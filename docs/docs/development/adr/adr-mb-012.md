# ADR-MB-012: Align with partner tools

## Status

Accepted

## Context

MijnBureau is part of a broader public-sector ecosystem where partner programs already invest in digital workplace capabilities. LaSuite (France) and OpenDesk (Germany) both maintain tooling stacks that overlap with our platform needs.

When we align with partner tooling, you reduce duplicated engineering effort, lower long-term maintenance cost, and increase opportunities for shared investments (integration work, security hardening, testing, documentation, and operations patterns).

If we choose separate tools too early, you create parallel maintenance tracks, fragmented expertise, and higher total cost of ownership across years.

## Decision

Adopt a partner-first tooling strategy.

For every capability in scope, you evaluate tools in this order:

1. Use a tool already used by LaSuite or OpenDesk.
2. If no partner tool fits, evaluate whether the gap can be closed by configuration, extension, or contribution upstream.
3. Only then evaluate an alternative tool outside the partner stacks.

You only select a non-partner alternative when there is a strong, documented reason, such as:

- Mandatory legal, security, or compliance requirements are not met.
- Required functionality is missing and cannot be delivered in a realistic timeframe.
- Operational risk is unacceptable (for example reliability, supportability, or lifecycle concerns).
- Total cost and delivery impact are demonstrably better, based on a transparent comparison.

Each exception must include a written rationale, trade-off analysis, and review by architecture and product owners.

## Consequences

**Pros:**

- ✅ You reduce long-term platform cost by reusing existing partner investments.
- ✅ You improve interoperability and knowledge sharing with LaSuite and OpenDesk.
- ✅ You focus internal capacity on gaps and differentiation instead of duplicated foundations.
- ✅ You strengthen procurement and roadmap alignment through shared demand.

**Cons:**

- ❌ You may accept slower feature adoption when partner roadmaps move at a different pace.
- ❌ You spend additional upfront effort on partner-fit analysis before selecting tools.
- ❌ You need governance discipline to keep exception decisions consistent and evidence-based.

This ADR sets the default: partner alignment first, alternatives only with strong justification.
