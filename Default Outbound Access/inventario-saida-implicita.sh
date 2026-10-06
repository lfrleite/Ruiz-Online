#!/usr/bin/env bash
# inventario-saida-implicita.sh
# Lista as subnets que ainda não são privadas e as NICs com IP de saída implícito,
# usando o Azure Resource Graph, e grava um CSV para cada consulta.
#
# Uso:
#   bash inventario-saida-implicita.sh                          # assinaturas a que você tem acesso
#   bash inventario-saida-implicita.sh -s <subscriptionId>      # uma assinatura
#   bash inventario-saida-implicita.sh -m <managementGroupId>   # um management group
#   bash inventario-saida-implicita.sh -o ./saida               # pasta de destino dos CSVs
#
# Requisitos: Azure CLI com sessão ativa (az login), jq e permissão de Reader no escopo.
# O script só lê. Nenhum recurso é alterado.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PAGE_SIZE=1000
OUT_DIR="."
SCOPE_ARGS=()

usage() {
  sed -n '2,13p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

fail() {
  echo "ERRO: $*" >&2
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -s|--subscription)
      [[ $# -ge 2 ]] || fail "informe o ID da assinatura depois de $1"
      SCOPE_ARGS=(--subscriptions "$2"); shift 2 ;;
    -m|--management-group)
      [[ $# -ge 2 ]] || fail "informe o ID do management group depois de $1"
      SCOPE_ARGS=(--management-groups "$2"); shift 2 ;;
    -o|--output-dir)
      [[ $# -ge 2 ]] || fail "informe a pasta de destino depois de $1"
      OUT_DIR="$2"; shift 2 ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      usage >&2; fail "parâmetro desconhecido: $1" ;;
  esac
done

command -v az >/dev/null 2>&1 || fail "Azure CLI não encontrado. Use o Cloud Shell ou instale o az."
command -v jq >/dev/null 2>&1 || fail "jq não encontrado. Instale o jq ou use o Cloud Shell."
az account show >/dev/null 2>&1 || fail "sem sessão no Azure. Execute az login antes."

mkdir -p "$OUT_DIR" || fail "não foi possível criar a pasta $OUT_DIR"

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

# Executa uma consulta .kql com paginação e grava o resultado em CSV.
run_query() {
  local kql_file="$1" csv_file="$2" label="$3"
  local query rows total page_file
  local skip=0 page=0
  local skip_args=()

  [[ -f "$kql_file" ]] || fail "arquivo de consulta não encontrado: $kql_file"

  # Remove as linhas de comentário e junta a consulta em uma linha só.
  query="$(grep -vE '^[[:space:]]*//' "$kql_file" | tr '\n' ' ')"

  rm -f "$WORK_DIR"/page-*.json

  while :; do
    page_file="$(printf '%s/page-%05d.json' "$WORK_DIR" "$page")"

    skip_args=()
    if [[ "$skip" -gt 0 ]]; then
      skip_args=(--skip "$skip")
    fi

    if ! az graph query -q "$query" --first "$PAGE_SIZE" \
        ${skip_args[@]+"${skip_args[@]}"} \
        ${SCOPE_ARGS[@]+"${SCOPE_ARGS[@]}"} \
        --query "data" --output json > "$page_file"; then
      fail "a consulta de $label falhou. Confira a mensagem do az acima."
    fi

    # Sem esta checagem, uma resposta em formato inesperado viraria "nenhum registro".
    if ! jq -e 'type == "array"' "$page_file" >/dev/null 2>&1; then
      fail "a resposta de $label não veio como lista de registros. Rode o az graph query na mão e confira o formato da saída."
    fi

    rows="$(jq 'length' "$page_file")"
    if [[ "$rows" -lt "$PAGE_SIZE" ]]; then
      break
    fi

    skip=$((skip + PAGE_SIZE))
    page=$((page + 1))
  done

  jq -s 'add' "$WORK_DIR"/page-*.json > "$WORK_DIR/all.json"
  total="$(jq 'length' "$WORK_DIR/all.json")"

  if [[ "$total" -eq 0 ]]; then
    echo "$label: nenhum registro encontrado."
    return 0
  fi

  jq -r '(.[0] | keys_unsorted) as $cols
         | ($cols | @csv),
           (.[] | [ .[$cols[]] ] | map(if . == null then "" else tostring end) | @csv)' \
    "$WORK_DIR/all.json" > "$csv_file"

  echo "$label: $total registro(s) em $csv_file"
}

STAMP="$(date +%Y%m%d-%H%M%S)"

run_query "$SCRIPT_DIR/subnets-nao-privadas.kql" \
  "$OUT_DIR/subnets-nao-privadas-$STAMP.csv" "Subnets não privadas"

run_query "$SCRIPT_DIR/nics-saida-implicita.kql" \
  "$OUT_DIR/nics-saida-implicita-$STAMP.csv" "NICs com saída implícita"

echo "Concluído."
