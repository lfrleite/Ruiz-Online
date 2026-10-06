#!/usr/bin/env bash
# Passo 6: zona privatelink, link com a VNet e DNS zone group no Private Endpoint.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/00-variaveis.sh"

echo ">> Zona privada $ZONA"
az network private-dns zone create \
  --resource-group "$RG" \
  --name "$ZONA" \
  --output none

echo ">> Link da zona com a VNet $VNET (sem auto-registro)"
az network private-dns link vnet create \
  --resource-group "$RG" \
  --zone-name "$ZONA" \
  --name "$LINK" \
  --virtual-network "$VNET" \
  --registration-enabled false \
  --output none

echo ">> DNS zone group no Private Endpoint $PE"
az network private-endpoint dns-zone-group create \
  --resource-group "$RG" \
  --endpoint-name "$PE" \
  --name default \
  --private-dns-zone "$ZONA" \
  --zone-name blob \
  --output none

echo
echo "Registros A na zona:"
az network private-dns record-set a list \
  --resource-group "$RG" \
  --zone-name "$ZONA" \
  --query "[].{Nome:name, TTL:ttl, IP:aRecords[0].ipv4Address}" \
  --output table

echo
echo "Links da zona:"
az network private-dns link vnet list \
  --resource-group "$RG" \
  --zone-name "$ZONA" \
  --query "[].{Link:name, Estado:virtualNetworkLinkState, AutoRegistro:registrationEnabled}" \
  --output table
