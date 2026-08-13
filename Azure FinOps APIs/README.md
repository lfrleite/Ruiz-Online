# Azure FinOps APIs

Biblioteca de referências e coletas FinOps que dependem de APIs de Billing, Cost Management, Reservations ou Consumption e não devem ser forçadas para o Azure Resource Graph.

## Regras

- Não tratar custo, utilização ou benefício financeiro como dados nativos do Azure Resource Graph.
- Não publicar IDs reais de billing accounts, subscriptions, reservations ou tenants.
- Preferir APIs oficiais, Cost Management Exports, Azure CLI ou Azure PowerShell.
- Documentar permissões e limitações de cada fonte.
- Não classificar uma coleta como testada sem evidência real de execução.

## Catálogo

| Nº | Coleta | Fonte principal |
|---:|---|---|
| 01 | Reservas Azure e Utilização | Reservations + Cost Management/Consumption APIs |
| 02 | Consumo Cost Management por Mês | Cost Management API / Exports |
