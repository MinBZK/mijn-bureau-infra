---
sidebar_position: 4
---

# Testing

This guide explains the testing process for MijnBureau. To ensure a secure and high-quality product, we test critical components and continuously improve our testing practices. The `./scripts/` directory contains scripts to enhance quality and security. Passing these scripts increases the likelihood of passing the CI/CD pipeline (though it is not guaranteed).

---

## Formatting

We enforce strict formatting rules using Prettier. To format your changes, run:

```bash
./scripts/format.sh
```

---

## Linting

Linting is enforced using GitLint and Helmfile. To lint your changes, run:

```bash
./scripts/lint.sh
```

---

## Pre-commit Checks

We use pre-commit hooks to enforce general rules before committing. To run pre-commit checks on the repository, execute:

```bash
pre-commit run --all
```

---

## Policy Compliance

Policies ensure adherence to Architectural Decision Records (ADRs). These checks are performed using Conftest. To verify policy compliance, run:

```bash
./scripts/policy.sh
```

If you are interested in the policies, they are located in the `./policy/` folder.

---

## Helmfile Testing

We have developed a testing system for Helmfile to ensure charts meet quality standards and include important variables. To test your changes, run:

```bash
./scripts/test.sh
```
