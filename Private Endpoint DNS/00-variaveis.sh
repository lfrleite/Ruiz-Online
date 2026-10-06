#!/usr/bin/env bash
# Variáveis do laboratório "Private Endpoint e DNS privado".
# Os outros scripts carregam este arquivo sozinhos. Para usar as variáveis
# direto no terminal: source ./00-variaveis.sh

export LOCATION="${LOCATION:-westus2}"
export RG="${RG:-rg-pedns-lab-wus2-001}"
export VNET="${VNET:-vnet-pedns-lab-wus2-001}"
export SNET_VM="${SNET_VM:-snet-pedns-vm-wus2-001}"
export SNET_PE="${SNET_PE:-snet-pedns-pe-wus2-001}"
export SNET_DNS="${SNET_DNS:-snet-pedns-dnsin-wus2-001}"
export NSG="${NSG:-nsg-pedns-vm-wus2-001}"
export VM="${VM:-vm-pedns-lab-wus2-001}"
export PE="${PE:-pep-pedns-blob-wus2-001}"
export ZONA="privatelink.blob.core.windows.net"
export LINK="${LINK:-link-vnet-pedns-lab-wus2-001}"
export RESOLVER="${RESOLVER:-dnspr-pedns-lab-wus2-001}"
export INBOUND="${INBOUND:-in-pedns-lab-wus2-001}"
export ATRIBUICAO="${ATRIBUICAO:-pedns-blob-zone-group}"
export CONTAINER="${CONTAINER:-lab}"
export BLOB="${BLOB:-teste.txt}"
export ARQ_SAS="${ARQ_SAS:-$HOME/.pedns-lab-sas-url}"

if ! az account show --only-show-errors >/dev/null 2>&1; then
  echo "ERRO: sem sessão no Azure CLI. Rode 'az login' e tente de novo." >&2
  return 1 2>/dev/null || exit 1
fi

SUB_ID="$(az account show --query id --output tsv)"
export SUB_ID

# Nome de Storage Account é único no mundo inteiro, então o sufixo sai do ID da assinatura.
export STG="${STG:-stpednslab$(echo "$SUB_ID" | tr -d '-' | cut -c1-8)}"
export FQDN="$STG.blob.core.windows.net"
