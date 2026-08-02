# Microsoft Graph Queries

Biblioteca pública de coletas para identidade, segurança, Intune e Microsoft 365.

## Regras

- Não publicar tenants, e-mails, UPNs, dispositivos, serial numbers, IDs ou resultados reais.
- Utilizar permissões mínimas e autenticação delegada somente quando apropriado.
- Manter cada coleta em uma pasta com `query.ps1` e `README.md`.
- Marcar endpoints beta explicitamente.
- Não classificar uma coleta como testada sem evidência real de execução.
- Exportar resultados apenas para a pasta local `output`, ignorada ou removida antes de qualquer commit.

## Dependências

```powershell
Install-Module Microsoft.Graph.Authentication -Scope CurrentUser
```

Os scripts utilizam `Invoke-MgGraphRequest` para preservar os endpoints oficiais e controlar paginação.

## Catálogo

| Nº | Coleta | Arquivos |
|---:|---|---|
| 01 | Visao Geral do Tenant | `query.ps1` + `README.md` |
| 02 | Licencas e Service Plans | `query.ps1` + `README.md` |
| 03 | Microsoft Secure Score Atual e Historico | `query.ps1` + `README.md` |
| 04 | Controles do Microsoft Secure Score | `query.ps1` + `README.md` |
| 05 | Identity Secure Score e Recomendacoes | `query.ps1` + `README.md` |
| 06 | Recursos Impactados por Recomendacoes do Entra | `query.ps1` + `README.md` |
| 07 | Funcoes Privilegiadas e PIM | `query.ps1` + `README.md` |
| 08 | Politicas de Acesso Condicional | `query.ps1` + `README.md` |
| 09 | MFA SSPR e Metodos de Autenticacao | `query.ps1` + `README.md` |
| 10 | Identity Protection Usuarios e Deteccoes de Risco | `query.ps1` + `README.md` |
| 11 | Governanca de Grupos | `query.ps1` + `README.md` |
| 12 | Entra Connect Sync | `query.ps1` + `README.md` |
| 13 | Branding e Dominios | `query.ps1` + `README.md` |
| 14 | Inventario de Dispositivos Intune | `query.ps1` + `README.md` |
| 15 | Compliance do Intune por Configuracao | `query.ps1` + `README.md` |
| 16 | Saude dos Conectores do Intune | `query.ps1` + `README.md` |
| 17 | Falhas de Aplicativos e Enrollment do Intune | `query.ps1` + `README.md` |
| 18 | Uso do SharePoint Online | `query.ps1` + `README.md` |
| 19 | Uso do OneDrive | `query.ps1` + `README.md` |
| 20 | Service Health do Microsoft 365 | `query.ps1` + `README.md` |

## Status

Todos os scripts foram classificados como **REVISADOS ESTRUTURALMENTE** e não foram executados em tenant.
