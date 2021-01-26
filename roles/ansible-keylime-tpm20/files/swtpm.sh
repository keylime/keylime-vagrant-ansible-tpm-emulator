#!/usr/bin/env bash

modprobe tpm_vtpm_proxy

TPMDIR=$(mktemp -d)

swtpm_setup --tpm2 \
    --tpmstate ${TPMDIR} \
    --createek --allow-signing --decryption --create-ek-cert \
    --create-platform-cert \
    --display

swtpm chardev --tpm2 --vtpm-proxy --tpmstate dir=${TPMDIR} -d

export TPM2TOOLS_TCTI="device:/dev/tpm0"
