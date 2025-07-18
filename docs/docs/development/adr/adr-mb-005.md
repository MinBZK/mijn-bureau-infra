# ADR-MB-005: Use GitHub for Source Code Management

## Status

Accepted

## Context

Our team requires a reliable, collaborative, and feature-rich platform to manage source code, handle version control, support continuous integration workflows, and facilitate open development.

there are many providers like github, gitlab, codeberg, opencode and some self hosted options like gitea.

## Decision

We will use GitHub as our primary platform for source code management across all projects. Main reason is the big user base they have and the free CI/CD runners. We currently also do not have the resources to host and run things ourself that is not directly related to our project deliverables.

We will **not** use the advanced features of Github which will create a unnecessary vendor lock-in.

## Consequences

- Our workflows will center around GitHub features and APIs and will need rewriting when changing provider
- Contributors will need a GitHub account
- We rely on a third-party hosted service
