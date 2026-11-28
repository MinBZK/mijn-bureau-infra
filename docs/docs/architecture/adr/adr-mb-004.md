# ADR-MB-004: Gitmoji commits

## Status

Accepted

## Context

Having no commit convention can lead to inconsistencies, making it harder to understand the purpose of a commit at a glance, especially during code reviews and when reading the Git history

## Decision

We will adopt [Gitmoji](https://gitmoji.dev/) as our commit message convention. Gitmoji is a standardized way of using emojis to represent the intent of a commit.

```
<emoji>(optional scope) <description>

[optional body]

[optional footer(s)]
```

## Consequences

**Pros:**

- ✅ Improves readability of commit logs.
- ✅ Provides an at-a-glance overview of the types of changes in the codebase.
- ✅ Encourages contributors to be more thoughtful and descriptive in commits.

**Cons:**

- ❌ Might have a learning curve for new team members unfamiliar with Gitmoji.
- ❌ Some tools or pipelines may require extra configuration if emojis cause formatting issues
