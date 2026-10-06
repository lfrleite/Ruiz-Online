#!/usr/bin/env bash
# Diagnóstico somente leitura de um Private Endpoint e do DNS em volta dele.
# Uso: ./diagnostico-pe-dns.sh <rg-do-pe> <nome-do-pe> <rg-da-zona> <nome-da-zona> [id-da-vnet-de-origem]
# Exemplo:
#   ./diagnostico-pe-dns.sh rg-pedns-lab-wus2-001 pep-pedns-blob-wus2-001 \
#     rg-pedns-lab-wus2-001 privatelink.blob.core.windows.net
set -uo pipefail

if [ "$#" -lt 4 ]; then
  echo "Uso: $0 <rg-do-pe> <nome-do-pe> <rg-da-zona> <nome-da-zona> [id-da-vnet-de-origem]" >&2
  exit 1
fi

PE_RG="$1"
PE_NOME="$2"
ZONA_RG="$3"
ZONA_NOME="$4"
VNET_ORIGEM_ID="${5:-}"

if ! az account show --only-show-errors >/dev/null 2>&1; then
  echo "ERRO: sem sessão no Azure CLI. Rode 'az login' e tente de novo." >&2
  exit 1
fi

titulo() { echo; echo "---- $1 ----"; }

titulo "1. O Private Endpoint existe e a conexão foi aprovada?"
if ! az network private-endpoint show \
      --name "$PE_NOME" \
      --resource-group "$PE_RG" \
      --query "{nome:name, estado:provisioningState, conexao:privateLinkServiceConnections[0].privateLinkServiceConnectionState.status, fqdnEsperado:customDnsConfigs}" \
      --output json; then
  echo "ERRO: Private Endpoint $PE_NOME não encontrado em $PE_RG." >&2
  exit 1
fi

titulo "2. Qual IP privado a NIC do endpoint recebeu?"
NIC_ID="$(az network private-endpoint show --name "$PE_NOME" --resource-group "$PE_RG" --query "networkInterfaces[0].id" --output tsv)"
az network nic show \
  --ids "$NIC_ID" \
  --query "ipConfigurations[].{config:name, ipPrivado:privateIPAddress, fqdns:privateLinkConnectionProperties.fqdns}" \
  --output json

titulo "3. O endpoint tem DNS zone group? Apontando para qual zona?"
az network private-endpoint dns-zone-group list \
  --endpoint-name "$PE_NOME" \
  --resource-group "$PE_RG" \
  --query "[].{grupo:name, zonas:privateDnsZoneConfigs[].privateDnsZoneId}" \
  --output json

titulo "4. Quais registros A existem na zona $ZONA_NOME?"
az network private-dns record-set a list \
  --zone-name "$ZONA_NOME" \
  --resource-group "$ZONA_RG" \
  --query "[].{Nome:name, TTL:ttl, IP:aRecords[0].ipv4Address}" \
  --output table \
  || echo "AVISO: zona $ZONA_NOME não encontrada em $ZONA_RG."

titulo "5. A zona está linkada com quais VNets?"
az network private-dns link vnet list \
  --zone-name "$ZONA_NOME" \
  --resource-group "$ZONA_RG" \
  --query "[].{Link:name, Estado:virtualNetworkLinkState, Fallback:resolutionPolicy, VNet:virtualNetwork.id}" \
  --output table

titulo "6. A VNet de origem usa DNS do Azure ou DNS customizado?"
if [ -z "$VNET_ORIGEM_ID" ]; then
  SUBNET_ID="$(az network private-endpoint show --name "$PE_NOME" --resource-group "$PE_RG" --query "subnet.id" --output tsv)"
  VNET_ORIGEM_ID="${SUBNET_ID%/subnets/*}"
  echo "(sem VNet informada, olhando a VNet do próprio endpoint)"
fi
az network vnet show \
  --ids "$VNET_ORIGEM_ID" \
  --query "{vnet:name, dnsServers:dhcpOptions.dnsServers}" \
  --output json

echo
echo "Leitura rápida:"
echo "- conexao diferente de Approved: o problema ainda não é DNS."
echo "- sem zone group e sem registro A: o endpoint foi criado sem integração de DNS."
echo "- registro A certo, mas a VNet de origem fora da lista de links: falta o link."
echo "- dnsServers preenchido: o servidor customizado precisa encaminhar a zona pública do serviço para 168.63.129.16."
