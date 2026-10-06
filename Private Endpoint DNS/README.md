# Private Endpoint e DNS privado

Arquivos do laboratório do artigo [Private Endpoint e DNS privado no Azure sem dor de cabeça](https://blog.ruizsolutions.online/posts/azure-private-endpoint-dns-privado/).

Tudo roda em Bash, no Cloud Shell ou em qualquer terminal com Azure CLI logado. Nenhum script guarda senha, chave de conta ou segredo: o acesso ao blob usa Microsoft Entra ID e uma user delegation SAS de leitura com 24 horas de validade.

| Arquivo | Para que serve |
| --- | --- |
| `00-variaveis.sh` | Nomes dos recursos do laboratório. Os outros scripts carregam sozinhos. |
| `01-rede-e-vm.sh` | Resource Group, VNet, subnets, NSG e a VM de teste. Recebe como parâmetro o IPv4 público de onde o SSH vai sair. |
| `02-storage.sh` | Storage Account, container, blob de teste e a URL com SAS. |
| `03-private-endpoint.sh` | Private Endpoint do blob sem integração de DNS (alternativa ao portal). |
| `04-dns-privado.sh` | Zona `privatelink.blob.core.windows.net`, link com a VNet e DNS zone group. |
| `05-private-resolver.sh` | Azure DNS Private Resolver com inbound endpoint. |
| `06-policy-zone-group.sh` | Atribuição da policy built-in que cria o zone group sozinha. |
| `teste-dentro-fora.sh` | Resolução de nome e resposta do blob, de fora e de dentro da VNet. |
| `diagnostico-pe-dns.sh` | Diagnóstico somente leitura para qualquer Private Endpoint. |

Ordem de execução e explicação de cada passo estão no artigo.

O laboratório gera custo enquanto existir. Ao terminar:

```bash
source ./00-variaveis.sh
RG_ID="$(az group show --name "$RG" --query id --output tsv)"
az policy assignment delete --name "$ATRIBUICAO" --scope "$RG_ID"
az group delete --name "$RG" --yes --no-wait
rm -f "$ARQ_SAS"
```
