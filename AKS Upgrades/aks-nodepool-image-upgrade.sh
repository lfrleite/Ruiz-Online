#!/usr/bin/env bash
# Atualiza somente a imagem de nó de um node pool do AKS, ajustando o surge antes, e acompanha até o fim.
# Uso: ./aks-nodepool-image-upgrade.sh <resource-group> <cluster> <node-pool> [max-surge] [--yes]
# Exemplo: ./aks-nodepool-image-upgrade.sh rg-aks-lab-wus2-001 aks-upgrade-lab-wus2-001 userpool 33%
# Sem --yes o script pede confirmação antes de disparar o upgrade.
set -euo pipefail

RG="${1:-}"
CLUSTER="${2:-}"
POOL="${3:-}"
MAX_SURGE="${4:-33%}"
CONFIRMA="${5:-}"
INTERVALO=30          # segundos entre uma consulta e outra
LIMITE_MINUTOS=120    # tempo máximo de acompanhamento

if [[ -z "$RG" || -z "$CLUSTER" || -z "$POOL" ]]; then
  echo "Uso: $0 <resource-group> <cluster> <node-pool> [max-surge] [--yes]" >&2
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

consulta_pool() {
  az aks nodepool show \
    --resource-group "$RG" \
    --cluster-name "$CLUSTER" \
    --name "$POOL" \
    --query "$1" \
    --output tsv
}

if ! ATUAL=$(consulta_pool nodeImageVersion); then
  echo "Não encontrei o node pool '$POOL' no cluster '$CLUSTER'." >&2
  exit 1
fi

ESTADO=$(consulta_pool provisioningState)
if [[ "$ESTADO" != "Succeeded" ]]; then
  echo "O node pool está em '$ESTADO'. Resolva a operação anterior antes de iniciar outra." >&2
  exit 1
fi

DISPONIVEL=$(az aks nodepool get-upgrades \
  --resource-group "$RG" \
  --cluster-name "$CLUSTER" \
  --nodepool-name "$POOL" \
  --query latestNodeImageVersion \
  --output tsv)

if [[ -z "$DISPONIVEL" ]]; then
  echo "O AKS não retornou a imagem disponível para '$POOL'. Rode 'az aks nodepool get-upgrades' na mão e confira." >&2
  exit 1
fi

echo "Imagem atual:      $ATUAL"
echo "Imagem disponível: $DISPONIVEL"

if [[ "$ATUAL" == "$DISPONIVEL" ]]; then
  echo "O node pool já está na imagem mais recente. Nada a fazer."
  exit 0
fi

if [[ "$CONFIRMA" != "--yes" ]]; then
  echo
  echo "Os nós de '$POOL' serão drenados e regravados com a imagem nova, um lote por vez."
  read -r -p "Digite o nome do node pool para confirmar: " RESPOSTA
  if [[ "$RESPOSTA" != "$POOL" ]]; then
    echo "Confirmação não confere. Nada foi alterado." >&2
    exit 1
  fi
fi

echo
echo "Ajustando o max surge do node pool para $MAX_SURGE..."
az aks nodepool update \
  --resource-group "$RG" \
  --cluster-name "$CLUSTER" \
  --name "$POOL" \
  --max-surge "$MAX_SURGE" \
  --output none

echo "Disparando o upgrade somente da imagem de nó..."
az aks nodepool upgrade \
  --resource-group "$RG" \
  --cluster-name "$CLUSTER" \
  --name "$POOL" \
  --node-image-only \
  --no-wait

INICIO=$(date +%s)
while true; do
  ESTADO=$(consulta_pool provisioningState)
  IMAGEM=$(consulta_pool nodeImageVersion)
  DECORRIDO=$(( ($(date +%s) - INICIO) / 60 ))
  echo "$(date '+%H:%M:%S') | estado: $ESTADO | imagem: $IMAGEM | ${DECORRIDO} min"

  if [[ "$ESTADO" == "Succeeded" && "$IMAGEM" == "$DISPONIVEL" ]]; then
    echo
    echo "Upgrade concluído. Node pool '$POOL' em $IMAGEM."
    exit 0
  fi

  if [[ "$ESTADO" == "Failed" || "$ESTADO" == "Canceled" ]]; then
    echo
    echo "O upgrade terminou em '$ESTADO'. Veja o Activity Log do cluster e os eventos com 'kubectl get events'." >&2
    exit 1
  fi

  if [[ "$DECORRIDO" -ge "$LIMITE_MINUTOS" ]]; then
    echo
    echo "Passei de $LIMITE_MINUTOS minutos acompanhando. A operação continua no Azure, confira o estado manualmente." >&2
    exit 1
  fi

  sleep "$INTERVALO"
done
