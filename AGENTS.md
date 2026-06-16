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

When you change infrastructure files, use this order:

1. Run `./scripts/format.sh` when formatting is needed.
2. Run `./scripts/lint.sh` for lint checks.
3. Run `./scripts/test.sh` for full policy validation.
4. Run `./scripts/policy.sh` when you only need policy verification.

When you change docs files:

1. Run `cd docs && yarn` if dependencies are missing.
2. Run `cd docs && yarn start` for local verification.
3. Run `cd docs && yarn build` before finalizing changes.

## Troubleshooting

- If `helmfile` fails on secrets, provide `-s "$SOPS_AGE_KEY"` to `./scripts/test.sh`.
- If `conftest` is missing, install it and rerun the script.
- If docs commands fail, run `yarn` again in `docs/`.
