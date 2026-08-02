# Configurações de Segurança Não Conformes

## Objetivo

Detalhar configurações de segurança aplicáveis e não conformes por dispositivo, incluindo risco, impacto, remediação e benchmarks.

## Tabelas

`DeviceTvmSecureConfigurationAssessment` e `DeviceTvmSecureConfigurationAssessmentKB`.

## Campos retornados

- Dispositivo e sistema operacional
- Configuração, categoria e subcategoria
- Descrição e risco
- Impacto e possível impacto ao usuário
- Remediação, benchmarks e MITRE

## Recomendações, causas e soluções

- Usar `RiskDescription` como causa técnica.
- Usar `RemediationOptions` como solução recomendada.
- Priorizar por impacto, exposição e quantidade de dispositivos afetados.

## Execução

Cole o conteúdo de `query.kql` em **Microsoft Defender portal > Hunting > Advanced Hunting**.

## Limitações

Requer Microsoft Defender for Endpoint e dados de Vulnerability Management. Algumas colunas podem depender do licenciamento.

## Documentação oficial

https://learn.microsoft.com/defender-xdr/advanced-hunting-devicetvmsecureconfigurationassessment-table
- KB: https://learn.microsoft.com/defender-xdr/advanced-hunting-devicetvmsecureconfigurationassessmentkb-table

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **02/08/2026**
- Evidência: revisão estática do KQL e da documentação oficial.
- Execução em tenant: **não realizada**
