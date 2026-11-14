---
sidebar_position: 6
---

# Secrets

MijnBureau handles secrets in two layers:

1. **Derived secrets** — all application and database passwords are *derived deterministically* from the master password `MIJNBUREAU_MASTER_PASSWORD`. Out of the box you do not need to store any password on disk.
2. **SOPS secrets files** *(optional)* — for values that must be overridden per environment (for example SMTP relay credentials), you can add an encrypted `*.secrets.yaml` file to an environment.

---

## 1. Derived secrets (default)

Every password in `helmfile/environments/default/secret.yaml.gotmpl` is generated with:

```yaml
{{ derivePassword 1 "long" (requiredEnv "MIJNBUREAU_MASTER_PASSWORD") "<app>" "<key>" | sha1sum }}
```

This means:

- Only `MIJNBUREAU_MASTER_PASSWORD` must be kept secret and stable. All logins (Keycloak admin, Nextcloud admin, database passwords, LiveKit keys, etc.) are reproducible from it.
- Changing `MIJNBUREAU_MASTER_PASSWORD` rotates **every** generated password and breaks access to existing data. Set it once for each deployment and keep it safe.
- Override an individual value in your environment values file (e.g. `helmfile/environments/production/mijnbureau.yaml.gotmpl`) under the `secret:` key if you want a specific password instead of a derived one.

Optional secret inputs consumed from the environment:

- `MESSAGES_MTA_RELAY_PASSWORD` — SMTP relay password for Messages (only when `application.messages.relayHost` is set).

---

## 2. SOPS secrets files (optional)

For secrets that cannot be derived (external credentials, federation keys, LDAP bind passwords, ...), MijnBureau supports SOPS-encrypted secrets files via [helm-secrets](https://github.com/jkroepke/helm-secrets).

> **Note:** loading of secrets files is disabled by default. The `secrets:` entries in `helmfile/bases/environment.yaml.gotmpl` are commented out; uncomment the block for the environments that use a secrets file:
>
> ```yaml
> demo:
>   values:
>     - "helmfile/environments/default/*.yaml*"
>     - "helmfile/environments/demo/*.yaml.gotmpl"
>   secrets:
>     - "helmfile/environments/{{ .Environment.Name }}/*.secrets.yaml"
> ```
>
> Secrets files must be named `*.secrets.yaml` in the environment directory; the default `values:` glob (`*.yaml.gotmpl`) does **not** pick them up.

### Steps to use SOPS

1. **Install the tools**: [SOPS](https://getsops.io/), [AGE](https://github.com/FiloSottile/age), and the [helm-secrets](https://github.com/jkroepke/helm-secrets) plugin. Running `helmfile init` installs the plugin.

2. **Generate an AGE key pair**:

   ```bash
   age-keygen -o mykey.txt
   ```

3. **Update `.sops.yaml`**: replace the `age:` entry in the repository root `.sops.yaml` with your public key. The path rule `.*secrets.yaml$` is already in place.

4. **Create and encrypt the secrets file**:

   ```bash
   # create helmfile/environments/<environment>/<name>.secrets.yaml with your values, then:
   export SOPS_AGE_KEY_FILE=./mykey.txt
   helm secrets encrypt -i helmfile/environments/<environment>/<name>.secrets.yaml
   ```

   Encrypted secrets files can be committed to git; SOPS only leaves the public values readable.

5. **Deploy** (helm-secrets decrypts in memory via helmfile):

   ```bash
   export MIJNBUREAU_MASTER_PASSWORD=changethis
   export SOPS_AGE_KEY_FILE=./mykey.txt
   helmfile -e <environment> template
   helmfile -e <environment> apply
   ```

### Scripts integration

- `./scripts/test.sh` accepts `-s "$SOPS_AGE_KEY"` for decryption in CI/test settings.
- When available, `./scripts/policy.sh` reads the master password from `/run/secrets/mijnbureau-master-password`.
