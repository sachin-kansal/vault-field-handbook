# Key/Value pair

***Most Common and simplest Secret Engine used mostly in every organisation***

-  Save information in the key value pair
-  data saved in json format

## Enable engine

> kv secret engine comes in 2 different version 1 and 2. version 2 is recommended and we will e using the same.

```bash
vault secrets enable -version=2 -path=testengine kv
``` 
> path is the important configuration as it define the kv secret engine name and root path which allow us to create ultiple kv secret engines.

> Default value of path is kv

![sucess](../assets/secret%20engines/kv/engine%20enabled.png)

UI

![sucessui](../assets/secret%20engines/kv/kvui.png)

## creating secret
```bash
vault kv put -mount=testengine secret1 username=sachin password=dfyabhsfh
```
![secretcreateed](../assets/secret%20engines/kv/ui%20output.png)

> **To Remember:** the path of secrets vary with the tool used for access.

![secretpaths](../assets/secret%20engines/kv/ui%20path%20info.png)


## versioning

> kv version2 comes with versioning

As you can see in the image new version 2 of the same secret is created

![versioning](../assets/secret%20engines/kv/versions%20cli.png)

> in ui you can see the changes made

![versioningdiff](../assets/secret%20engines/kv/versiondiff.png)

### rollback the secret version
> **To Remember:**even if the secret is rollback a new version of that secret will be created having the data copied from previous version.

for instance if we rollback from v5 to v3 then a new v6 will be created having the data stored in v3

> current active version
![currentversion](../assets/secret%20engines/kv/current%20version.png)

```bash
vault kv rollback -mount=testengine -version=1 secret1
```
![rollbackcmd](../assets/secret%20engines/kv/rolbackv1-v2.png)

a new version 3 is created if compared with version1 it will be same.

![statemach](../assets/secret%20engines/kv/statematch.png)


## patching a secret

### why patch??
> when we ran the put command it created a new verion(v2) of secret containing only the details passed from cli and it deleted the data stored in old version(v1) but that is not the requirement all the time. it could be that i want to edit only 1 kv pair or add a new kv pair without loosing existing data.

> Key is unique and used to identify whether it needs to update the value or add a new pair

> every update creates a new version.

#### adding new pair
```bash
vault kv patch -mount=testengine secret1 patching="adding something new"
```
![patching1](../assets/secret%20engines/kv/patching%20adding%20new%20cli.png)
![patchingouput](../assets/secret%20engines/kv/patcing%20adding%20info.png)

#### updating a kv pair

```bash
vault kv patch -mount=testengine secret1 patching="updating the old data"
```
![patching3](../assets/secret%20engines/kv/vault_patching_update_cli.png)
![patching4](../assets/secret%20engines/kv/vault_patching_update_ui.png)

## Deleting vs Destroying


Deleting | Destroying
-------- | ---------
only marks the secret version as deleted | permenantly deletes the version of secret
can be restored using undelete | version is lost form the chain forever no recovery possible

### Deleting
we will see in the UI and cli using get command the version3 of secret name secret1 mounted at testengine gets marked deleted and becomes unreadable after deletion. later this will be recoverable using undelete.
```bash
vault kv delete -mount=testengine -versions=3  secret1
```
Cli
![result1](../assets/secret%20engines/kv/deletebeforeafter.png)

UI
![ui1](../assets/secret%20engines/kv/deletev3.png)
![ui2](../assets/secret%20engines/kv/deletedui.png)


### Recovering the Lost version

```bash
vault kv undelete -mount=testengine -versions=3  secret1
```

![undelete1](../assets/secret%20engines/kv/undelete1.png)
![undelete2](../assets/secret%20engines/kv/undelete2.png)

Now the lost data is recovered and deleted mark is removed. It can be usefull when we want to secure the data for some period of time without loosing it. thoose could be security patch, compliance tests moving the vault backened. 

This way secrets are still present but are not readable by any application including any malware or thirdparty attack on the vault.


### Destorying

Destroying is the permanent deletion of secret

```bash
vault kv destroy -mount="testengine" -versions=3  "secret1"
```

![destroy1](../assets/secret%20engines/kv/destroy1.png)
![destroy2](../assets/secret%20engines/kv/destroy2.png)

### Reading 

> to read specific version
```bash
vault kv get -mount="testengine" -version=2  "secret1"
```

> to read latest current version
```bash
vault kv get -mount="testengine"  "secret1"
```
***Remember the Current version is always latest version***
