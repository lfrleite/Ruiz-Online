#!/usr/bin/env bash
# 03-remediacao.sh
# Reavalia um resource group e cria uma remediation task para cada policy modify
# da iniciativa, limitada a esse resource group.
# Uso: ./03-remediacao.sh <nome-do-resource-group>
set -euo pipefail

RG="${1:-}"
ASSIGNMENT="asg-tags-governanca"
REFERENCE_IDS=("herdar-ambiente-rg" "herdar-centrodecusto-rg" "herdar-departamento-sub")
MAX_CHECKS=40
SLEEP_SECONDS=15

if [[ -z "$RG" ]]; then
  echo "Uso: $0 <nome-do-resource-group>" >&2
  exit 1
fi
if ! SUBSCRIPTION_ID=$(az account show --query id -o tsv 2>/dev/null); then
  echo "Sem sessão ativa. Rode 'az login' e selecione a assinatura de laboratório." >&2
  exit 1
fi
if ! az group show --name "$RG" --output none 2>/dev/null; then
  echo "Resource group não encontrado: $RG" >&2
  exit 1
fi

ASSIGNMENT_ID="/subscriptions/$SUBSCRIPTION_ID/providers/Microsoft.Authorization/policyAssignments/$ASSIGNMENT"
STAMP=$(date +%Y%m%d%H%M)

echo "Reavaliando a conformidade de $RG (pode levar alguns minutos)..."
az policy state trigger-scan --resource-group "$RG"

for REF in "${REFERENCE_IDS[@]}"; do
  NAME="rem-$REF-$STAMP"
  echo "Criando a remediation task $NAME..."
  az policy remediation create \
    --name "$NAME" \
    --resource-group "$RG" \
    --policy-assignment "$ASSIGNMENT_ID" \
    --definition-reference-id "$REF" \
    --output none

  STATE="Running"
  FINISHED="no"
  for ((i = 1; i <= MAX_CHECKS; i++)); do
    STATE=$(az policy remediation show --name "$NAME" --resource-group "$RG" \
      --query provisioningState --output tsv)
    case "$STATE" in
      Succeeded | Complete | Failed | Canceled)
        FINISHED="yes"
        break
        ;;
    esac
    sleep "$SLEEP_SECONDS"
  done
  if [[ "$FINISHED" == "yes" ]]; then
    echo "  $NAME terminou com estado: $STATE"
  else
    echo "  $NAME ainda está em $STATE depois de $((MAX_CHECKS * SLEEP_SECONDS)) segundos." >&2
    echo "  Acompanhe com: az policy remediation show --name $NAME --resource-group $RG" >&2
  fi
  if [[ "$STATE" == "Failed" ]]; then
    echo "  Veja o motivo com: az policy remediation deployment list --name $NAME --resource-group $RG" >&2
  fi
done

echo "Remediation tasks registradas em $RG:"
az policy remediation list --resource-group "$RG" \
  --query "[].{Nome:name, Estado:provisioningState, Policy:policyDefinitionReferenceId}" --output table
