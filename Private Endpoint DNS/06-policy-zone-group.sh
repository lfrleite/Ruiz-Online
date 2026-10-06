#!/usr/bin/env bash
# Passo 12: atribui a policy built-in "Configure a private DNS Zone ID for blob groupID"
# no Resource Group do laboratório, com identidade gerenciada e a role que ela pede.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/00-variaveis.sh"

POLICY_ID="/providers/Microsoft.Authorization/policyDefinitions/75973700-529f-4de2-b794-fb9b6781b6b0"
# Network Contributor: é a role que a própria definição declara em roleDefinitionIds.
ROLE_ID="4d97b98b-1d4f-4787-a291-c67834d212e7"

RG_ID="$(az group show --name "$RG" --query id --output tsv)"
ZONA_ID="$(az network private-dns zone show --resource-group "$RG" --name "$ZONA" --query id --output tsv)"

echo ">> Atribuição $ATRIBUICAO no escopo $RG"
az policy assignment create \
  --name "$ATRIBUICAO" \
  --display-name "Lab: zone group automatico para Private Endpoint de blob" \
  --policy "$POLICY_ID" \
  --scope "$RG_ID" \
  --params "{ 'privateDnsZoneId': { 'value': '$ZONA_ID' } }" \
  --mi-system-assigned \
  --location "$LOCATION" \
  --identity-scope "$RG_ID" \
  --role "$ROLE_ID" \
  --output none

az policy assignment show \
  --name "$ATRIBUICAO" \
  --scope "$RG_ID" \
  --query "{atribuicao:name, identidade:identity.principalId}" \
  --output json
