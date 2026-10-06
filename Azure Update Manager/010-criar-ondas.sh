#!/usr/bin/env bash
# Artigo 010 - Ondas de patch com escopo dinâmico e TAGs
# Cria uma maintenance configuration (escopo Guest) por onda e associa a ela um dynamic scope
# no nível da assinatura, filtrando pela TAG da onda.
#
# Uso padrão (cria HML e PRD, a DEV foi criada pelo portal no Passo 3):
#   ./010-criar-ondas.sh
#
# Tudo pela CLI, com a DEV em recorrência diaria para o teste do laboratório:
#   ONDAS="DEV HML PRD" DEV_RECUR="Day" \
#   DEV_START="$(TZ=America/Sao_Paulo date -d '+40 minutes' '+%Y-%m-%d %H:%M')" \
#   ./010-criar-ondas.sh
#
# Autenticação: use o Cloud Shell ou rode "az login" antes. Nenhuma credencial fica no script.

set -euo pipefail

RG="${RG:-rg-aum-lab-wus2-001}"
LOCATION="${LOCATION:-westus2}"
TAG_KEY="${TAG_KEY:-OndaPatch}"
TIME_ZONE="${TIME_ZONE:-E. South America Standard Time}"
DURATION="${DURATION:-02:00}"
START_TIME="${START_TIME:-22:00}"
ONDAS="${ONDAS:-HML PRD}"

# A data de início é só o ponto de partida. A primeira execução acontece na primeira
# recorrência depois dela, então amanhã serve para qualquer onda mensal.
START_DATE="${START_DATE:-$(TZ=America/Sao_Paulo date -d '+1 day' '+%Y-%m-%d')}"

trap 'echo "ERRO na linha $LINENO. Confira a mensagem acima antes de rodar de novo." >&2' ERR

command -v az >/dev/null 2>&1 || { echo "Azure CLI não encontrada." >&2; exit 1; }
az account show --only-show-errors --output none || { echo "Sem sessão ativa. Rode az login." >&2; exit 1; }

SUBSCRIPTION_ID="$(az account show --query id --output tsv)"

ESTADO_RP="$(az provider show --namespace Microsoft.Maintenance --query registrationState --output tsv)"
if [ "$ESTADO_RP" != "Registered" ]; then
  echo "O provider Microsoft.Maintenance está como '$ESTADO_RP'. Registre e aguarde antes de continuar:" >&2
  echo "  az provider register --namespace Microsoft.Maintenance" >&2
  exit 1
fi

az group show --name "$RG" --only-show-errors --output none || { echo "Resource group $RG não encontrado." >&2; exit 1; }

for ONDA in $ONDAS; do
  case "$ONDA" in
    DEV)
      RECUR="${DEV_RECUR:-Month Second Tuesday Offset1}"
      START="${DEV_START:-$START_DATE $START_TIME}"
      ;;
    HML)
      RECUR="Month Second Tuesday Offset6"
      START="$START_DATE $START_TIME"
      ;;
    PRD)
      RECUR="Month Third Tuesday Offset4"
      START="$START_DATE $START_TIME"
      ;;
    *)
      echo "Onda desconhecida: $ONDA. Use DEV, HML ou PRD." >&2
      exit 1
      ;;
  esac

  SUFIXO="$(echo "$ONDA" | tr '[:upper:]' '[:lower:]')"
  MC_NAME="mc-aum-$SUFIXO-wus2-001"
  DS_NAME="ds-aum-$SUFIXO"

  echo "[$ONDA] Criando a maintenance configuration $MC_NAME ($RECUR, início em $START)..."
  az maintenance configuration create \
    --resource-group "$RG" \
    --resource-name "$MC_NAME" \
    --maintenance-scope InGuestPatch \
    --location "$LOCATION" \
    --maintenance-window-duration "$DURATION" \
    --maintenance-window-recur-every "$RECUR" \
    --maintenance-window-start-date-time "$START" \
    --maintenance-window-time-zone "$TIME_ZONE" \
    --install-patches-linux-parameters classifications-to-include="[Critical,Security]" \
    --install-patches-windows-parameters classifications-to-include="[Critical,Security]" \
    --reboot-setting IfRequired \
    --extension-properties InGuestPatchMode="User" \
    --tags "$TAG_KEY=$ONDA" Ambiente=Lab \
    --only-show-errors \
    --output none

  MC_ID="$(az maintenance configuration show \
    --resource-group "$RG" \
    --resource-name "$MC_NAME" \
    --query id \
    --output tsv)"

  echo "[$ONDA] Criando o dynamic scope $DS_NAME com o filtro $TAG_KEY=$ONDA..."
  az maintenance assignment create-or-update-subscription \
    --subscription "$SUBSCRIPTION_ID" \
    --name "$DS_NAME" \
    --maintenance-configuration-id "$MC_ID" \
    --location global \
    --filter-resource-groups "$RG" \
    --filter-locations "$LOCATION" \
    --filter-os-types windows linux \
    --filter-tags "{$TAG_KEY:[$ONDA]}" \
    --filter-tags-operator All \
    --only-show-errors \
    --output none

  echo "[$ONDA] Pronto."
done

echo "Dynamic scopes da assinatura:"
az maintenance assignment list-subscription --output json
