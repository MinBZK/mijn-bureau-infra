---
sidebar_position: 2
---

# Your account

Your MijnBureau account is managed centrally: one identity (Keycloak) and one
Matrix identity (Matrix Authentication Service, MAS) that all applications rely
on. This page explains what you can change yourself and how to manage your
sessions.

## What is managed where

| Thing                         | Where you change it                                                          |
| ----------------------------- | ---------------------------------------------------------------------------- |
| Name, e-mail address          | Your account page at `https://id.<global.domain>/realms/mijnbureau/account/` |
| Password                      | The sign-in page of the identity provider (`id.<global.domain>`)             |
| Profile picture               | Managed by your organisation                                                 |
| Chat display name and devices | Element (only if your administrator allows it)                               |
| Team and contact details      | [People](./people.md)                                                        |

Most deployments feed your name and e-mail from the identity provider and lock
them in the individual tools, so that your chat profile, mail sender and
document author always match.

## Opening your account

1. Go to `https://id.<global.domain>/realms/mijnbureau/account/`, or click your
   name in the [Bureaublad](./bureaublad.md) and choose _Account_.
2. Sign in with your usual credentials if asked.
3. You land on your Keycloak account page with your profile and connected
   applications.

Password and session management live in Keycloak; name and e-mail are fed from
the identity provider and cannot be changed from the applications themselves.

## Changing your password

1. Go to the sign-in page of `id.<global.domain>`.
2. Choose _Forgot password_ (or _Update password_ from your account overview).
3. Follow the instructions in the e-mail you receive.

If no reset mail arrives, your organisation may not have enabled password
recovery; ask your administrator to reset the password for you.

## Managing sessions and devices

Every application you signed in to keeps a session. Close the ones you no longer
recognise:

1. Open your account page at `https://id.<global.domain>/realms/mijnbureau/account/`.
2. Open _Account security_ → _Device activity_.
3. Review the list — browser, operating system, last activity — and revoke
   anything that is not yours.
4. Sign out of everything when you lose a device.

Revoking a session signs that device out on its next request. Chat clients that
stay connected in the background may take a minute to notice.

## Connected applications

The account page lists the applications you have granted access to (Docs,
Drive, Meet, Mail, Chat, …). Revoking a grant here logs that application out;
the next visit asks you to sign in again.

## Signing out properly

- **From one application:** use its own _Sign out_ menu item.
- **From everything:** sign out in your account page, or close your browser and
  revoke the remaining sessions.
- **Shared computers:** always sign out of both the application and the identity
  provider — closing the tab is not enough.

## Tips

- Use one browser profile for work. Mixing personal and work profiles mixes
  sessions and makes "why am I logged in as someone else" bugs possible.
- Keep your e-mail address up to date: password resets and invitations go there.
- Chat device verification matters: see [Chat](./element.md#devices-and-verification)
  before you sign in on a new laptop or phone.

## Related

- [Administration](../administration.md) — for administrators looking up or
  resetting accounts
- [Bureaublad](./bureaublad.md) — the overview page you start from
