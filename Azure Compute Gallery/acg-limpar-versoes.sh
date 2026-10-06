#!/usr/bin/env bash
#
# acg-limpar-versoes.sh
# Remove versões antigas de imagem em uma Azure Compute Gallery, mantendo as N mais altas
# de cada image definition.
#
# Por padrão o script NÃO apaga nada: ele só mostra o que faria. Para apagar, use --executar.
#
# Uma versão nunca é removida quando:
#   - está entre as N versões mais altas da image definition;
#   - é a versão que o "latest" resolve hoje (a mais alta com excludeFromLatest = false);
#   - é referenciada por algum Virtual Machine Scale Set da assinatura atual;
#   - tem end of life date no futuro (a não ser que você passe --ignorar-eol).
#
# Requisitos: Azure CLI autenticado (az login) e bash com GNU sort e GNU date.
# O Azure Cloud Shell atende aos dois.
#
# Uso:
#   ./acg-limpar-versoes.sh -g <resource-group> -r <galeria> [-i <image-definition>] [-k <N>] [--ignorar-eol] [--executar]
#
# Exemplos:
#   ./acg-limpar-versoes.sh -g rg-aib-lab-wus2-001 -r gal_aib_lab_wus2_001 -k 3
#   ./acg-limpar-versoes.sh -g rg-aib-lab-wus2-001 -r gal_aib_lab_wus2_001 -i imgdef-debian13 -k 2 --executar

set -euo pipefail

RESOURCE_GROUP=""
GALLERY=""
IMAGE_DEFINITION=""
KEEP=3
EXECUTAR="false"
IGNORAR_EOL="false"

uso() {
  sed -n '2,23p' "$0" | sed 's/^# \{0,1\}//'
}

erro() {
  echo "ERRO: $*" >&2
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -g|--resource-group|-r|--gallery-name|-i|--image-definition|-k|--manter)
      [[ $# -ge 2 ]] || { uso; erro "o parâmetro $1 precisa de um valor"; }
      case "$1" in
        -g|--resource-group)   RESOURCE_GROUP="$2" ;;
        -r|--gallery-name)     GALLERY="$2" ;;
        -i|--image-definition) IMAGE_DEFINITION="$2" ;;
        -k|--manter)           KEEP="$2" ;;
      esac
      shift 2
      ;;
    --ignorar-eol)         IGNORAR_EOL="true"; shift ;;
    --executar)            EXECUTAR="true"; shift ;;
    -h|--help)             uso; exit 0 ;;
    *)                     uso; erro "parâmetro desconhecido: $1" ;;
  esac
done

[[ -n "$RESOURCE_GROUP" ]] || { uso; erro "informe o resource group com -g"; }
[[ -n "$GALLERY" ]]        || { uso; erro "informe a galeria com -r"; }
[[ "$KEEP" =~ ^[0-9]+$ ]]  || erro "o valor de -k precisa ser um número inteiro"
[[ "$KEEP" -ge 1 ]]        || erro "o valor de -k precisa ser 1 ou maior"

command -v az >/dev/null 2>&1 || erro "Azure CLI não encontrado"
az account show --output none 2>/dev/null || erro "sem sessão no Azure. Rode az login antes"

SUBSCRIPTION_NAME=$(az account show --query name --output tsv)
AGORA=$(date -u +%s)

echo "Assinatura : $SUBSCRIPTION_NAME"
echo "Galeria    : $GALLERY ($RESOURCE_GROUP)"
echo "Manter     : $KEEP versões mais altas por image definition"
if [[ "$EXECUTAR" == "true" ]]; then
  echo "Modo       : EXECUÇÃO (as versões candidatas serão apagadas)"
else
  echo "Modo       : simulação (nada será apagado, use --executar para apagar)"
fi
echo

# Image definitions a tratar
if [[ -n "$IMAGE_DEFINITION" ]]; then
  az sig image-definition show \
    --resource-group "$RESOURCE_GROUP" \
    --gallery-name "$GALLERY" \
    --gallery-image-definition "$IMAGE_DEFINITION" \
    --output none || erro "image definition $IMAGE_DEFINITION não encontrada"
  DEFINICOES="$IMAGE_DEFINITION"
else
  DEFINICOES=$(az sig image-definition list \
    --resource-group "$RESOURCE_GROUP" \
    --gallery-name "$GALLERY" \
    --query "[].name" \
    --output tsv)
fi

