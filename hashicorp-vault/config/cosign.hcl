path "transit/keys/cosign" {
  capabilities = ["read"]
}

path "transit/hmac/cosign/*" {
  capabilities = ["update"]
}

path "transit/sign/cosign/*" {
  capabilities = ["update"]
}

path "transit/verify/cosign" {
  capabilities = ["create"]
}

path "transit/verify/cosign/*" {
  capabilities = ["update"]
}