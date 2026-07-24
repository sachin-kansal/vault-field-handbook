path "sys/generate-root/attempt" {
  capabilities = ["create", "update", "read", "sudo"]
}

path "sys/generate-root/update" {
  capabilities = ["create", "update", "read", "sudo"]
}

path "sys/generate-root/attempt/*" {
  capabilities = ["read", "sudo"]
}

path "sys/generate-root/status" {
  capabilities = ["read", "sudo"]
}