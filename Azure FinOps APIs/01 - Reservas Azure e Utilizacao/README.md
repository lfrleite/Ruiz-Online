# Reservas Azure e Utilização

## Objetivo

Documentar a fonte correta para consultar reservas, utilização, aquisição, escopo, prazo e vencimento no Azure.

## Fontes recomendadas

- Reservations API para inventário e detalhes das reservas.
- Cost Management e Consumption APIs para utilização e benefícios.
- Azure CLI ou Azure PowerShell como clientes das APIs.

## Campos normalmente necessários

- Reservation Order e Reservation ID
- Produto, SKU, região e quantidade
- Escopo e modelo de compartilhamento
- Data de compra, início e expiração
- Estado da reserva
- Utilização e percentual de benefício
- Subscription ou grupo de gerenciamento associado

## Limitações

Essas informações não são suportadas integralmente pelo Azure Resource Graph. A disponibilidade depende do modelo de cobrança e das permissões de Billing e Cost Management.

## Status de validação

- Status: **CLASSIFICADA COMO FONTE EXTERNA AO ARG**
- Data da revisão: **13/08/2026**
- Execução em ambiente de billing: **não realizada**
