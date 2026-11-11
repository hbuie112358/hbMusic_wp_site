# Step 2: inventory of the old site

*In this file "the user" is the person Claude works with, and "Claude" is the assistant.*

What the old site contains, from the database dump in `db/` and the files in `wordpress/`
(export of 2026-11-01). Public content only: no login names, addresses of visitors or
credentials. Ends with the list of what the new site must cover.

## Pages and posts

| Page | Content | Notes |
|---|---|---|
| Home (front page) | Short bio; "Contact For an event" button | Button links to `http://` with the domain written out (D7) |
| About | Longer bio; the same button | Same link |
| Contact | Booking email address and a Facebook link, as text | No form on the page |
| Songlist | 108 songs: titles in one list, artists in a second list beside it | The two lists match only by position; edited most recently (2025-12) |
| Video | Lists the posts in the category "All video" | Works: 3 posts |
| Audio | Lists the posts in the category "All audio" | **Empty:** the category has no posts, but the page is in the main menu |
| Audio and Video | No content; set as the posts page | Not in the menu; appears unused |

- **Posts:** 3 ("Video 01" to "Video 03"), each one YouTube embed. Categories by decade (1970s,
  1980s, 1990s, 2010s; 2000s unused) and "All video".
- **Reusable blocks:** "audio" and "video", the post lists used by the Audio and Video pages.
- **Revisions:** 356 old saved versions; not carried over.

## Navigation and widgets

- **Main menu:** Home, Video, Audio, Songlist, Contact, About.
- **Sidebar:** Recent Posts; a list of the categories under "Audio & Video"; a search box
  labelled "Search for audio or video". The theme's home and footer widget areas are empty.

## Theme

- **`music-lite` 1.5 (active):** header with the site title (logo option on, but no logo set;
  header image off), main menu, content with sidebar, footer with a copyright line and theme
  credit. Custom CSS (theme-specific fixes: title capitalisation, list markers, video spacing),
  not needed with the new theme.
- **`music-lite-child` (inactive): empty.** Its only code loads the parent's stylesheet; open
  item 4 is settled, nothing to carry over.

## Site settings

- Site title "Howard Buie Music"; tagline "Solo acoustic guitarist and singer in Parkersburg,
  Marietta, Mid Ohio Valley"; time zone America/New_York; permalinks `/%postname%/`.
- Comments closed by default; registration off; search engines allowed.
- No site icon (favicon).

## Search and sharing (Yoast SEO 28.1 at the export; updated to 28.8 in plan step 0f)

- Set up: XML sitemap on, titles from the site name and tagline, Facebook page linked, Open Graph
  and Twitter cards on.
- Gaps: the site is described as a **company**, not a person or musician (`docs/SITE_CHECKLIST.md`
  9.2); **no default sharing image** (9.3); **author archives on** in Yoast, one of the ways login names
  are revealed (4.5); checked on the live site on 2026-11-02: `/?author=1` returns 404 and the
  REST user list 401, so the name is not revealed there; no home page meta description of its own (it uses the tagline).

## Images

Six images in the media library (33 MB in `uploads/`, including WordPress's generated sizes):

| Image | Original | Notes |
|---|---|---|
| Photo, 2025-01 | 8192×5464, 12 MB | Scaled copy 2560×1708 used; the original is far larger than any page needs |
| Photo playing, 2024-03 | 2984×3978, 5 MB | Scaled copy 1920×2560 used |
| Photo playing, 2024-04, three crops | 960×540 and two crops, PNG, 390-800 KB | Photos saved as PNG: several times heavier than JPEG or WebP |
| Two small icons for the audio and video lists | 278×372 and 309×174, PNG, 120-215 KB | Same; the theme shows them at 30-77 px wide |

## Leftovers in the database

Tables and settings from plugins that are no longer installed: All in One SEO (`wp_aioseo_*`),
WPForms (`wp_wpforms_*`, and one contact form that nothing uses), MonsterInsights (three note
categories). Wordfence's own tables hold its logs. None of this is carried to the new site.

## Security notes

- **Login log** (Wordfence, 2025-01-09 to 2026-10-31): about 1,360 failed logins, 155 of them
  with the real login name; no successful login except the user's own on 2025-01-09. No sign of
  a break-in through the login. The new site's admin gets a new login name (step 9).
- **Email:** a confirmation email sent on 2026-11-02 never arrived (see the plan's Current
  position).

## What the new site must cover

The list as written on 2026-11-02, with what became of each item (updated 2026-11-11). D19
(2026-11-07) moved song requests, clips and setlist preferences to future plugins, and D22 set the
five pages.

From the content:
- [x] Home: bio and a clear way to book (2b, D22; on staging since 5f).
- [x] About: the longer bio (2b, D22; on staging).
- [x] Contact: became the Book page (D22), with the booking form (5e) and the email and Facebook
  links; `/contact/` forwards to it (8h). The request form went to a future plugin (D19).
- [x] Songlist: all 108 songs with their artists (5a, on staging).
- [~] Video: became the Music page (D22, on staging); which videos, and which on Home, is the
  user's choice (5f).
- [ ] A way to find a song or video (today: the sidebar search): the sidebar is gone (D22); a
  search on the Songs page comes after go-live (the user, 2026-11-11).
- [~] The main photos: the 885-pixel photo is used as it is (D23) and web copies are in
  `data/photos/web/`; a modern format (WebP) is not decided.

From the user's requests (plan step 5):
- [x] Songs as data, entered in the admin (5a).
- [ ] Song requests with emailed clips (5b, D8): a future plugin (D19), not for go-live.
- [ ] A private audio clip per song (5c): a future plugin (D19).
- [ ] Setlist preferences (5d), with genre and era per song: a future plugin (D19); 5a stores
  only the title and artist.

To decide in the content and design session (plan step 2b):
- [x] The Audio page: dropped; Music replaces it, and `/audio/` forwards there (D22, 8h).
- [x] The empty "Audio and Video" page: dropped (D22).
- [x] The sidebar: dropped (D22).
- [~] A site icon and a default sharing image: the sharing image is set in Yoast (step 6); a site
  icon is not decided.

Fixed by the rebuild (`docs/SITE_CHECKLIST.md`):
- [ ] Links inside content without the domain written out (D7): checked with the content at step 9.
- [x] Yoast: an Organization (a musician since 8h, `MusicGroup`), a sharing image, author
  archives off (step 6).
- [ ] Old plugin leftovers and revisions not carried over: decided with step 9's choice between
  updating in place and a fresh install.
