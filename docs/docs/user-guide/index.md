---
sidebar_position: 10
---

# Using MijnBureau

MijnBureau is a complete digital workplace: chat, mail, video meetings, files,
documents, a calendar, project management and search, all running on your own
organisation's infrastructure. Every tool is a separate web application, but you
only sign in once and they all know who you are.

This guide is written for people who _use_ MijnBureau. For installing,
configuring and administering a deployment, see the
[component documentation](../components/index.md) and the
[Administration](../operating/administration.md) page.

## The tools in one table

| Tool                                               | What you use it for                                                 | Where                           |
| -------------------------------------------------- | ------------------------------------------------------------------- | ------------------------------- |
| [Bureaublad](./bureaublad.md)                      | The starting point: all apps, search and your shortcuts on one page | `bureaublad.<global.domain>`    |
| [Chat (Element)](./element.md)                     | Chat with colleagues and external Matrix users, in channels and 1:1 | `element.<global.domain>`       |
| [Mail (Messages)](./messages.md)                   | Shared inboxes, threads, labels and attachments                     | `messages.<global.domain>`      |
| [Calendar](./calendars.md)                         | Personal and shared calendars, invitations, booking links           | `calendars.<global.domain>`     |
| [Meetings (Meet)](./meet.md)                       | Video calls with screen sharing, recording and AI summaries         | `meet.<global.domain>`          |
| [Drive](./drive.md)                                | Files and folders, sharing with people or links                     | `drive.<global.domain>`         |
| [Docs](./docs.md)                                  | Collaborative documents, meeting notes and wikis                    | `docs.<global.domain>`          |
| [Office editing (Collabora)](./collabora.md)       | Edit Word, Excel and PowerPoint files in the browser                | inside Drive and Docs           |
| [Projects](./projects.md)                          | Project plans, pages and tasks                                      | `projects.<global.domain>`      |
| [Contacts](./contacts.md)                          | Personal and shared address books, groups and labels                | `contacts.<global.domain>`      |
| [Dictaphone](./dictaphone.md)                      | Turn audio recordings into transcripts and summaries                | `dictaphone.<global.domain>`    |
| [AI assistant (Conversations)](./conversations.md) | Ask questions, summarise text, draft content                        | `conversations.<global.domain>` |
| [Search (Find)](./find.md)                         | One search box across your documents and files                      | `find.<global.domain>`          |
| [Files (Nextcloud)](./nextcloud.md)                | File sync and desktop clients, when your organisation enables it    | `nextcloud.<global.domain>`     |
| [Your account](./account.md)                       | Change your details, manage sessions, sign out everywhere           | `mas.<global.domain>`           |

Not every deployment enables every tool. The [Bureaublad](./bureaublad.md) only
shows the apps your organisation has turned on.

## Signing in

Every application uses the same account, managed centrally by your
organisation's identity provider (MijnBureau ships with Keycloak at
`id.<global.domain>`).

1. Open any application, for example `https://bureaublad.<global.domain>`.
2. You are redirected to the sign-in page of `id.<global.domain>`.
3. Enter the username and password you received from your administrator.
4. After signing in you are returned to the application you started from.

There is no separate password per tool and **self-registration is disabled**:
accounts are created by your administrator. If you do not have an account yet,
ask them for one.

:::tip
Use a password manager. Since you sign in once for all applications, that one
credential protects all your mail, files and chat.
:::

## Common concepts

A few things work the same everywhere, so they are explained once here.

### Your identity

Your display name, e-mail address and avatar come from your central account. You
change them once, in [your account](./account.md), and all applications pick the
change up. Some deployments lock the display name in chat (so it cannot drift
from the directory) — that is intentional.

### Sharing

Sharing works with roles, and the vocabulary is the same in Docs, Drive and
Nextcloud:

| Role            | Can do                                          |
| --------------- | ----------------------------------------------- |
| Viewer / Reader | Open and download, no changes                   |
| Commenter       | Read and leave comments or suggestions          |
| Editor          | Change the content, upload new versions         |
| Owner / Manager | Everything above, plus invite others and delete |

There are two ways to share:

- **With people** — search for a colleague by name or e-mail address. They get
  access through their existing account; no link to forward.
- **With a link** — for people outside your organisation. Anyone with the link
  gets the role you picked. Treat such links like passwords, and set an expiry
  date when the tool offers one.

### Notifications

Each application has its own notification settings (mail, in-app, or both).
Application notifications are sent through the MijnBureau mail server, so they
arrive in your MijnBureau inbox.

### Working offline and on mobile

All tools are web applications: they work in any modern browser (Firefox,
Chrome, Edge, Safari) without installation. Chat has native mobile and desktop
apps; file sync needs Nextcloud, which not every deployment enables.

## Getting help

- Something does not work? First check [Your account](./account.md) — an expired
  session explains most "it suddenly stopped working" cases.
- Ask your administrator for access to a tool you cannot open, or for an account
  in a shared inbox.
- Your administrator can use the [Administration](../operating/administration.md) page to
  look up logs, sessions and accounts.
