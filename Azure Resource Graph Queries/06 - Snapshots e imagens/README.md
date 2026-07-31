# Snapshots e Imagens

## Objetivo

Inventariar snapshots, imagens gerenciadas e artefatos do Azure Compute Gallery, incluindo origem, sistema operacional, armazenamento, replicação, segurança e datas disponíveis.

## Fonte

- `Resources`
- `ResourceContainers`, utilizada para obter o nome da subscription

## Recursos contemplados

- Snapshots
- Imagens gerenciadas
- Azure Compute Galleries
- Definições de imagem
- Versões de imagem

## Principais campos retornados

- Subscription, Resource Group, nome, tipo e localização
- Galeria, definição e versão da imagem
- Estado de provisionamento e classificação do artefato
- Datas de criação, publicação e End of Life quando disponíveis
- Idade estimada
- Sistema operacional, geração Hyper-V e arquitetura
- Tamanho de discos e discos de dados
- Origem do snapshot ou imagem
- Criptografia e políticas de acesso de rede
- Perfil de publicação, regiões de destino e replicação
- Tags e Resource ID

## Execução

Execute o arquivo `query.kql` no Azure Resource Graph Explorer, Azure CLI com `az graph query` ou Azure PowerShell com `Search-AzGraph`.

### Filtro opcional por subscription

O arquivo `query.kql` contém o bloco abaixo comentado no topo. Para ativá-lo, remova `//` e mantenha o filtro imediatamente após a linha `Resources`:

```kusto
// Para filtrar por subscriptions, insira após a linha "Resources":
// | where subscriptionId in (
//     'SUBSCRIPTION-ID-1',
//     'SUBSCRIPTION-ID-2'
// )
```

## Limitações

- As propriedades variam entre snapshots, imagens gerenciadas, galerias, definições e versões.
- Datas e `systemData` podem estar vazios ou apresentar comportamentos diferentes conforme o tipo de recurso.
- A idade calculada depende da disponibilidade de `properties.timeCreated`.
- A consulta não confirma utilização real, dependências de deploy ou autorização para exclusão.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **31/07/2026**
- Evidência: revisão estática dos tipos de recurso e grupos de propriedades projetados.
- Execução no tenant: **não realizada**
