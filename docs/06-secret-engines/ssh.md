# Hashicorp VAULT SSH ENGINE
> what we are building

![flow image](../assets/secret%20engines/ssh.png)


## SSH ENGINE: Vault Configuration and Usage

### Prerequisites (On Target Machine)

> create the user on target machine
```bash
useradd -m -s /bin/bash sachin
```

### Vault Server Configuration

> Enable SSH Secrets Engine

```bash
vault secrets enable -path=test_ssh ssh
```
> Configure SSH Role (`my-role`)

```bash
vault write test_ssh/roles/my-role -<<EOH
{
  "algorithm_signer": "rsa-sha2-256",
  "allow_user_certificates": true,
  "allowed_users": "*",
  "allowed_extensions": "permit-pty,permit-port-forwarding",
  "default_extensions": {
    "permit-pty": ""
  },
  "key_type": "ca",
  "default_user": "master",
  "ttl": "2h"
}
EOH
```

### Configure Remote Machines

> Retrieve and Trust the CA Public Key

On all remote machines:

```bash
curl -H "X-Vault-Token: <service_token>" \
     -o /etc/ssh/trusted-user-ca-keys.pem \
     http://192.168.29.10:8200/v1/test_ssh/public_key
```

> Update `sshd` Configuration

Add the trusted CA key to the SSH daemon configuration.

```bash
/etc/ssh/sshd_config.d# cat vault.conf
TrustedUserCAKeys /etc/ssh/trusted-user-ca-keys.pem
```

> Restart SSH Daemon

```bash
sshd -t
systemctl restart sshd
```

### Local Machine Usage

#### Generate Local SSH Key Pair


ssh-keygen -t ed25519 -f ~/.ssh/id_vault


#### Generate Short-Lived Signed Certificate (Using `my-role`)

```bash
vault write test_ssh/sign/my-role \
    public_key=@~/.ssh/id_vault.pub
```

The output will include the signed certificate.

#### Save the Signed Certificate

Example command to save the certificate (note: the provided `echo` command saves a specific example cert, the actual command should capture the output of the `vault write` above):


#### capturing the actual output is better:

> USe vault write recommended
```bash
vault write test_ssh/sign/my-role public_key=@~/.ssh/id_vault.pub 
```

>  Or echo command:
```bash
echo "ssh-ed25519-cert-v01@openssh.com AAAAI
..................
..............
Tw==" \
> ~/.ssh/id_vault-cert.pub
```

## Generate Short-Lived Signed Certificate (Using `ca_test` role, if needed)

repeat the vault write command for a role named `ca_test`:

```bash
vault write test_ssh/sign/ca_test public_key=@~/.ssh/id_vault.pub > ~/.ssh/id_vault-cert.pub
```

#### Set Permissions

```bash
chmod 600 ~/.ssh/id_vault-cert.pub
```

### SSH Access

Use the private key and the signed certificate to authenticate.

```bash
ssh -i ~/.ssh/id_vault -i ~/.ssh/id_vault-cert.pub sachin@192.168.29.10
```

**Note:** OpenSSH usually detects the corresponding `-cert.pub` file automatically if the private key is specified, so the following might also work:

```bash
ssh -i ~/.ssh/id_vault sachin@192.168.29.10
```
