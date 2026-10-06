#!/usr/bin/env bash
# Passo 4 (alternativa ao portal): Private Endpoint do blob, de propósito SEM DNS.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/00-variaveis.sh"

STG_ID="$(az storage account show --name "$STG" --resource-group "$RG" --query id --output tsv)"

echo ">> Private Endpoint $PE na subnet $SNET_PE"
az network private-endpoint create \
  --name "$PE" \
  --resource-group "$RG" \
  --vnet-name "$VNET" \
  --subnet "$SNET_PE" \
  --private-connection-resource-id "$STG_ID" \
  --group-id blob \
  --connection-name "con-$PE" \
  --output none

az network private-endpoint show \
  --name "$PE" \
  --resource-group "$RG" \
  --query "{estado:provisioningState, conexao:privateLinkServiceConnections[0].privateLinkServiceConnectionState.status, dns:customDnsConfigs}" \
  --output json
