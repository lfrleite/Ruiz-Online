#!/usr/bin/env bash
# Mostra, lado a lado, como o nome da Storage Account resolve e o que o blob
# responde de FORA (este terminal) e de DENTRO (a VM de teste, via SSH).
# Uso: ./teste-dentro-fora.sh [IP_DE_UM_SERVIDOR_DNS]
# Com o IP opcional, a consulta de dentro da VM é feita direto nesse servidor.
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/00-variaveis.sh" || exit 1

SERVIDOR_DNS="${1:-}"
if [ -n "$SERVIDOR_DNS" ] && ! [[ "$SERVIDOR_DNS" =~ ^[0-9]{1,3}(\.[0-9]{1,3}){3}$ ]]; then
  echo "ERRO: '$SERVIDOR_DNS' não é um endereço IPv4. Uso: $0 [IP_DE_UM_SERVIDOR_DNS]" >&2
  exit 1
fi

if [ ! -s "$ARQ_SAS" ]; then
  echo "ERRO: não achei $ARQ_SAS. Rode o 02-storage.sh antes." >&2
  exit 1
fi
SAS_URL="$(cat "$ARQ_SAS")"

VM_IP="$(az vm show --show-details --resource-group "$RG" --name "$VM" --query publicIps --output tsv)"
if [ -z "$VM_IP" ]; then
  echo "ERRO: não consegui o IP público da VM $VM. Ela está ligada?" >&2
  exit 1
fi

echo "================ DE FORA (este terminal) ================"
nslookup "$FQDN" || echo "(nslookup falhou)"
echo "HTTP do blob: $(curl -s -o /dev/null -w '%{http_code}' --max-time 20 "$SAS_URL")"

echo
echo "================ DE DENTRO (VM $VM) ================"
ssh -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 "azureuser@$VM_IP" \
  "nslookup '$FQDN' $SERVIDOR_DNS || echo '(nslookup falhou)'; \
   echo \"HTTP do blob: \$(curl -s -o /dev/null -w '%{http_code}' --max-time 20 '$SAS_URL')\""
