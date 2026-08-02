# Cobertura e Saúde do Defender for Endpoint

## Objetivo

Apresentar o último estado conhecido de onboarding, sensor, agente e exposição dos dispositivos.

## Tabelas

`DeviceInfo`.

## Campos retornados

- Dispositivo e sistema
- Onboarding e saúde do sensor
- Versão do cliente
- Grupo, IP público e exposição
- Exposure Level e Asset Value
- Recomendação, causa e solução

## Recomendações, causas e soluções

- Não onboarded: concluir integração.
- Sensor inativo: investigar conectividade e serviço.
- Internet-facing: correlacionar com vulnerabilidades e criticidade.
- Versão ausente ou antiga: revisar atualização do agente.

## Execução

Cole o conteúdo de `query.kql` em **Microsoft Defender portal > Hunting > Advanced Hunting**.

## Limitações

A tabela contém o último registro conhecido; dispositivos inativos podem permanecer no inventário conforme retenção.

## Documentação oficial

https://learn.microsoft.com/defender-xdr/advanced-hunting-deviceinfo-table

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **02/08/2026**
- Evidência: revisão estática do KQL e da documentação oficial.
- Execução em tenant: **não realizada**
