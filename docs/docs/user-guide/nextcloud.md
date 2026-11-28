---
sidebar_position: 150
---

# Files (Nextcloud)

Nextcloud is the optional file platform in MijnBureau. It complements
[Drive](./drive.md): Drive is the place for sharing inside the platform, while
Nextcloud adds desktop synchronisation, mobile apps and the classic
"network drive in my file manager" experience.

## Opening it

- Web: `https://nextcloud.<global.domain>`
- From the [Bureaublad](./bureaublad.md): the Nextcloud tile
- Desktop and mobile: install the Nextcloud client and sign in with
  `https://nextcloud.<global.domain>`

You sign in with your MijnBureau account; there is no separate Nextcloud
password.

## The sync client

The reason to enable Nextcloud is the desktop client:

1. Download the client for Windows, macOS or Linux from your organisation's
   software portal (or from nextcloud.com).
2. Add an account and enter `https://nextcloud.<global.domain>`.
3. Your browser opens the sign-in page; authenticate there.
4. Choose which folders to sync and where they appear locally.
5. Keep the client running: it uploads local changes and downloads remote ones.

Rules that prevent most sync problems:

- Do not edit the same file on two machines at once while offline; the client
  will create a conflict copy instead of merging.
- Do not sync enormous folders (VM images, photo libraries) — they cost space and
  time.
- Pause syncing on metered connections; resume before you need the files.
- Never delete the sync folder on disk to "clean up": the client treats it as a
  deletion and removes the files on the server too.

## Sharing

Sharing works like the rest of the suite: pick the file or folder, choose
**Share**, add colleagues by name or create a link with an expiry date. Roles are
the familiar viewer/editor set (see the [overview](./index.md#sharing)).

External shares (links) are the usual way to exchange large files with people
outside the organisation.

## Versions and deleted files

- Each file keeps previous versions; open the file's _Versions_ panel to restore
  one.
- Deleted files go to _Deleted files_ and can be restored by the owner until the
  retention period ends.
- Restoring a version or a deleted file counts as a change and syncs to all
  connected devices.

## Office documents

Office files stored in Nextcloud also open in [Collabora](./collabora.md), the
same office suite that Drive uses. Multiple people can edit the same document at
the same time, and the result stays a normal `.docx`/`.xlsx` file.

## When to use Nextcloud and when to use Drive

| Need                                                         | Use                         |
| ------------------------------------------------------------ | --------------------------- |
| Share a folder with a colleague inside the platform          | Drive                       |
| Work in the same file from several devices, offline included | Nextcloud (sync client)     |
| Hand a large file to somebody outside the organisation       | Either — links work in both |
| Keep files next to documents and projects in one workflow    | Drive                       |

Your organisation may standardise on one of them; follow that, and do not store
the same document in both places.

## Good to know

- Quotas apply and are managed by your administrator.
- The sync client is the only component that stores files on your device; the web
  interface does not.
- Files are stored on the organisation's own infrastructure, not in a public
  cloud.
- If a folder suddenly shows hundreds of conflicts, stop the client and ask for
  help instead of resolving them by hand.

## Related

- [Drive](./drive.md) — the platform-native file storage
- [Collabora](./collabora.md) — Office editing
- [Component documentation](../components/nextcloud.md) — how Nextcloud is deployed
