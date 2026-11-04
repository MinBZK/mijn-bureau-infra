# Vaultwarden

This directory contains the Helm chart and Helmfile configuration for
[Vaultwarden](https://github.com/dani-garcia/vaultwarden), a lightweight
Bitwarden-compatible password manager server.

## Notes

- The Helmfile deployment uses PostgreSQL (Bitnami by default, CloudNativePG
  when `database.default.provider=cnpg`) via `DATABASE_URL`.
- SSO uses the configured `authentication.oidc.issuer`, falling back to the
  in-cluster Keycloak realm when the issuer is unset and Keycloak is enabled.
  SSO is always enabled and is the only login method; the vault master password
  is still required to decrypt the vault. Email changes are disabled in
  Vaultwarden so the local email cannot drift from the identity provider.
- Attachments, RSA keys and the icon cache are stored on a persistent volume
  mounted at `/data`. If `database.host` is empty the chart falls back to
  SQLite on that same volume.
- The admin panel token is generated from `MIJNBUREAU_MASTER_PASSWORD` and can
  be used at `https://<hostname>/admin`.
- Horizontal pod autoscaling stays disabled by default because attachments are
  still stored on a ReadWriteOnce volume. Enable it only after moving file
  storage to shared/object storage.
