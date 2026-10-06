#!/usr/bin/env bash
# 02-upgrade-trusted-launch.sh
# Converte uma VM existente para Trusted Launch: confere geração e tamanho,
# cria um restore point, desaloca, troca o Security type, liga e valida.
# Uso: ./02-upgrade-trusted-launch.sh -g <resource-group> -n <vm> [--sem-secure-boot] [--gen1-preparada] [--yes]

set -euo pipefail

RG=""
VM=""
SECURE_BOOT="true"
GEN1_PREPARADA="false"
CONFIRMADO="false"

uso() {
  echo "Uso: $0 -g <resource-group> -n <vm> [--sem-secure-boot] [--gen1-preparada] [--yes]"
}

erro() { echo "ERRO: $*" >&2; exit 1; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    -g|--resource-group) RG="${2:-}"; shift 2 ;;
    -n|--name) VM="${2:-}"; shift 2 ;;
    --sem-secure-boot) SECURE_BOOT="false"; shift ;;
    --gen1-preparada) GEN1_PREPARADA="true"; shift ;;
    -y|--yes) CONFIRMADO="true"; shift ;;
    -h|--help) uso; exit 0 ;;
    *) uso; erro "Parâmetro desconhecido: $1" ;;
  esac
done

if [[ -z "$RG" || -z "$VM" ]]; then
  uso
  exit 1
fi

trap 'echo "Falha na linha $LINENO. A VM pode ter ficado desalocada: confira com az vm get-instance-view e ligue com az vm start se for o caso." >&2' ERR

command -v az >/dev/null || erro "Azure CLI não encontrado."
az account show >/dev/null 2>&1 || erro "Sessão não autenticada. Rode az login antes."

echo "[1/6] Lendo a configuração atual de $VM"
VM_ID=$(az vm show -g "$RG" -n "$VM" --query id -o tsv)
LOCATION=$(az vm show -g "$RG" -n "$VM" --query location -o tsv)
SIZE=$(az vm show -g "$RG" -n "$VM" --query hardwareProfile.vmSize -o tsv)
SEC_TYPE=$(az vm show -g "$RG" -n "$VM" --query securityProfile.securityType -o tsv)
OS_DISK_ID=$(az vm show -g "$RG" -n "$VM" --query storageProfile.osDisk.managedDisk.id -o tsv)

if [[ -z "$OS_DISK_ID" ]]; then
  erro "A VM não usa disco gerenciado no S.O. Este script não cobre esse caso."
fi

GERACAO=$(az disk show --ids "$OS_DISK_ID" --query hyperVGeneration -o tsv)
echo "      Tamanho: $SIZE | Geração do disco: ${GERACAO:-desconhecida} | Security type: ${SEC_TYPE:-Standard}"

case "$SEC_TYPE" in
  TrustedLaunch) echo "A VM já está em Trusted Launch. Nada a fazer."; exit 0 ;;
  ConfidentialVM) erro "Confidential VM não entra neste procedimento." ;;
esac

if [[ "$GERACAO" != "V2" && "$GEN1_PREPARADA" != "true" ]]; then
  erro "O disco de S.O. não está marcado como Geração 2 (valor lido: '${GERACAO:-vazio}'). Se a VM é Gen1, faça o snapshot, prepare o disco dentro do S.O. (MBR2GPT no Windows, validação de GPT e EFI no Linux) e rode de novo com --gen1-preparada."
fi

echo "[2/6] Conferindo se $SIZE aceita Geração 2 e Trusted Launch em $LOCATION"
CAPS=$(az vm list-skus --resource-type virtualMachines --location "$LOCATION" \
  --query "[?name=='$SIZE'].capabilities[] | [?name=='HyperVGenerations' || name=='TrustedLaunchDisabled'].[name, value]" -o tsv)

if [[ -z "$CAPS" ]]; then
  erro "Não encontrei o tamanho $SIZE em $LOCATION."
fi
if ! grep -q "HyperVGenerations.*V2" <<<"$CAPS"; then
  erro "O tamanho $SIZE não suporta Geração 2. Troque o tamanho antes."
fi
if grep -qi "TrustedLaunchDisabled.*true" <<<"$CAPS"; then
  erro "O tamanho $SIZE está marcado com TrustedLaunchDisabled. Troque o tamanho antes."
fi

if [[ "$CONFIRMADO" != "true" ]]; then
  echo
  echo "A VM $VM será DESALOCADA (fica indisponível) e convertida para Trusted Launch."
  if [[ "$GERACAO" != "V2" ]]; then
    echo "Ela é Gen1: depois da conversão não existe volta para Gen1."
  fi
  read -r -p "Digite o nome da VM para confirmar: " RESPOSTA
  if [[ "$RESPOSTA" != "$VM" ]]; then
    erro "Confirmação não confere. Nada foi alterado."
  fi
fi

echo "[3/6] Criando restore point da VM"
RPC="rpc-$VM"
RP="rp-pre-tl-$(date +%Y%m%d%H%M)"
az restore-point collection create -g "$RG" --collection-name "$RPC" \
  --location "$LOCATION" --source-id "$VM_ID" -o none
az restore-point create -g "$RG" --collection-name "$RPC" --name "$RP" -o none
echo "      Restore point $RP criado na coleção $RPC"

echo "[4/6] Desalocando a VM"
az vm deallocate -g "$RG" -n "$VM" -o none

echo "[5/6] Trocando o Security type para TrustedLaunch (Secure Boot: $SECURE_BOOT, vTPM: true)"
az vm update -g "$RG" -n "$VM" \
  --security-type TrustedLaunch \
  --enable-secure-boot "$SECURE_BOOT" --enable-vtpm true -o none

echo "[6/6] Ligando e validando"
az vm start -g "$RG" -n "$VM" -o none

SEC_FINAL=$(az vm show -g "$RG" -n "$VM" --query securityProfile.securityType -o tsv)
az vm show -g "$RG" -n "$VM" \
  --query "{VM:name, SecurityType:securityProfile.securityType, SecureBoot:securityProfile.uefiSettings.secureBootEnabled, vTPM:securityProfile.uefiSettings.vTpmEnabled}" -o table

if [[ "$SEC_FINAL" != "TrustedLaunch" ]]; then
  erro "O Security type ficou como '${SEC_FINAL:-Standard}'. Revise o Activity Log da VM."
fi

echo "Concluído. Agora entre na VM por RDP ou SSH e confirme que o S.O. subiu normalmente."
