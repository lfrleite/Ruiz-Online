# Azure Update Manager - Pre Event Snapshot

Arquivos do artigo [Snapshot automático antes do patch com o pre-event do Azure Update Manager](https://blog.ruizsolutions.online/posts/azure-update-manager-snapshot-pre-evento/).

| Arquivo | Para que serve |
| --- | --- |
| `Invoke-AumPreEventSnapshot.ps1` | Runbook PowerShell 7.4 do pre-event. Lê o evento, acha as VMs da execução no Resource Graph e cria snapshot incremental de cada disco com TAGs de rastreio. Cancela a execução se algum snapshot falhar, se nenhuma VM for encontrada ou se o tempo acabar. |
| `Invoke-AumPostEventCleanup.ps1` | Runbook PowerShell 7.4 do post-event. Lista ou apaga os snapshots vencidos criados pelo runbook de pre-event. |
| `role-aum-cancel-maintenance-run.json` | Custom role (formato do `az role definition create`) com a permissão de cancelar a execução da janela. |
| `webhookdata-teste.json` | Valor de exemplo para o parâmetro `WebhookData` no Test pane. |
| `vms-da-execucao.kql` | Consulta Resource Graph com as VMs de uma execução. |
| `snapshots-do-pre-event.kql` | Consulta Resource Graph com os snapshots criados pelo runbook. |

Os runbooks autenticam com a Managed Identity do Automation Account. Nenhum arquivo aqui guarda credencial, e a URL do webhook não deve ser gravada em repositório.
