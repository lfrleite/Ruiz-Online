## Introdução

Na [Parte 1](https://github.com/lfrleite/Ruiz-Online/blob/main/Terraform/Homologa%C3%A7%C3%A3o/Landing%20Zone%20Parte%2001.md) criamos a fundação da Landing Zone com Terraform e backend no Azure Storage.

Agora vamos:

- Substituir Service Principal por **OIDC federated credentials**.
- Adicionar **Azure Policy** para governança.
- Integrar **Azure Key Vault** para segredos.
- Criar **Private Endpoints** para serviços PaaS.
- Organizar ambientes (dev/stage/prod).

---

## 1. O que muda com OIDC?

Com OIDC, o GitHub gera tokens temporários em vez de armazenar secrets.  
Vantagens:

- Sem secrets persistentes.
- Tokens expiram rápido.
- Controle por repositório e branch.

> Documentação: [Authenticate to Azure using GitHub OIDC](https://learn.microsoft.com/azure/developer/github/connect-from-azure)

---

## 2. Criando credencial federada no Azure

```bash
az ad app create --display-name "gh-terraform-oidc"

APP_ID=$(az ad app list --display-name "gh-terraform-oidc" --query "[0].appId" -o tsv)
SP_ID=$(az ad sp create --id $APP_ID --query id -o tsv)

az role assignment create   --assignee $SP_ID   --role Contributor   --scope /subscriptions/<SUBSCRIPTION_ID>

az ad app federated-credential create --id $APP_ID   --parameters '{
    "name": "gh-oidc",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:<ORG_NAME>/<REPO_NAME>:ref:refs/heads/main",
    "audiences": ["api://AzureADTokenExchange"]
  }'
```

---

## 3. Adicionando Azure Policy

Estrutura:

```plaintext
infra-landingzone/
├─ modules/
│  ├─ policy/
│  ├─ foundation/
│  └─ network/
├─ envs/
│  ├─ dev/
│  ├─ stage/
│  └─ prod/
```

Arquivo: `modules/policy/main.tf`

```hcl
variable "scope" {}
variable "policy_definitions" {
  type = list(object({
    name         = string
    display_name = string
    policy_type  = string
    mode         = string
    policy_rule  = any
  }))
}

resource "azurerm_policy_definition" "defs" {
  for_each     = { for p in var.policy_definitions : p.name => p }
  name         = each.value.name
  display_name = each.value.display_name
  policy_type  = each.value.policy_type
  mode         = each.value.mode
  policy_rule  = each.value.policy_rule
}

resource "azurerm_policy_assignment" "assign" {
  for_each             = azurerm_policy_definition.defs
  name                 = "assign-${each.value.name}"
  scope                = var.scope
  policy_definition_id = each.value.id
}
```

Exemplo de chamada:

```hcl
module "policy" {
  source = "../../modules/policy"
  scope  = "/subscriptions/${var.subscription_id}"
  policy_definitions = [
    {
      name         = "allowed-locations"
      display_name = "Allowed Locations"
      policy_type  = "Custom"
      mode         = "All"
      policy_rule  = jsondecode(file("${path.module}/allowed-locations.json"))
    }
  ]
}
```

---

## 4. Key Vault para segredos

```hcl
resource "azurerm_key_vault" "main" {
  name                        = "kv-lz-${var.env}"
  location                    = var.location
  resource_group_name         = azurerm_resource_group.network.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  soft_delete_retention_days  = 90
  purge_protection_enabled    = true
  enable_rbac_authorization   = true
  tags                        = var.tags
}
```

---

## 5. Private Endpoints para PaaS

```hcl
resource "azurerm_private_endpoint" "kv" {
  name                = "pe-kv-${var.env}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = azurerm_subnet.private.id

  private_service_connection {
    name                           = "psc-kv"
    private_connection_resource_id = azurerm_key_vault.main.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }
}
```

---

## 6. Múltiplos ambientes

```plaintext
envs/
├─ dev/
│  ├─ backend.tf
│  └─ main.tf
├─ stage/
│  ├─ backend.tf
│  └─ main.tf
└─ prod/
   ├─ backend.tf
   └─ main.tf
```

Cada ambiente com backend separado:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "tfstatebrsouth001"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
  }
}
```

---

## Conclusão

Agora sua Landing Zone:

- Não depende de secrets no pipeline.
- Tem governança com Azure Policy.
- Segredos protegidos no Key Vault.
- Serviços PaaS isolados com Private Endpoints.
- Ambientes separados e isolados.

Com essa base, você pode crescer no Azure com segurança e organização.

---
