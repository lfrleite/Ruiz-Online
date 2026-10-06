#!/usr/bin/env bash
# Passo 10: Azure DNS Private Resolver com um inbound endpoint.
# É para esse IP que o DNS on-premises aponta o conditional forwarder
# da zona pública do serviço (blob.core.windows.net).
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/00-variaveis.sh"

echo ">> Extensão dns-resolver do Azure CLI"
az extension add --name dns-resolver --only-show-errors

echo ">> Subnet dedicada e delegada para o inbound endpoint"
az network vnet subnet create \
  --resource-group "$RG" \
  --vnet-name "$VNET" \
  --name "$SNET_DNS" \
  --address-prefixes 10.60.3.0/28 \
  --delegations Microsoft.Network/dnsResolvers \
  --output none

VNET_ID="$(az network vnet show --resource-group "$RG" --name "$VNET" --query id --output tsv)"
SUBNET_ID="$(az network vnet subnet show --resource-group "$RG" --vnet-name "$VNET" --name "$SNET_DNS" --query id --output tsv)"

echo ">> Private Resolver $RESOLVER"
az dns-resolver create \
  --name "$RESOLVER" \
  --resource-group "$RG" \
  --location "$LOCATION" \
  --id "$VNET_ID" \
  --output none

echo ">> Inbound endpoint $INBOUND"
az dns-resolver inbound-endpoint create \
  --name "$INBOUND" \
  --dns-resolver-name "$RESOLVER" \
  --resource-group "$RG" \
  --location "$LOCATION" \
  --ip-configurations "[{private-ip-allocation-method:Dynamic,id:$SUBNET_ID}]" \
  --output none

INBOUND_IP="$(az dns-resolver inbound-endpoint show \
  --name "$INBOUND" \
  --dns-resolver-name "$RESOLVER" \
  --resource-group "$RG" \
  --query "ipConfigurations[0].privateIpAddress" \
  --output tsv)"

echo
echo "Pronto. IP do inbound endpoint: $INBOUND_IP"
echo "Teste: ./teste-dentro-fora.sh $INBOUND_IP"
