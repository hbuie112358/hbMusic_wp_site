# Routines

*In this file "the user" is the person Claude works with, and "Claude" is the assistant.*

The recurring care the site needs, with what each step protects. Agreed with the user on
2026-11-10 (plan step 8). The user keeps a monthly calendar reminder: "Monthly site check, see
docs/ROUTINES.md".

## Monthly site check (about 10 minutes)

Until go-live, steps 1-3 run on staging; afterwards on live.

1. **Booking test:** on the Book page, send a request with the user's own name, an email address
   of the user's, and the message "monthly test".
2. **It arrives:** within a few minutes, in the business Gmail inbox, with the label "Booking
   requests". If not, see "If the test fails" below.
3. **Delete the test email.** Never click its "Unsubscribe" link or "Report spam": either one puts
   the address on Brevo's blocked list, and every booking request after that is dropped without
   any alert (plan step 8, "Brevo setup, where it stands").
4. **Content export (D27):** in the live site's admin, Tools → Export → All content → Download
   Export File. The file goes into the project's `data/exports/`, named with the date
   (for example `2026-12-01-content.xml`). The originals of new photos go into `data/photos/`.
5. **The data folder's off-computer copy** is brought up to date.

**What it protects:**
- Steps 1-2 prove the whole path a visitor's request takes (the form, FluentSMTP, Brevo, Gmail),
  which a failure alert alone cannot: a request Brevo accepts but does not deliver raises no
  alert.
- The test also uses Brevo's API key every month. The key expires after 90 days without use.
- Step 4 is the off-site copy D27 chose instead of a backup plugin: the content holds no keys or
  passwords, and the code is on GitHub.

## If the test fails

- **A Pushover alert came:** sending failed. FluentSMTP → Email Logs shows the error, and the
  request can be resent from there once the cause is fixed. If Brevo refused the server's address,
  that address is authorised under Brevo's Security → Authorized IPs. The failed entry holds a
  visitor's details and is deleted once dealt with.
- **No alert and no email:** Brevo accepted the email but did not deliver it. Most likely the
  receiving address is on Brevo's blocked list for transactional email. Where Brevo lists it, to
  unblock the address, is still to be found on the real screen and written in here.
- **The email is in spam despite the filter:** it is marked "Not spam", and the Gmail filter
  (`from:website@howardbuiemusic.com`, never spam, label "Booking requests") is checked.

## When replacing a picture

A changed picture gets a **new file name** (for example `howard-buie-logo-2027.png`), never the old
name over the old file. Visitors' browsers keep pictures for up to 7 days (the server's
`cache-control`, plan 8l), so under the old name some visitors would still see the old picture
for a week. Pages, styles and scripts need nothing: they arrive fresh or carry a version in their
address.

Claude helps with any of these when the user brings the symptom to a session.
