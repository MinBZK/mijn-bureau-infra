# AGENTS

This file tells coding agents how to run, test, and validate this repository.

## Scope

You work in an infrastructure repository that uses Helmfile, Conftest, and Docusaurus.

Main areas:

- `helmfile/`: deployment definitions and environments.
- `policy/`: shared Rego policy rules.
- `tests/`: test environments and test-specific Rego policies.
- `docs/`: Docusaurus documentation site.

## Prerequisites

Install these tools before you run commands:

- `helm`
- `helmfile`
- `conftest`
- `prettier`
- `gitlint`
- `yarn` (for docs)

Optional for local secret handling:

- `sops`

## Quick Start

From repository root, run:

```bash
./scripts/lint.sh
./scripts/test.sh
```

These commands validate Helmfile configuration and policy behavior.

## Common Commands

Use these scripts from repository root:

```bash
./scripts/format.sh                 # Format files with Prettier
./scripts/lint.sh                   # Run gitlint and helmfile lint
./scripts/policy.sh                 # Render + run conftest policies
./scripts/test.sh                   # Run full test matrix from tests/*.yaml
```

Useful options:

```bash
./scripts/test.sh -e demo -s "$SOPS_AGE_KEY"
./scripts/policy.sh -e default
```

Notes:

- `./scripts/test.sh` sets `MIJNBUREAU_MASTER_PASSWORD=test` internally.
- `./scripts/test.sh` accepts `-s` to set `SOPS_AGE_KEY` for decryption.
- `./scripts/policy.sh` reads `/run/secrets/mijnbureau-master-password` when available.

## Render Manifests Directly

Use Helmfile directly when you need fast rendering checks:

```bash
helmfile template
helmfile -e demo template
```

## Documentation Site

The docs site lives in `docs/` and uses Docusaurus.

```bash
cd docs
yarn
yarn start
```

Build static docs:

```bash
cd docs
yarn build
```

## VS Code Tasks

If you run tasks from VS Code, use:

- `format`
- `lint`
- `generate`
- `policy`
- `test`

## Agent Workflow

**Mandatory checklist — run ALL of these before reporting a change as done, in this order. Never skip them, never leave them to a later step, and never report "done" while any of them failed or was not run. The CI pipeline (`ci.yaml`) runs the equivalent checks on every push/PR, so skipping these locally means the change fails in CI.**

```bash
./scripts/format.sh               # Prettier over the repo; must produce no git diff afterwards
./scripts/lint.sh                 # gitlint + helmfile lint
./scripts/test.sh                 # full Conftest policy matrix against tests/*.yaml
./scripts/policy.sh               # policy/ Rego rules against the rendered default environment
```

Notes:

- `./scripts/test.sh` sets `MIJNBUREAU_MASTER_PASSWORD=test` internally. Rendering outside test.sh requires `MIJNBUREAU_MASTER_PASSWORD` to be set explicitly (there is no default).
- `./scripts/policy.sh` accepts `-s` to set `SOPS_AGE_KEY` for decryption.
- If you change anything under `helmfile/`, also render every environment before reporting done:
  `MIJNBUREAU_MASTER_PASSWORD=test helmfile -e demo template`, `-e production template`, and `helmfile template` (default env). CI validates these via kubeconform and Conftest on the rendered manifests.

When you change docs files:

1. Run `cd docs && yarn` if dependencies are missing.
2. Run `cd docs && yarn start` for local verification.
3. Run `cd docs && yarn build` before finalizing changes.

## Network isolation baseline

When `cluster.networkPolicy.defaultDeny.enabled` is true (default), every
enabled app with `application.<app>.namespace` set gets a
`default-deny-ingress` NetworkPolicy from the `defaultdeny` release
(`helmfile/apps/common/charts/defaultdeny`), allowing same-namespace traffic
only. Routing into apps over Ingress/Gateway/LB depends on the chart's own
NetworkPolicy (`allowExternal`, `ingressNSMatchLabels`) — chart-provided
NetworkPolicies rely on namespaces carrying the `kubernetes.io/metadata.name`
label (set by standard K8s / Fundament). The conftest policy
`policy/netpol-namespaces.rego` warns when a NetworkPolicy selects a whole
namespace without narrowing to pods.

## Troubleshooting

- If `helmfile` fails on secrets, provide `-s "$SOPS_AGE_KEY"` to `./scripts/test.sh`.
- If `conftest` is missing, install it and rerun the script.
- If docs commands fail, run `yarn` again in `docs/`.

## Kubernetes

Everything is deploy on fundement, an NDSCloud based on gardener and metalstack. You can use kubectl commands to investigate how the applications run.

## Products used

We use allow of opensource products. Also allot from LaSuite. For deetails information about the lasuite products you can investigate the git repostitory on github. it often contains a helmchart you can use as example.

LaSuite Docs: <https://github.com/suitenumerique/docs/tree/main/src/helm/impress>
LaSuite Drive: <https://github.com/suitenumerique/drive/tree/main/src/helm/drive>
LaSuite Messages: <https://github.com/suitenumerique/messages>
LaSuite Calendar: <https://github.com/suitenumerique/calendars/>
LaSuite Meet: <https://github.com/suitenumerique/meet/tree/main/src/helm/meet>
LaSuite Projects: <https://github.com/suitenumerique/projects>
LaSuite conversations: <https://github.com/suitenumerique/conversations/tree/main/src/helm/conversations>
LaSuite Dictaphone: <https://github.com/suitenumerique/dictaphone/tree/main/src/helm/dictaphone>
Bureaublad: <https://github.com/MinBZK/bureaublad>
Element Synaps and web: <https://github.com/element-hq/element-docker-demo>
Livekit: <https://github.com/livekit/livekit>
