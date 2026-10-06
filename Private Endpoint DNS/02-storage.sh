#!/usr/bin/env bash
# Passo 2: Storage Account, container, um blob de teste e uma URL com SAS de leitura.
# Nada de chave de conta: tudo com Microsoft Entra ID e user delegation SAS.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/00-variaveis.sh"

echo ">> Storage Account $STG"
az storage account create \
  --name "$STG" \
  --resource-group "$RG" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false \
  --output none

STG_ID="$(az storage account show --name "$STG" --resource-group "$RG" --query id --output tsv)"
USER_ID="$(az ad signed-in-user show --query id --output tsv)"

echo ">> Role Storage Blob Data Contributor para o usuário logado, só nesta conta"
ATRIBUICAO_ROLE="$(az role assignment list \
  --assignee "$USER_ID" \
  --role "Storage Blob Data Contributor" \
  --scope "$STG_ID" \
  --query "[0].id" \
  --output tsv)"
if [ -z "$ATRIBUICAO_ROLE" ]; then
  az role assignment create \
    --assignee-object-id "$USER_ID" \
    --assignee-principal-type User \
    --role "Storage Blob Data Contributor" \
    --scope "$STG_ID" \
    --output none
else
  echo "   a role já estava atribuída, seguindo"
fi

echo ">> Container $CONTAINER (o RBAC pode levar alguns minutos para propagar)"
CRIADO=0
for TENTATIVA in $(seq 1 10); do
  if az storage container create \
       --account-name "$STG" \
       --name "$CONTAINER" \
       --auth-mode login \
       --only-show-errors \
       --output none 2>/dev/null; then
    CRIADO=1
    break
  fi
  echo "   tentativa $TENTATIVA de 10 sem permissão ainda, aguardando 30 segundos"
  sleep 30
done
if [ "$CRIADO" -ne 1 ]; then
  echo "ERRO: não consegui criar o container. Confira a role em $STG e rode de novo." >&2
  exit 1
fi

echo ">> Blob $BLOB"
ARQ_TMP="$(mktemp)"
trap 'rm -f "$ARQ_TMP"' EXIT
echo "Se você está lendo isso, o blob respondeu." > "$ARQ_TMP"
az storage blob upload \
  --account-name "$STG" \
  --container-name "$CONTAINER" \
  --name "$BLOB" \
  --file "$ARQ_TMP" \
  --auth-mode login \
  --overwrite true \
  --only-show-errors \
  --output none

echo ">> URL com user delegation SAS, somente leitura, válida por 24 horas"
EXPIRA="$(date -u -d '+1 day' '+%Y-%m-%dT%H:%MZ')"
SAS_URL="$(az storage blob generate-sas \
  --account-name "$STG" \
  --container-name "$CONTAINER" \
  --name "$BLOB" \
  --permissions r \
  --expiry "$EXPIRA" \
  --https-only \
  --auth-mode login \
  --as-user \
  --full-uri \
  --output tsv)"

( umask 077; printf '%s\n' "$SAS_URL" > "$ARQ_SAS" )
echo
echo "Pronto. Endpoint do blob: https://$FQDN"
echo "URL com SAS gravada em $ARQ_SAS (não cole esse conteúdo em print nem em chat)."
