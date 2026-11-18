# Search

MijnBureau provides one search experience across the suite. The Bureaublad search bar and
the search fields in Docs and Drive query **Find**, the LaSuite global search service.

## How it works

- Docs and Drive push their documents into separate OpenSearch indices (`find-docs`,
  `find-drive`).
- New apps can be integrated (but we started with docs and drive)
- A search request carries the user's own token, exchanged through **Menshen** into a
  scoped Find token, so results only include documents the user may open.
- Access rights are enforced server-side; the index is not a public copy of all content.

Search requires `application.find.enabled` (indexing) and, for routing searches through
Find, `application.find.searchEnabled`. Without the latter, Docs falls back to title search.

## Where to search

| Location              | What it searches                     |
| --------------------- | ------------------------------------ |
| Bureaublad search bar | Docs and Drive, with scope selection |
| Docs                  | Documents, titles and full text      |
| Drive                 | Files and folders                    |

## Configuration

- [Find component documentation](../components/find.md)
- [Bureaublad component documentation](../components/bureaublad.md#global-search)
