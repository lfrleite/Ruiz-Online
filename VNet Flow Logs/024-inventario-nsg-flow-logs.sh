#!/usr/bin/env bash
# Artigo 024 - Migrando de NSG flow logs para VNet flow logs
# Roda a consulta 024-inventario-nsg-flow-logs.kql no Azure Resource Graph
# e grava o resultado em JSON para servir de fotografia do "antes".
#
# Uso:
#   az login
#   bash 024-inventario-nsg-flow-logs.sh                      # todas as assinaturas que voce enxerga
#   bash 024-inventario-nsg-flow-logs.sh <subId1> <subId2>    # so as assinaturas informadas
#
# O script so le. Ele nao altera nenhum flow log.

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KQL="$DIR/024-inventario-nsg-flow-logs.kql"
SAIDA="inventario-flow-logs-$(date +%Y%m%d-%H%M).json"

if ! command -v az >/dev/null 2>&1; then
  echo "ERRO: Azure CLI nao encontrado. Use o Cloud Shell ou instale o az." >&2
  exit 1
fi

if ! az account show >/dev/null 2>&1; then
  echo "ERRO: sem sessao ativa. Rode 'az login' antes." >&2
  exit 1
fi

if [ ! -f "$KQL" ]; then
  echo "ERRO: arquivo $KQL nao encontrado. Deixe o .kql na mesma pasta do script." >&2
  exit 1
fi

# Remove as linhas de comentario e junta a consulta em uma linha so
QUERY="$(grep -v '^//' "$KQL" | tr '\n' ' ')"

ESCOPO=()
if [ "$#" -gt 0 ]; then
  ESCOPO=(--subscriptions "$@")
fi

echo "Consultando o Resource Graph..."
az graph query -q "$QUERY" --first 1000 ${ESCOPO[@]+"${ESCOPO[@]}"} --output json > "$SAIDA"

echo "Resultado completo gravado em: $SAIDA"
echo "Atencao: --first aceita no maximo 1000 registros por chamada."
echo "Se o seu ambiente tiver mais flow logs que isso, rode por assinatura."
