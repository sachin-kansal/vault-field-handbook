# Vault Production Setup

## What We Are Doing ?

We are going to setup a Single-Node  Vault server on a Rasberry Pie machine with production like configuration.

For now we are using filesystem as storage backend which is not recommended in production at all. But we will migrate this storage backened later from filesystem to Mysql Database.

When Configuring following points should be kept in mind
 
 - do i need ui
 - Run vault server on the Private network with no internet.
 - Can Applications and Users/teams can reach it.
 - Tls must be enabled for secure communication
 - Level of Logs needs to be enabled
 - Which Montioring tool are to be used and where to right the logs files

## Configure vault.hcl
Full configuration reference → [vault.hcl](./vault.hcl)

## download and install packages

source :
```url
https://developer.hashicorp.com/vault/install
```
```bash
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update && sudo apt install vault
```

## create the Vault User

For least privilidges on linux machine we need to create the vault user. No-one should have any extra access then they need it.

```bash
 useradd --system --home /etc/vault.d --shell /bin/false vault
```

## porper directories

### Backend Storage

> we need Data for using filesystem backend storage for now. we will migrate it to DB

```bash
/srv/vault/data 
```

### For logs

> We need log directory for keeping the hashicorp vault logs. monitoring tools like filebeat can scrape it.

```bash
/srv/vault/log
```

### For Audit Logs

> Audit logs to see who/which app logged in when and what they did. No secrets created or changed are captured by the audit logs only actions performed

```bash
/srv/vault/audit
```

### Move binaries from default bin path

```bash
sudo mv /usr/bin/vault /srv/vault/bin/vault
sudo chown vault:vault /srv/vault/bin/vault
sudo chmod 750 /srv/vault/bin/vault
ln -s /srv/vault/bin/vault /usr/bin/vault
```
## configure vault.hcl

- server ip exposing vault for ui
  192.168.29.10

- tls 
    1. disabled for dev
      ```hcl
      listener "tcp" {
      address = "192.168.29.10:8200"
      tls_disable = 1
      }
      ```
    2. enable for production (must)

       to generate the self signed certificate
      ```bash
      openssl req -x509 -newkey rsa:4096 \
      -keyout /etc/vault.d/vault-key.pem \
      -out /etc/vault.d/vault-cert.pem \
      -days 365 -nodes \
      -subj "/CN=192.168.29.10" \
      -addext "subjectAltName=IP:192.168.29.10"
      ```
      
       Cofiguration block 
      ```hcl
      #HTTPS listener
      listener "tcp" {
      address       = "192.168.29.10:8200"
      tls_cert_file = "/etc/vault.d/vault-cert.pem"
      tls_key_file  = "/etc/vault.d/vault-key.pem"
      }
      ```
    *** REMEMBER *** 
    
    certificate use must rely on SAN not CN else following error will be thrown by vault cli
    vault status
    
    >Error checking seal status: Get "https://192.168.29.10:8200/v1/sys/seal-status": tls: failed to verify certificate: x509: certificate relies on legacy Common Name field, use SANs instead

- telemetry (pre-requiste prometheus)
  1. create policy for metrics  
   ```hcl
    path "sys/metrics" {
    capabilities = ["read","list"]
    }
   ```
  2. create token with policy attached
    ```bash
    vault token create \
    -policy=prometheus-metrics \
    -period=720h \
    -display-name=prometheus \
    -no-default-policy
    ```
  3. update vault and prometheus configs
    
    vault telemetry
    ```hcl
    #telemetry
    telemetry {
    prometheus_retention_time = "30s"
    disable_hostname = true
    }
    ```

    prometheus job
    ```yaml
    - job_name: vault
    metrics_path: "/v1/sys/metrics"
    scheme: https
    tls_config:
      ca_file: "/etc/vault.d/vault-cert.pem"
    bearer_token: "hvs.xxxxxxxxxxxxxxxxxx"
    params:
      format: ['prometheus'] 
    static_configs:
    
      - targets: ['192.168.29.10:8200']
    ```
- backened filesystem
```bash
  # data
  /srv/vault/data
  #logs and audit logs
  /srv/vault/log/vault.log
  chown -R vault:vault /srv/vault/data /srv/vault/log/vault.log
  /srv/vault/audit
```
- mlock enabled
  > to prevent keys and tokens from bieng written on the disk

- logging level : Error

## systemd unit file
```bash
cat << EOF > /etc/systemd/system/vault.service
[Unit]
Description=HashiCorp Vault
Documentation=https://www.vaultproject.io/docs
Requires=network-online.target
After=network-online.target

[Service]
User=vault
Group=vault
ExecStart=/srv/vault/bin/vault server -config=/etc/vault.d/vault.hcl
ExecReload=/bin/kill --signal HUP $MAINPID
KillMode=process
Restart=on-failure
RestartSec=5
LimitNOFILE=65536
CapabilityBoundingSet=CAP_IPC_LOCK
AmbientCapabilities=CAP_IPC_LOCK
NoNewPrivileges=yes

[Install]
WantedBy=multi-user.target
EOF
```
## init the vault
``` bash
vault status

vault operator init

vault operator unseal  #repeat until sealed false i.e. minimum threshold set

# enable audit logs
chown -R vault:vault /srv/vault/audit/

vault audit enable file file_path=/srv/vault/audit/audit.log
```
