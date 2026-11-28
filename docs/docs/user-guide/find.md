---
sidebar_position: 140
---

# Search (Find)

Find is the MijnBureau search service. It indexes the content of your documents
and files so that one search box — on the [Bureaublad](./bureaublad.md) — can
find a phrase inside a document, a file name, or a person, instead of you
remembering which application you wrote it in.

## Using it

1. Open the [Bureaublad](./bureaublad.md).
2. Type in the search field: a word, a phrase, a file name, a person.
3. Press Enter.
4. Results are grouped by application. Open one to jump straight to the item.

Search is available wherever the platform has enabled it; when your
administrator has not turned on the content index yet, only names and titles are
searched.

## What is searched

| Source                    | What is matched                                         |
| ------------------------- | ------------------------------------------------------- |
| [Docs](./docs.md)         | Document titles and body text, including subpages       |
| [Drive](./drive.md)       | File names, and the content of supported document types |
| [Contacts](./contacts.md) | Names, groups and profile details                       |

Chat and mail are searched **inside their own applications** (the search field in
Element and in Messages), not from the Bureaublad. That is intentional: message
history is encrypted or personal, so it is kept out of the central index.

## Writing queries that work

- Use the words you would have written in the document: _"budget 2026
  marketing"_ beats _"budget"_.
- Put a distinctive phrase in quotes if you remember it verbatim.
- Search for the person who wrote it when you remember them better than the
  subject.
- Narrow by application if the result list is long: add the tool name or open the
  application and search there.
- Results are ranked, not alphabetical — the first page is usually enough.

## Permissions and privacy

- The search index respects access rights: you only get results for content you
  could open anyway.
- Indexing happens on your own infrastructure; content is not sent to an external
  search engine.
- Deleting a document or file removes it from future results; existing results
  may lag briefly while the index catches up.
- Search does not reveal _why_ you can see something; if a document looks
  unexpectedly public, check its sharing settings.

## When results look wrong

| Symptom                     | Explanation                                                    |
| --------------------------- | -------------------------------------------------------------- |
| Recent document missing     | The index updates with a short delay after saving              |
| No results inside documents | Content indexing is not enabled in your deployment             |
| Results you cannot open     | The item was shared with you and then removed                  |
| Only titles found           | The document type is not indexed (for example an archive)      |
| Search box absent           | Global search is not enabled; use the application's own search |

## Good to know

- Folder-level search in [Drive](./drive.md) and in-document search in
  [Docs](./docs.md) still work independently; they are faster for "search within
  this thing".
- The index covers text, not images; a screenshot of a table is not findable by
  its contents.
- If you need a subject to be findable by others, write the keywords into the
  title or the first paragraph.

## Related

- [Bureaublad](./bureaublad.md) — where the search box lives
- [Docs](./docs.md) and [Drive](./drive.md) — the indexed sources
- [Component documentation](../components/find.md) — how the search service is deployed
