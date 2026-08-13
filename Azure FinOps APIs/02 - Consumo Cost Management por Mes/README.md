# Consumo Cost Management por Mês

## Objetivo

Documentar a fonte correta para consolidar custos mensais por subscription, serviço, recurso, período e moeda.

## Fontes recomendadas

- Cost Management Query API para consultas agregadas.
- Cost Management Exports para datasets recorrentes.
- Azure CLI ou Azure PowerShell como clientes da API.
- Billing e Consumption APIs quando aplicável ao contrato.

## Campos normalmente necessários

- Período e data de uso
- Subscription e Resource Group
- Resource ID e tipo de recurso
- Serviço, meter e charge type
- Custo real e amortizado
- Moeda
- Benefícios de reserva ou Savings Plan
- Tags e dimensões financeiras disponíveis

## Limitações

Dados de custo e consumo não devem ser tratados como uma consulta do Azure Resource Graph. A disponibilidade e granularidade dependem do escopo de cobrança, contrato, permissões e tempo de processamento do Cost Management.

## Status de validação

- Status: **CLASSIFICADA COMO FONTE EXTERNA AO ARG**
- Data da revisão: **13/08/2026**
- Execução em ambiente de billing: **não realizada**
