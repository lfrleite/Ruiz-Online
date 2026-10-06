# Default Outbound Access

Arquivos do artigo [O fim do default outbound access: saída explícita para as VMs no Azure](https://blog.ruizsolutions.online/posts/azure-default-outbound-access-saida-explicita/).

| Arquivo | Para que serve |
| --- | --- |
| `subnets-nao-privadas.kql` | Consulta de Resource Graph que lista as subnets que ainda não são privadas, com NAT Gateway, route table e delegações de cada uma |
| `nics-saida-implicita.kql` | Consulta de Resource Graph que lista as NICs com `defaultOutboundConnectivityEnabled` igual a `true` |
| `inventario-saida-implicita.sh` | Executa as duas consultas com `az graph query`, pagina o resultado e grava um CSV para cada uma |

## Como usar

Os três arquivos precisam estar na mesma pasta.

```bash
az login
bash inventario-saida-implicita.sh -o ./inventario
```

Parâmetros opcionais: `-s <subscriptionId>` para uma assinatura e `-m <managementGroupId>` para um management group. Sem escopo, o Resource Graph consulta todas as assinaturas a que a sua conta tem acesso.

O script usa login interativo, exige `jq` e permissão de **Reader** no escopo. Ele só lê: nenhum recurso é alterado e nenhum segredo fica em texto.

As duas consultas também podem ser coladas direto no Resource Graph Explorer do Portal.
