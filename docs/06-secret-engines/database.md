# Dynamic Database Secrets

The database is where an application's most valuable asset lives: its data.
Breaches are reported almost daily, and leaked personal data leads directly
to identity theft and fraud. Every extra hurdle between an attacker and the
database matters.

HashiCorp Vault's database secrets engine creates credentials on demand.
Each application request gets a unique database user with a limited
lifetime (TTL). When the lease expires, Vault automatically drops the user,
and the application must request new credentials.

This is more secure than static passwords stored in a Vault KV engine,
a Kubernetes Secret, or a shared environment file:

- **No shared or long-lived passwords.** Every credential is unique and
  temporary, so a leaked one stops working soon after.
- **No human ever needs to see or store the password.**
- **Least privilege by role.** A service that only reads data gets a
  read-only role and cannot modify data or run DDL commands that change
  the schema.
- **Audit and revocation.** Every credential request is logged, and any
  lease can be revoked instantly.

The following steps show how to make your database credentials dynamic.

## Enable and configure the Engine

![Enable Engine](../assets/secret%20engines/db/db-engine.png)

## Create the Vault_admin user

> A vault admin user is required in Database side. this user is used to create users and grant them required access as instructed by vault. And don't worry even the credentials for this users are not known by anyone as vault rotates them post db connection is created.

![Vault admin](../assets/secret%20engines/db/vault-admin.png)

## Create DB connection in Vault

![DB_Connection](../assets/secret%20engines/db/db-connection.png)

## Create Role for app

Creation statement 
> SQl statement to create role and grant Select permission to public scheme for all tables.

```sql
CREATE ROLE "{{name}}" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';
GRANT SELECT ON ALL TABLES IN SCHEMA public TO "{{name}}";
```
Revoke Statement

> Sql Statement to revoke the user and grant any object owned by temporary user to assign back to vault_admin.

```sql
REASSIGN OWNED BY "{{name}}" TO vault_admin;
DROP OWNED BY "{{name}}";
DROP ROLE IF EXISTS "{{name}}";
```

![App_reader](../assets/secret%20engines/db/app-reader.png)

## Generate Credentials

```bash
vault read database/creds/app-reader/
``` 
![generate_password](../assets/secret%20engines/db/generated_password.png)

> the generated password is shortlived for only 1 hour post that application needs to re-request the new credentials from the vault.

## Use Credentials and test

> As it can be seen the user can read data as only select is granted to the role. the Insert command fails 

![test_credentials](../assets/secret%20engines/db/use_Creds.png)