ui = true

mlock = true

default_lease_ttl = "768h"

log_level= "error"
log_file= "/srv/vault/log/vault.log"

storage "file" {
  path = "/srv/vault/data"
}


#HTTP listener
listener "tcp" {
  address = "192.168.31.50:8200"
  tls_disable = 1
}

#HTTPS listener
listener "tcp" {
  address       = "192.168.31.50:8201"
  tls_cert_file = "/opt/vault/tls/tls.crt"
  tls_key_file  = "/opt/vault/tls/tls.key"
}

seal "gcpckms" {
  project     = "k8s-data-practice"
  region      = "asia-south2"
  key_ring    = "vault"
  crypto_key  = "vault-auto-unseal"
  credentials = "/srv/vault/key.json"
}
