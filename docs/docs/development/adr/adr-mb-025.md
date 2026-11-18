# ADR-MB-025: Testing strategy

## Status

Accepted (complements ADR-MB-007)

## Context

ADR-MB-007 selects Conftest as the policy engine but does not describe how the repository
is validated. MijnBureau is a Helmfile composition of third-party charts, so most defects
appear as rendered manifests rather than application code: wrong namespaces, missing
secrets, broken selectors, invalid values or environment-specific gating.

A single render is not enough because environments intentionally differ. Tests must run
without a cluster so contributors and CI get the same result.

## Decision

We will validate changes with a layered, cluster-free test strategy.

1. **Formatting** — Prettier over the repository (`scripts/format.sh`).
2. **Lint** — gitlint for commit messages and `helmfile lint` for charts
   (`scripts/lint.sh`).
3. **Render matrix** — `scripts/test.sh` renders every environment listed in `tests/*.yaml`
   and runs the environment-specific Rego rules in `tests/`.
4. **Policy** — `scripts/policy.sh` runs `policy/` against the rendered default environment,
   covering namespaces, labels, images and NetworkPolicies.
5. **CI parity** — `.github/workflows/ci.yaml` renders every environment, runs kubeconform
   and Conftest on the output, and executes the same setup tests.

A change is not complete until all steps pass for the environments it affects. Rendering
outside the scripts requires `MIJNBUREAU_MASTER_PASSWORD` to be set explicitly.

## Consequences

**Pros:**

- ✅ Failures are caught before a cluster is involved.
- ✅ Environment-specific gating is exercised, not assumed.
- ✅ Contributors can reproduce CI locally with the same scripts.

**Cons:**

- ❌ The render matrix grows with every environment and slows CI.
- ❌ Policy tests validate structure, not runtime behaviour; upgrade testing still needs a
  cluster.
- ❌ Third-party chart behaviour can change in ways the policy rules do not model.
