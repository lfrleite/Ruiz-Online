#!/usr/bin/env bash
# 02-iniciativa-e-atribuicao.sh
# Cria a iniciativa de TAGs com cinco policies built-in e atribui na assinatura
# com enforcement desligado (DoNotEnforce) e managed identity do sistema.
# Precisa do arquivo iniciativa-tags-definitions.json na mesma pasta.
set -euo pipefail

LOCATION="westus2"
INITIATIVE="ini-tags-governanca-lab"
ASSIGNMENT="asg-tags-governanca"
DEFINITIONS_FILE="$(dirname "$0")/iniciativa-tags-definitions.json"

if ! SUBSCRIPTION_ID=$(az account show --query id -o tsv 2>/dev/null); then
  echo "Sem sessão ativa. Rode 'az login' e selecione a assinatura de laboratório." >&2
  exit 1
fi
if [[ ! -f "$DEFINITIONS_FILE" ]]; then
  echo "Arquivo não encontrado: $DEFINITIONS_FILE" >&2
  exit 1
fi

SCOPE="/subscriptions/$SUBSCRIPTION_ID"
INITIATIVE_ID="$SCOPE/providers/Microsoft.Authorization/policySetDefinitions/$INITIATIVE"

echo "Criando a iniciativa $INITIATIVE..."
az policy set-definition create \
  --name "$INITIATIVE" \
  --display-name "Governanca de TAGs (lab)" \
  --description "Exige Ambiente e CentroDeCusto no resource group e faz os recursos herdarem as TAGs do resource group e da assinatura." \
  --metadata '{"category":"Tags"}' \
  --definitions "$(cat "$DEFINITIONS_FILE")" \
  --output none

echo "Atribuindo a iniciativa em $SCOPE com enforcement DoNotEnforce..."
az policy assignment create \
  --name "$ASSIGNMENT" \
  --display-name "Governanca de TAGs (lab)" \
  --scope "$SCOPE" \
  --policy-set-definition "$INITIATIVE_ID" \
  --enforcement-mode DoNotEnforce \
  --mi-system-assigned \
  --location "$LOCATION" \
  --role Contributor \
  --identity-scope "$SCOPE" \
  --output none

PRINCIPAL_ID=$(az policy assignment show --name "$ASSIGNMENT" --scope "$SCOPE" \
  --query identity.principalId --output tsv)
if [[ -z "$PRINCIPAL_ID" ]]; then
  echo "A atribuição foi criada sem managed identity. Confira antes de continuar." >&2
  exit 1
fi

echo "Managed identity da atribuição (principalId): $PRINCIPAL_ID"
echo "Roles da identidade:"
az role assignment list --assignee "$PRINCIPAL_ID" --all --output table