[[ -n "$DEFINICOES" ]] || { echo "Nenhuma image definition encontrada. Nada a fazer."; exit 0; }

# IDs de imagem referenciados por scale sets da assinatura atual (em minúsculas).
# Apagar uma versão usada por scale set quebra o scale out e o reimage dele.
# Se a consulta falhar (falta de permissão de leitura em scale sets, por exemplo), o script
# para aqui. Seguir em frente seria apagar versão sem saber se algum scale set depende dela.
if ! VMSS_BRUTO=$(az vmss list \
  --query "[].virtualMachineProfile.storageProfile.imageReference.id" \
  --output tsv); then
  erro "não consegui listar os scale sets da assinatura. Sem essa lista o script não apaga nada"
fi
VMSS_REFS=$(echo "$VMSS_BRUTO" | tr '[:upper:]' '[:lower:]')

TOTAL_CANDIDATAS=0
TOTAL_APAGADAS=0
TOTAL_FALHAS=0

for DEF in $DEFINICOES; do
  echo "== $DEF"

  # Uma linha por versão: nome, excludeFromLatest, endOfLifeDate, id
  LINHAS=$(az sig image-version list \
    --resource-group "$RESOURCE_GROUP" \
    --gallery-name "$GALLERY" \
    --gallery-image-definition "$DEF" \
    --query "[].[name, to_string(publishingProfile.excludeFromLatest || \`false\`), publishingProfile.endOfLifeDate || 'none', id]" \
    --output tsv)

  if [[ -z "$LINHAS" ]]; then
    echo "   sem versões"
    echo
    continue
  fi

  # Ordena da versão mais alta para a mais baixa (Major, depois Minor, depois Patch)
  ORDENADAS=$(echo "$LINHAS" | sort -t $'\t' -k1,1 -V -r)

  # Versão que o latest resolve hoje: a mais alta que não está excluída
  LATEST=$(echo "$ORDENADAS" | awk -F '\t' 'tolower($2) != "true" { print $1; exit }')

  POSICAO=0
  while IFS=$'\t' read -r NOME EXCLUIDA EOL ID; do
    POSICAO=$((POSICAO + 1))
    MOTIVO=""

    if [[ "$POSICAO" -le "$KEEP" ]]; then
      MOTIVO="entre as $KEEP mais altas"
    elif [[ "$NOME" == "$LATEST" ]]; then
      MOTIVO="é o latest atual"
    elif [[ -n "$VMSS_REFS" ]] && echo "$VMSS_REFS" | grep -qxF "$(echo "$ID" | tr '[:upper:]' '[:lower:]')"; then
      MOTIVO="referenciada por scale set"
    elif [[ "$IGNORAR_EOL" != "true" && "$EOL" != "none" ]]; then
      # Data que o date não entende vira motivo para manter, nunca para apagar.
      if ! EOL_EPOCH=$(date -u -d "$EOL" +%s 2>/dev/null); then
        MOTIVO="end of life com data ilegível: $EOL"
      elif [[ "$EOL_EPOCH" -gt "$AGORA" ]]; then
        MOTIVO="end of life em ${EOL%%T*}"
      fi
    fi

    if [[ -n "$MOTIVO" ]]; then
      printf '   manter   %-14s %s\n' "$NOME" "($MOTIVO)"
      continue
    fi

    TOTAL_CANDIDATAS=$((TOTAL_CANDIDATAS + 1))

    if [[ "$EXECUTAR" != "true" ]]; then
      printf '   apagaria %-14s\n' "$NOME"
      continue
    fi

    printf '   apagando %-14s ' "$NOME"
    if SAIDA=$(az sig image-version delete \
        --resource-group "$RESOURCE_GROUP" \
        --gallery-name "$GALLERY" \
        --gallery-image-definition "$DEF" \
        --gallery-image-version "$NOME" < /dev/null 2>&1); then
      echo "ok"
      TOTAL_APAGADAS=$((TOTAL_APAGADAS + 1))
    else
      echo "FALHOU"
      echo "$SAIDA" | sed 's/^/      /' >&2
      TOTAL_FALHAS=$((TOTAL_FALHAS + 1))
    fi
  done <<< "$ORDENADAS"

  echo
done

echo "Resumo: $TOTAL_CANDIDATAS candidata(s), $TOTAL_APAGADAS apagada(s), $TOTAL_FALHAS falha(s)."

if [[ "$TOTAL_FALHAS" -gt 0 ]]; then
  exit 1
fi
