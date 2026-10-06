#!/usr/bin/env bash
# Artigo 024 - Migrando de NSG flow logs para VNet flow logs
# Gera trafego permitido e negado a partir da vm-flowlogs-lab-001 usando Run Command.
# Nao abre SSH nem RDP para a internet.
#
# Uso:
#   az login
#   bash 024-gerar-trafego.sh

set -euo pipefail

RG="rg-flowlogs-lab-wus2-001"
VM1="vm-flowlogs-lab-001"
VM2="vm-flowlogs-lab-002"

if ! az account show >/dev/null 2>&1; then
  echo "ERRO: sem sessao ativa. Rode 'az login' antes." >&2
  exit 1
fi

VM2_IP="$(az vm show --resource-group "$RG" --name "$VM2" --show-details --query privateIps --output tsv)"

if [ -z "$VM2_IP" ]; then
  echo "ERRO: nao consegui ler o IP privado da $VM2. A VM existe e esta ligada?" >&2
  exit 1
fi

echo "IP privado da $VM2: $VM2_IP"
echo "Gerando trafego a partir da $VM1 (cerca de 1 minuto)..."

az vm run-command invoke --resource-group "$RG" --name "$VM1" \
  --command-id RunShellScript \
  --scripts "for i in 1 2 3 4 5; do
    curl -s -o /dev/null -m 5 https://learn.microsoft.com && echo 'saida 443 ok';
    timeout 3 bash -c '</dev/tcp/$VM2_IP/22' && echo 'intra-vnet 22 ok';
    timeout 3 bash -c '</dev/tcp/$VM2_IP/8080' || echo 'intra-vnet 8080 sem resposta';
    sleep 5;
  done"
