# ADR-MB-026: Component selection exceptions

## Status

Accepted (amends ADR-MB-012)

## Context

ADR-MB-012 adopts a partner-first tooling strategy: prefer LaSuite or OpenDesk tooling, and
document any exception with a written rationale. The suite currently contains components
that are not part of either stack:

- **Bureaublad** — the start page, developed by MinBZK.
- **Excalidraw** — a whiteboard, bundled as an additional collaboration tool.
- **Ollama** — a local LLM runtime, used as a demo AI provider.

Without a recorded rationale, the partner-first rule is silently violated and future
choices have no precedent to follow.

## Decision

We will record these exceptions explicitly.

- **Bureaublad** is maintained by MinBZK and is therefore an in-house component rather than
  a third-party exception. It integrates the suite and is not a candidate for replacement.
- **Excalidraw** is included because neither LaSuite nor OpenDesk offers a whiteboard that
  integrates with the existing OIDC and sharing model. It is an exception under ADR-MB-012
  for as long as no partner component covers the capability.
- **Ollama** is included as a demo provider behind the OpenAI-compatible `ai.llm`
  interface. It is disabled for production use and does not create a dependency on a
  specific AI vendor.

Any further non-partner component requires an ADR that states the missing capability, the
evaluated partner alternatives and the exit path if a partner component becomes available.

## Consequences

**Pros:**

- ✅ The partner-first rule stays meaningful instead of being quietly bypassed.
- ✅ Exceptions have owners and an exit condition.
- ✅ Demo and production component sets are documented separately.

**Cons:**

- ❌ Each exception adds a component that must be tracked for security updates.
- ❌ Excalidraw may be replaced later, which is user-visible churn.
- ❌ More ADRs to maintain when the component set changes.
