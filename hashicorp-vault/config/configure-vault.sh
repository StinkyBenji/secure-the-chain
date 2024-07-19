#!/bin/sh

export VAULT_ADDR=<YOUR VAULT URL>
export VAULT_TOKEN=<YOUR VAULT TOKEN>

echo "enable transit secret engine for cosign ----- "

vault secrets enable transit

vault write -f transit/keys/cosign type="ecdsa-p256"

vault policy write cosign ./cosign.hcl

export COSIGN_TOKEN=$(vault token create -policy=cosign -format=yaml -orphan -ttl=768h | grep -E "client_token" | sed 's/^.*://')
