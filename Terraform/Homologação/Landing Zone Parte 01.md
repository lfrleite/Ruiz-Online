## Introdução

Se você trabalha com Microsoft Azure, já deve ter ouvido falar em **Landing Zone** — um conjunto de recursos e configurações que define a fundação da sua nuvem: rede, governança, segurança, monitoramento e identidade.

O problema é que muitas vezes essa fundação é criada manualmente e de forma inconsistente, dificultando escalabilidade, automação e governança.

Na **Parte 1**, vamos:

- Criar o **backend de estado** no Azure (Storage Account + container).
- Configurar o Terraform para usar esse backend.
- Provisionar os recursos iniciais (foundation + network).

---

## O que é uma Landing Zone?

A Landing Zone é a base para implantar e operar cargas de trabalho no Azure de forma organizada, segura e escalável.

Componentes comuns:

- **Management Groups** e **Subscriptions**.
- **Rede Hub-Spoke** para isolamento e segurança.
- **Controle de acesso** via RBAC.
- **Monitoramento** e **Logging** centralizados.
- **Políticas** de governança.

> Referência: [Cloud Adoption Framework - Landing Zones](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/)

---

## Estrutura do projeto Terraform

```plaintext
infra-landingzone/
├─ modules/
│  ├─ foundation/
│  └─ network/
├─ envs/
│  └─ prod/
├─ bootstrap/
│  └─ main.tf
└─ versions.tf
```

---

## 1. Bootstrap do backend de estado

Arquivo: `bootstrap/main.tf`

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "resource_group_name" {
  default = "rg-tfstate"
}

variable "location" {
  default = "Brazil South"
}

variable "storage_account_name" {
  default = "tfstatebrsouth001"
}

variable "container_name" {
  default = "tfstate"
}

resource "azurerm_resource_group" "state" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "state" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.state.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  enable_https_traffic_only = true
  allow_blob_public_access  = false
}

resource "azurerm_storage_container" "state" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.state.name
  container_access_type = "private"
}
```

Executar:

```bash
cd bootstrap
terraform init
terraform apply
```

---

## 2. Configurando o backend

Arquivo: `envs/prod/backend.tf`

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "tfstatebrsouth001"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}
```

---

## 3. Módulo Foundation

Arquivo: `modules/foundation/main.tf`

```hcl
variable "location" {
  default = "Brazil South"
}

variable "tags" {
  type = map(string)
}

resource "azurerm_resource_group" "network" {
  name     = "rg-lz-network"
  location = var.location
  tags     = var.tags
}

output "rg_network_name" {
  value = azurerm_resource_group.network.name
}
```

---

## 4. Módulo Network

Arquivo: `modules/network/main.tf`

```hcl
variable "location" {}
variable "resource_group_name" {}
variable "tags" {
  type = map(string)
}

resource "azurerm_virtual_network" "hub" {
  name                = "vnet-hub"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_subnet" "gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.1.0/27"]
}
```

---

## 5. Chamada dos módulos

Arquivo: `envs/prod/main.tf`

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "foundation" {
  source   = "../../modules/foundation"
  location = "Brazil South"
  tags = {
    environment = "prod"
    owner       = "cloud-team"
  }
}

module "network" {
  source              = "../../modules/network"
  location            = "Brazil South"
  resource_group_name = module.foundation.rg_network_name
  tags = {
    environment = "prod"
    owner       = "cloud-team"
  }
}
```

---

## Conclusão

Você criou a fundação da Landing Zone no Azure usando Terraform, com **backend remoto** no Azure Storage.  
Na próxima parte, vamos substituir o Service Principal por **OIDC** e aplicar governança e segurança avançada.

---
