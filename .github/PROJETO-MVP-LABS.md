# Projeto MVP — laboratórios e scripts de apoio

> **Atualizado em:** 15/11/2026. Planejamento e auditoria, não comprovante de execução.  
> **Fonte de verdade do acompanhamento:** [Projeto MVP no blog](https://github.com/lfrleite/lfrleite.github.io/blob/main/.github/PROJETO-MVP.md).  
> **Issue deste repositório:** [#5 — validar scripts de apoio](https://github.com/lfrleite/Ruiz-Online/issues/5).

## Regras

1. Os códigos precisam corresponder aos procedimentos efetivamente executados em laboratório pessoal antes da publicação de um artigo.
2. Separar comandos de **leitura**, **provisionamento**, **alteração** e **exclusão**; scripts destrutivos exigem escopo explícito e validação.
3. Não publicar dados sensíveis, hostnames, IDs de assinaturas, resultados reais de clientes, credenciais nem screenshots corporativos.
4. Não afirmar que código, imagens ou serviços foram testados sem logs e evidência reproduzível.
5. Referenciar versão/commit dos scripts ao publicar. Não alterar códigos existentes até a etapa de validação.

## Frentes e diretórios existentes

| Prioridade | Frente | Artefatos do repositório | Issue do blog |
| --- | --- | --- | --- |
| P0 | Azure VM Image Builder | [Azure Image Builder](../Azure%20Image%20Builder/) | [#1](https://github.com/lfrleite/lfrleite.github.io/issues/1) |
| P1 | Resource Graph | [Azure Resource Graph](../Azure%20Resource%20Graph/) · [Queries](../Azure%20Resource%20Graph%20Queries/) | [#2](https://github.com/lfrleite/lfrleite.github.io/issues/2) |
| P1 | Update Manager | [Azure Update Manager](../Azure%20Update%20Manager/) · [Pre Event Snapshot](../Azure%20Update%20Manager%20-%20Pre%20Event%20Snapshot/) | [#3](https://github.com/lfrleite/lfrleite.github.io/issues/3) |
| P1 | Start/Stop e órfãos | [Start Stop VMs v2](../Start%20Stop%20VMs%20v2/) · [Recursos Orfaos](../Recursos%20Orfaos/) | [#4](https://github.com/lfrleite/lfrleite.github.io/issues/4) |
| P1 | Azure Policy e redes | [Policy - Tags](../Azure%20Policy%20-%20Tags/) · [Private Endpoint DNS](../Private%20Endpoint%20DNS/) · [Default Outbound Access](../Default%20Outbound%20Access/) · [VNet Flow Logs](../VNet%20Flow%20Logs/) | [#5](https://github.com/lfrleite/lfrleite.github.io/issues/5) |
| P2 | Pipelines e Gallery | [AIB GitHub Actions](../Azure%20Image%20Builder%20-%20GitHub%20Actions/) · [Compute Gallery](../Azure%20Compute%20Gallery/) | [#6](https://github.com/lfrleite/lfrleite.github.io/issues/6) |
| P2 | Especializados | [Trusted Launch](../Trusted%20Launch/) · [AKS Upgrades](../AKS%20Upgrades/) | [#7](https://github.com/lfrleite/lfrleite.github.io/issues/7) |

## AIB — estado observado e próximo passo

Infraestrutura de rede, NAT, identidade e quatro definições de imagem presentes. Nenhum Image Template, Image Version ou VM de teste observado. **RBAC não confirmado** porque o comando inicial gerou erro de sintaxe de parâmetros. Validar a custom role e role assignments primeiro; depois executar o primeiro template Ubuntu 24.04 e registrar logs, versão da galeria, VM e evidências.

### Checklist de validação por script

- [ ] Parâmetros e placeholders conferidos
- [ ] Comando e dependências compatíveis com a documentação atual
- [ ] Execução autorizada em ambiente de laboratório, com saída e códigos de erro
- [ ] Casos de falha/limitações documentados
- [ ] Nenhum segredo ou dado sensível em logs ou em commits
- [ ] Referência cruzada para Issue e artigo do blog
- [ ] Limpeza de recursos temporários revisada

Este documento não altera, valida nem substitui qualquer script de laboratório.
