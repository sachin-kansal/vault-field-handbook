storage_source "file"{
    path = "/mnt/data/vault/data"
}

storage_destination "mysql"{
  address  = "127.0.0.1:3306"
  username = "vault"
  password = "vault-pass"
  database = "vault"
}