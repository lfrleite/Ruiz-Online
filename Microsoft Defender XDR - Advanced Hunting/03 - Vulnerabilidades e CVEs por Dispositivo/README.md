# Vulnerabilidades e CVEs por Dispositivo

## Objetivo

Relacionar vulnerabilidades de software por dispositivo com CVSS, exploit, zero-day, atualização recomendada e descrição.

## Tabelas

`DeviceTvmSoftwareVulnerabilities` e `DeviceTvmSoftwareVulnerabilitiesKB`.

## Campos retornados

- Dispositivo, software e versão
- CVE e severidade
- CVSS, exploit e zero-day
- Atualização recomendada
- Causa, solução e prioridade

## Recomendações, causas e soluções

- Zero-day ou exploit disponível: priorizar investigação e mitigação.
- Aplicar atualização recomendada quando compatível.
- Quando não houver atualização, avaliar mitigação, isolamento ou remoção do software.

## Execução

Cole o conteúdo de `query.kql` em **Microsoft Defender portal > Hunting > Advanced Hunting**.

## Limitações

Requer Defender Vulnerability Management. A presença de CVE não autoriza atualização automática sem teste e janela.

## Documentação oficial

https://learn.microsoft.com/defender-xdr/advanced-hunting-devicetvmsoftwarevulnerabilities-table
- KB: https://learn.microsoft.com/defender-xdr/advanced-hunting-devicetvmsoftwarevulnerabilitieskb-table

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **02/08/2026**
- Evidência: revisão estática do KQL e da documentação oficial.
- Execução em tenant: **não realizada**
