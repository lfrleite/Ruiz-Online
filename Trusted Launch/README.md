# Trusted Launch em VMs existentes

Arquivos de apoio do artigo [Trusted Launch em VMs existentes no Azure](https://blog.ruizsolutions.online/posts/azure-trusted-launch-vms-existentes/).

| Arquivo | Para que serve |
| --- | --- |
| `01-lab-trusted-launch.sh` | Cria o laboratório: duas VMs Gen2 com Security type Standard e uma VM Gen1 |
| `inventario-trusted-launch.kql` | Consulta Resource Graph que classifica cada VM em Trusted Launch, Gen2 Standard ou Gen1 |
| `resumo-trusted-launch.kql` | A mesma classificação, resumida em contagem por situação |
| `02-upgrade-trusted-launch.sh` | Confere geração e tamanho, pede confirmação, cria restore point, desaloca, converte para Trusted Launch, liga e valida |

## Uso

```bash
chmod +x 01-lab-trusted-launch.sh 02-upgrade-trusted-launch.sh

./01-lab-trusted-launch.sh

az graph query -q "$(cat inventario-trusted-launch.kql)" -o table

./02-upgrade-trusted-launch.sh -g rg-tl-lab-wus2-001 -n vm-tllnxg2-001
```

Parâmetros do script de upgrade:

- `--sem-secure-boot`: converte com vTPM ligado e Secure Boot desligado.
- `--gen1-preparada`: libera a execução em VM Gen1. Use só depois do snapshot e da conversão do disco dentro do S.O.
- `--yes`: não pede a confirmação com o nome da VM antes de desalocar. Para execução em lote.

## Requisitos

- Azure CLI 2.86.0 ou superior, com sessão autenticada (`az login`).
- Extensão `resource-graph` do Azure CLI para o `az graph query`.
- Nenhuma senha ou segredo fica gravado nos arquivos. A senha das VMs Windows é pedida no terminal.

## Limpeza

```bash
az group delete --name rg-tl-lab-wus2-001 --yes --no-wait
```
