#!/usr/bin/env bash
# Compara a imagem de nó em uso com a mais recente disponível em cada node pool de um cluster AKS.
# Uso: ./aks-node-image-status.sh <resource-group> <cluster>
# Retorno: 0 = todos os pools na imagem mais recente | 2 = existe pool atrasado | 1 = erro
set -euo pipefail

RG="${1:-}"
CLUSTER="${2:-}"

if [[ -z "$RG" || -z "$CLUSTER" ]]; then
  echo "Uso: $0 <resource-group> <cluster>" >&2
  exit 1
fi

if ! command -v az >/dev/null 2>&1; then
  echo "Azure CLI não encontrada no PATH." >&2
  exit 1
fi

if ! az account show >/dev/null 2>&1; then
  echo "Sem sessão ativa no Azure. Execute 'az login' antes de rodar o script." >&2
  exit 1
fi

if ! POOLS=$(az aks nodepool list \
  --resource-group "$RG" \
  --cluster-name "$CLUSTER" \
  --query "[].name" \
  --output tsv); then
  echo "Não consegui listar os node pools de '$CLUSTER' em '$RG'. Confira os nomes e a sua permissão." >&2
  exit 1
fi

if [[ -z "$POOLS" ]]; then
  echo "O cluster '$CLUSTER' não retornou nenhum node pool." >&2
  exit 1
fi

ATRASADOS=0
printf '%-14s %-10s %-52s %-52s %s\n' "POOL" "K8S" "IMAGEM ATUAL" "IMAGEM DISPONIVEL" "SITUACAO"

for POOL in $POOLS; do
  ATUAL=$(az aks nodepool show \
    --resource-group "$RG" \
    --cluster-name "$CLUSTER" \
    --name "$POOL" \
    --query nodeImageVersion \
    --output tsv)

  K8S=$(az aks nodepool show \
    --resource-group "$RG" \
    --cluster-name "$CLUSTER" \
    --name "$POOL" \
    --query orchestratorVersion \
    --output tsv)

  DISPONIVEL=$(az aks nodepool get-upgrades \
    --resource-group "$RG" \
    --cluster-name "$CLUSTER" \
    --nodepool-name "$POOL" \
    --query latestNodeImageVersion \
    --output tsv)

  if [[ "$ATUAL" == "$DISPONIVEL" ]]; then
    SITUACAO="em dia"
  else
    SITUACAO="ATRASADO"
    ATRASADOS=$((ATRASADOS + 1))
  fi

  printf '%-14s %-10s %-52s %-52s %s\n' "$POOL" "$K8S" "$ATUAL" "$DISPONIVEL" "$SITUACAO"
done

if [[ "$ATRASADOS" -gt 0 ]]; then
  echo
  echo "$ATRASADOS node pool(s) com imagem de nó mais nova disponível."
  exit 2
fi

echo
echo "Todos os node pools estão na imagem de nó mais recente da região."
