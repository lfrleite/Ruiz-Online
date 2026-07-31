# Secure Boot, vTPM e Trusted Launch

## Objetivo

Inventariar a configuração de segurança de inicialização das máquinas virtuais, incluindo Security Type, Secure Boot e vTPM.

## Fonte

`Resources`

## Campos retornados

- Subscription e VM
- Sistema operacional e geração Hyper-V
- Security Type
- Secure Boot e vTPM
- Classificação inicial da configuração
- Referência da imagem
- Estado de provisionamento e energia

## Execução

Execute no Azure Resource Graph Explorer, Azure CLI ou Azure PowerShell.

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

O ARG confirma a configuração ARM da VM, mas não comprova qual certificado Secure Boot está instalado dentro do sistema operacional convidado. Essa validação exige coleta no guest OS, Azure Machine Configuration, Run Command ou outra ferramenta equivalente.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **31/07/2026**
- Evidência: revisão estática das propriedades públicas de máquinas virtuais no ARG.
- Execução no tenant: **não realizada**
