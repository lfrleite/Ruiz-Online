#!/usr/bin/env bash
# Prepara o lado Azure do pipeline de Golden Image com GitHub Actions e OIDC.
# Cria a identidade do pipeline, a role customizada, o role assignment e as
# duas federated credentials (uma por environment do GitHub).
#
# Uso:
#   export GH_OWNER="<usuario-ou-organizacao>"
#   export GH_REPO="<repositorio>"
#   export GH_OWNER_ID="<id-numerico-do-owner>"   # só para subject imutável
#   export GH_REPO_ID="<id-numerico-do-repo>"     # só para subject imutável
#   bash setup-oidc-github.sh

set -euo pipefail

RESOURCE_GROUP="rg-aib-lab-wus2-001"
LOCATION="westus2"
PIPELINE_IDENTITY="id-aib-gha-lab-wus2-001"
ROLE_NAME="role-aib-lab-pipeline"
ROLE_FILE="Custom_Role_AIB_Pipeline.json"
ENV_BUILD="aib-build"
ENV_PUBLISH="aib-producao"
ISSUER="https://token.actions.githubusercontent.com"
AUDIENCE="api://AzureADTokenExchange"

: "${GH_OWNER:?Defina GH_OWNER com o usuário ou a organização do GitHub}"
: "${GH_REPO:?Defina GH_REPO com o nome do repositório}"
GH_OWNER_ID="${GH_OWNER_ID:-}"
GH_REPO_ID="${GH_REPO_ID:-}"

if ! az account show >/dev/null 2>&1; then
  echo "ERRO: sem sessão no Azure. Rode 'az login' antes." >&2
  exit 1
fi

if [[ ! -f "$ROLE_FILE" ]]; then
  echo "ERRO: $ROLE_FILE não está na pasta atual." >&2
  exit 1
fi

if ! az group show --name "$RESOURCE_GROUP" >/dev/null 2>&1; then
  echo "ERRO: o Resource Group $RESOURCE_GROUP não existe. Ele vem do laboratório anterior." >&2
  exit 1
fi

SUBSCRIPTION_ID=$(az account show --query id -o tsv)
TENANT_ID=$(az account show --query tenantId -o tsv)
RG_SCOPE="/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}"

# Subject no formato imutável quando os dois IDs foram informados.
if [[ -n "$GH_OWNER_ID" && -n "$GH_REPO_ID" ]]; then
  SUBJECT_PREFIX="repo:${GH_OWNER}@${GH_OWNER_ID}/${GH_REPO}@${GH_REPO_ID}"
elif [[ -z "$GH_OWNER_ID" && -z "$GH_REPO_ID" ]]; then
  SUBJECT_PREFIX="repo:${GH_OWNER}/${GH_REPO}"
else
  echo "ERRO: informe GH_OWNER_ID e GH_REPO_ID juntos, ou nenhum dos dois." >&2
  exit 1
fi

echo "==> Identidade do pipeline: $PIPELINE_IDENTITY"
if ! az identity show --resource-group "$RESOURCE_GROUP" --name "$PIPELINE_IDENTITY" >/dev/null 2>&1; then
  az identity create \
    --resource-group "$RESOURCE_GROUP" \
    --name "$PIPELINE_IDENTITY" \
    --location "$LOCATION" \
    --output none
fi

CLIENT_ID=$(az identity show --resource-group "$RESOURCE_GROUP" --name "$PIPELINE_IDENTITY" --query clientId -o tsv)
PRINCIPAL_ID=$(az identity show --resource-group "$RESOURCE_GROUP" --name "$PIPELINE_IDENTITY" --query principalId -o tsv)

echo "==> Role customizada: $ROLE_NAME"
ROLE_COUNT=$(az role definition list --name "$ROLE_NAME" --query "length(@)" -o tsv)
if [[ "$ROLE_COUNT" == "0" ]]; then
  TMP_ROLE=$(mktemp)
  trap 'rm -f "$TMP_ROLE"' EXIT
  sed "s|<SUBSCRIPTION_ID>|${SUBSCRIPTION_ID}|g" "$ROLE_FILE" > "$TMP_ROLE"
  az role definition create --role-definition "$TMP_ROLE" --output none
  echo "    Role criada. Aguardando 30 segundos pela propagação."
  sleep 30
fi

echo "==> Role assignment no escopo $RESOURCE_GROUP"
az role assignment create \
  --assignee-object-id "$PRINCIPAL_ID" \
  --assignee-principal-type ServicePrincipal \
  --role "$ROLE_NAME" \
  --scope "$RG_SCOPE" \
  --output none

# As credenciais da mesma identidade precisam ser criadas uma de cada vez.
for ENV_NAME in "$ENV_BUILD" "$ENV_PUBLISH"; do
  echo "==> Federated credential: ${SUBJECT_PREFIX}:environment:${ENV_NAME}"
  az identity federated-credential create \
    --name "fic-github-${ENV_NAME}" \
    --identity-name "$PIPELINE_IDENTITY" \
    --resource-group "$RESOURCE_GROUP" \
    --issuer "$ISSUER" \
    --subject "${SUBJECT_PREFIX}:environment:${ENV_NAME}" \
    --audiences "$AUDIENCE" \
    --output none
done

echo
echo "Valores para os secrets do repositório ${GH_OWNER}/${GH_REPO}:"
echo "  AZURE_CLIENT_ID       = $CLIENT_ID"
echo "  AZURE_TENANT_ID       = $TENANT_ID"
echo "  AZURE_SUBSCRIPTION_ID = $SUBSCRIPTION_ID"
