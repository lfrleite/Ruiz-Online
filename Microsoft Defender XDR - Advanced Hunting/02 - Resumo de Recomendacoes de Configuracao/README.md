# Resumo de Recomendações de Configuração

## Objetivo

Consolidar conformidade por configuração, quantidade de dispositivos afetados, risco e remediação.

## Tabelas

`DeviceTvmSecureConfigurationAssessment` e `DeviceTvmSecureConfigurationAssessmentKB`.

## Campos retornados

- Configuração e categoria
- Dispositivos aplicáveis, conformes e não conformes
- Percentual de conformidade
- Exemplos de dispositivos afetados
- Risco, impacto e remediação

## Recomendações, causas e soluções

- Priorizar configurações com maior impacto e maior número de dispositivos não conformes.
- Usar a descrição da KB como causa e solução oficial.
- Validar impacto ao usuário antes da implantação em massa.

## Execução

Cole o conteúdo de `query.kql` em **Microsoft Defender portal > Hunting > Advanced Hunting**.

## Limitações

O percentual é calculado apenas sobre dispositivos aplicáveis retornados pela tabela.

## Documentação oficial

https://learn.microsoft.com/defender-xdr/advanced-hunting-devicetvmsecureconfigurationassessment-table

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **02/08/2026**
- Evidência: revisão estática do KQL e da documentação oficial.
- Execução em tenant: **não realizada**
