---
sidebar_position: 10
---

# Docs

Docs is the MijnBureau document editor: a collaborative, block-based writing
tool for notes, meeting minutes, specifications and wikis. Several people can
type in the same document at the same time, every change is saved
automatically, and each document keeps its own history.

## Opening it

- Web: `https://docs.<global.domain>`
- From the [Bureaublad](./bureaublad.md): the documents tile

## The interface

| Area          | What it does                                                           |
| ------------- | ---------------------------------------------------------------------- |
| Document list | All documents you own or can read, with search and filters             |
| Subpages      | A tree of pages under the document you are in — Docs doubles as a wiki |
| Editor        | The writing surface: headings, lists, tables, callouts, code, media    |
| Comments      | Discussions attached to a passage, without editing the text            |
| Share         | Who can read, comment or edit                                          |
| History       | Previous versions of the page, restorable                              |

## Creating a document

1. Click **New doc** on the document list.
2. Give it a title (the first line is the title).
3. Write. Press `/` for the block menu, or use `#` for headings, `-` for
   lists, `>` for quotes, and ` ``` ` for code blocks.
4. Paste images or drop files into the page to embed them.
5. Create subpages with **New subpage** to build a structure — a project wiki,
   a handbook chapter, or meeting notes per month.

Everything is saved as you type; there is no save button and nothing is lost
when you close the tab.

![Docs editor with a page tree on the left and a document with comments](/img/features/notes.png)

## Writing together

- Share the document (see below) and start writing: cursors and selections of
  other people appear in the text.
- Use **comments** for review remarks: select text, choose _Comment_, and reply
  in the side panel. Resolve the comment when it is handled.
- **@mention** a colleague in a comment to notify them.
- For substantial rewrites, work in a subpage or a copy and merge by hand —
  simultaneous editing is safe, but big reorganisations are easier to review
  separately.

## Sharing and permissions

1. Click **Share** in the document header.
2. Add people or teams by name.
3. Pick a role: _Reader_ (read), _Commenter_ (read and comment), _Editor_
   (change), _Owner_ (also manage sharing).
4. Optionally create a link for people outside the organisation and choose its
   role.
5. Save, then tell the person where to find it — it appears in their document
   list.

Permissions on a subpage are inherited from its parent unless you explicitly
share the subpage; keep that in mind before moving a confidential page under a
widely shared parent.

## Templates and structure

- Create your own recurring structure (meeting notes, decision records,
  onboarding) once, then duplicate the document as a template.
- Use a top-level document as the index of a project, with the actual content in
  subpages.
- Keep titles searchable: they are what global search and the document list show
  first.

## History and recovery

- **History** lists earlier versions with author and time; open one to compare,
  then restore it if needed.
- Restoring a version does not delete later versions — you can go back again.
- Deleted documents go to the trash; ask the owner or an administrator to
  restore one if you deleted it by mistake.

## Exporting

Export a document to PDF or to an Office format from the document menu, for
people who do not have access to the platform. If you need to _edit_ an Office
file, store it in [Drive](./drive.md) instead — Docs is for content written
here.

## Good to know

- Docs and Drive are separate stores. A Docs page is not a file in Drive; share
  it through Docs.
- Search inside documents is provided by the global search service when it is
  enabled — see [Search](./find.md).
- Long documents stay fast; if a page becomes a dumping ground, split it into
  subpages.
- E-mail notifications for shares and mentions arrive in your
  [Mail](./messages.md) inbox.

## Related

- [Drive](./drive.md) — files and Office documents
- [Collabora](./collabora.md) — editing Word/Excel/PowerPoint
- [Search](./find.md) — find text across documents
- [Component documentation](../components/docs.md) — how Docs is deployed
