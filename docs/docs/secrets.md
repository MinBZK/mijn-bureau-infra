---
sidebar_position: 6
---

# Secrets

Sensitive values, such as database passwords, can be securely stored for MijnBureau using [helm-secrets](https://github.com/jkroepke/helm-secrets). Secrets can be managed in various ways, including secret managers like HashiCorp Vault or encryption tools like [SOPS](https://getsops.io/) and Vals. MijnBureau supports secrets handling and provides an example configuration for SOPS. A similar setup can be created for other tools.

### Example Secrets File

```bash
./helmfile/environments/{environment}/example.secrets.yaml
```

---

## SOPS

This section explains how to use SOPS for managing secrets. First, install [SOPS](https://getsops.io/) and [AGE](https://github.com/FiloSottile/age).

### Steps to Use SOPS

1. **Generate an AGE Key Pair**:

   Run the following command to generate a key pair:

   ```bash
   age-keygen -o mykey.txt
   ```

2. **Update `.sops.yaml`**:

   Replace the `age:` entry in `.sops.yaml` with your public key.

3. **Encrypt a File**:

   Add values to `example.secrets.yaml` and encrypt it:

   ```bash
   helm secrets encrypt -i ./helmfile/environments/{environment}/example.secrets.yaml
   ```

4. **Decrypt for Local Use**:

   Decrypt the file for local use by running:

   ```bash
   export SOPS_AGE_KEY_FILE=./mykey.txt
   helm secrets decrypt -i ./helmfile/environments/{environment}/example.secrets.yaml
   ```

5. **Use with Helmfile**:

   Export the required environment variables and run Helmfile commands:

   ```bash
   export MIJNBUREAU_MASTER_PASSWORD=changethis
   export SOPS_AGE_KEY_FILE=./mykey.txt
   helmfile template
   helmfile apply
   ```
