#!/usr/bin/env bash
#
# compliance-export-csv.sh
# Exporta para CSV o resultado das consultas compliance-*.kql desta pasta,
# usando o Azure Resource Graph pelo Azure CLI.
#
# Uso:
#   ./compliance-export-csv.sh                              # todas as assinaturas que o login enxerga
#   ./compliance-export-csv.sh -s "<subId1> <subId2>"       # assinaturas especificas
#   ./compliance-export-csv.sh -m "<managementGroupId>"     # um management group
#   ./compliance-export-csv.sh -o ./relatorios              # pasta de saida
#
# Requisitos: Azure CLI 2.22.0 ou superior, extensao resource-graph, jq e uma
# sessao ja autenticada (az login). O script nao guarda nem pede credencial.
# Permissao: leitura (Reader) nos recursos consultados.

set -euo pipefail

PAGE_SIZE=1000   # valor maximo aceito pelo parametro --first
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT_DIR="./compliance-$(date +%Y-%m-%d)"
SUBSCRIPTIONS=""
MANAGEMENT_GROUPS=""

usage() {
  sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//'
  exit "${1:-0}"
}

fail() {
  echo "ERRO: $*" >&2
  exit 1
}

while getopts ":s:m:o:h" opt; do
  case "$opt" in
    s) SUBSCRIPTIONS="$OPTARG" ;;
    m) MANAGEMENT_GROUPS="$OPTARG" ;;
    o) OUT_DIR="$OPTARG" ;;
    h) usage 0 ;;
    :) fail "a opcao -$OPTARG exige um valor." ;;
    \?) fail "opcao invalida: -$OPTARG. Use -h para ver o uso." ;;
  esac
done

if [ -n "$SUBSCRIPTIONS" ] && [ -n "$MANAGEMENT_GROUPS" ]; then
  fail "use -s ou -m, nao os dois ao mesmo tempo."
fi

command -v az >/dev/null 2>&1 || fail "Azure CLI nao encontrado."
command -v jq >/dev/null 2>&1 || fail "jq nao encontrado."

az account show --query id -o tsv >/dev/null 2>&1 \
  || fail "nenhuma sessao ativa. Rode 'az login' antes."

# A extensao resource-graph e quem entrega o comando 'az graph'.
EXT_COUNT="$(az extension list --query "[?name=='resource-graph'] | length(@)" -o tsv)"
if [ "$EXT_COUNT" = "0" ]; then
  echo "Instalando a extensao resource-graph..."
  az extension add --name resource-graph >/dev/null
fi

FAILED=0
SCOPE_ARGS=()
if [ -n "$SUBSCRIPTIONS" ]; then
  # shellcheck disable=SC2206
  SCOPE_ARGS=(--subscriptions $SUBSCRIPTIONS)
elif [ -n "$MANAGEMENT_GROUPS" ]; then
  # shellcheck disable=SC2206
  SCOPE_ARGS=(--management-groups $MANAGEMENT_GROUPS)
fi

shopt -s nullglob
QUERY_FILES=("$SCRIPT_DIR"/compliance-*.kql)
shopt -u nullglob
[ "${#QUERY_FILES[@]}" -gt 0 ] || fail "nenhum arquivo compliance-*.kql em $SCRIPT_DIR."

mkdir -p "$OUT_DIR"

# Converte a lista de objetos devolvida em 'data' para CSV.
# Colunas que vierem como objeto ou lista viram texto JSON dentro da celula.
JQ_HEADER='.data[0] | keys_unsorted | @csv'
JQ_ROWS='(.data[0] | keys_unsorted) as $cols
  | .data[]
  | [ .[$cols[]] | if type == "object" or type == "array" then tojson else . end ]
  | @csv'

for query_file in "${QUERY_FILES[@]}"; do
  name="$(basename "$query_file" .kql)"
  csv_file="$OUT_DIR/$name.csv"
  query="$(cat "$query_file")"
  skip=0
  total=0
  : > "$csv_file"

  echo "Consultando $name..."

  query_failed=0

  while :; do
    skip_args=()
    if [ "$skip" -gt 0 ]; then
      skip_args=(--skip "$skip")
    fi

    if ! page="$(az graph query -q "$query" --first "$PAGE_SIZE" \
        ${skip_args[@]+"${skip_args[@]}"} \
        ${SCOPE_ARGS[@]+"${SCOPE_ARGS[@]}"} \
        -o json)"; then
      query_failed=1
      break
    fi

    # Se o retorno nao for o JSON esperado, a consulta conta como falha.
    if ! rows="$(jq -e '.data | length' <<<"$page" 2>/dev/null)"; then
      query_failed=1
      break
    fi

    if [ "$rows" -eq 0 ]; then
      break
    fi

    if [ "$total" -eq 0 ]; then
      if ! jq -r "$JQ_HEADER" <<<"$page" >> "$csv_file"; then
        query_failed=1
        break
      fi
    fi
    if ! jq -r "$JQ_ROWS" <<<"$page" >> "$csv_file"; then
      query_failed=1
      break
    fi

    total=$((total + rows))

    # Pagina incompleta significa que acabou.
    if [ "$rows" -lt "$PAGE_SIZE" ]; then
      break
    fi
    skip=$((skip + PAGE_SIZE))
  done

  if [ "$query_failed" -eq 1 ]; then
    # Resultado parcial engana mais do que ajuda: o arquivo incompleto e removido.
    rm -f "$csv_file"
    FAILED=$((FAILED + 1))
    echo "  FALHOU. Rode o arquivo no Resource Graph Explorer para ver a mensagem completa." >&2
  elif [ "$total" -eq 0 ]; then
    rm -f "$csv_file"
    echo "  sem registros no escopo consultado."
  else
    echo "  $total linha(s) em $csv_file"
  fi
done

if [ "$FAILED" -gt 0 ]; then
  fail "$FAILED consulta(s) falharam. Os demais arquivos estao em: $OUT_DIR"
fi

echo "Concluido. Arquivos em: $OUT_DIR"
