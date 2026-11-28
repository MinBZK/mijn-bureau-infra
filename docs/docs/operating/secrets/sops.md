---
sidebar_position: 30
---

# SOPS secrets files

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

## Steps to use SOPS

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

## Scripts integration

- `./scripts/test.sh` accepts `-s "$SOPS_AGE_KEY"` for decryption in CI/test settings.
- When available, `./scripts/policy.sh` reads the master password from `/run/secrets/mijnbureau-master-password`.

## Relationship to the other options

SOPS files are overrides on top of the [derived secrets](./derived.md): use them
for the handful of values that cannot be derived. To move all secrets to a
central secret manager instead, see
[External Secrets Operator](./external-secrets-operator.md).
