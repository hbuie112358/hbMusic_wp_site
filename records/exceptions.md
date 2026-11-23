# Recorded exceptions

*In this file "the user" is the person Claude works with, and "Claude" is the assistant.*

Each place where howardbuiemusic.com differs from the DTS Operations Handbook on purpose, with its
reason and date (H99). The status sheet ([`status.md`](status.md)) links here from each item an
exception covers. The project's `CLAUDE.md`, "Handbook", names each one in a line. An exception
naming a weakness still open is kept in the private records folder, and only its number is here
(`records/README.md`).

## E1

**The host is Hostinger, not a DTS standard host** (chapter 3). The hosting is prepaid through
2028; the site moves when that plan ends (rebuild plan step 10). Since 2026-11-02.

## E2

**A staging site is kept on the host** (chapter 2's local staging, H7; chapter 12, 3.9). It is
the user's practice ground for staging on a host, which Shop sites need. It sits behind a
site-wide password at the server, with test content only, and runs live's PHP version. Since
2026-11-03 (rebuild plan 3g-1).

## E3

**Secrets are kept in the user's password notes, not in Bitwarden** (chapter 12, 1.5; the
toolkit, chapter 3), until DTS's Bitwarden is set up (a follow-up in the handbook's
`WORKING_DRAFT.md`, "Open items"); then each secret moves there. Nothing else holds them: not the
repository, GitHub, email or chat. Since 2026-11-23.

## E4

**Two Administrator logins belong to the user** (chapter 6; chapter 12, 4.1): the admin made at
go-live, and the old site's admin, kept as the way back until rebuild plan 9n (from about
2026-12-01), then removed. Since 2026-11-17.

## E5

See the private records (a weakness the host does not let the site close; chapter 12, 3.8).

## E6

**No written agreement on who may change what** (chapters 9 and 10; chapter 12, 4.9): the user's
own site, with no customer. Since 2026-11-23.
