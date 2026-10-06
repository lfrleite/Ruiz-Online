#!/usr/bin/env bash
# 04-limpeza.sh
# Remove a atribuição, a iniciativa, a role da managed identity, os resource groups
# do laboratório e a TAG Departamento da assinatura.
# Pede confirmação antes de apagar qualquer coisa.
set -euo pipefail

INITIATIVE="ini-tags-governanca-lab"
ASSIGNMENTS=("asg-tags-governanca" "asg-tag-ondapatch-vm")
RESOURCE_GROUPS=("rg-tags-legado-wus2-001" "rg-tags-novo-wus2-001" "rg-tags-teste-wus2-001")

if ! SUBSCRIPTION_ID=$(az account show --query id -o tsv 2>/dev/null); then
  echo "Sem sessão ativa. Rode 'az login' e selecione a assinatura de laboratório." >&2
  exit 1
fi
SCOPE="/subscriptions/$SUBSCRIPTION_ID"

echo "Assinatura em uso: $SUBSCRIPTION_ID"
echo "Serão removidos:"
echo "  atribuições: ${ASSIGNMENTS[*]}"
echo "  iniciativa: $INITIATIVE"
echo "  resource groups (com tudo o que estiver dentro): ${RESOURCE_GROUPS[*]}"
echo "  TAG Departamento da assinatura"
read -r -p "Digite SIM para continuar: " CONFIRM
if [[ "$CONFIRM" != "SIM" ]]; then
  echo "Nada foi removido."
  exit 1
fi

for ASSIGNMENT in "${ASSIGNMENTS[@]}"; do
  if az policy assignment show --name "$ASSIGNMENT" --scope "$SCOPE" --output none 2>/dev/null; then
    PRINCIPAL_ID=$(az policy assignment show --name "$ASSIGNMENT" --scope "$SCOPE" \
      --query identity.principalId --output tsv)
    if [[ -n "$PRINCIPAL_ID" ]]; then
      echo "Removendo as roles da managed identity de $ASSIGNMENT..."
      az role assignment delete --assignee "$PRINCIPAL_ID" --scope "$SCOPE" || true
    fi
    echo "Removendo a atribuição $ASSIGNMENT..."
    az policy assignment delete --name "$ASSIGNMENT" --scope "$SCOPE"
  else
    echo "Atribuição $ASSIGNMENT não existe, seguindo."
  fi
done

if az policy set-definition show --name "$INITIATIVE" --output none 2>/dev/null; then
  echo "Removendo a iniciativa $INITIATIVE..."
  az policy set-definition delete --name "$INITIATIVE"
fi

for RG in "${RESOURCE_GROUPS[@]}"; do
  if az group show --name "$RG" --output none 2>/dev/null; then
    echo "Removendo o resource group $RG..."
    az group delete --name "$RG" --yes --no-wait
  fi
done

echo "Removendo a TAG Departamento da assinatura..."
az tag update --resource-id "$SCOPE" --operation Delete --tags Departamento=TI --output none

echo "Limpeza disparada. A exclusão dos resource groups termina em segundo plano."
