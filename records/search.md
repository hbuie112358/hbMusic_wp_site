# Search record

*In this file "the user" is the person Claude works with, and "Claude" is the assistant.*

One entry per page: what the page should be found for in search engines, and how it is set up
for that. Each entry is written as the page's brief before its wording changes, then completed
with the result of the SEO plugin's check (Yoast SEO 28.8). The aim: every check green; any check
that is not green is listed with its reason. Plan item 1c (`docs/planning/rebuild-plan.md`).
Everything here is public anyway in search results; no personal data.

## Search phrases (agreed with the user, 2026-11-15)

Each page answers its own question, so no two pages compete for the same search. Only Home and
Book carry Fayetteville; About carries Southern Pines. To be checked against Google's own search
suggestions while each page's brief is written.

| Page | Current address | Search phrase |
|---|---|---|
| Home | `/` (the front page) | acoustic guitarist Fayetteville |
| Book | `/book/` | book acoustic guitarist Fayetteville |
| Music | `/music/` | acoustic guitar cover videos |
| Songs | `/songlist/` | acoustic cover song list |
| About | `/about/` | acoustic guitarist Southern Pines |
| Privacy Policy | `/privacy-policy/` | privacy policy |

## Home

- Search phrase: acoustic guitarist Fayetteville
- Search title: *(to write in 1c)*
- Description: *(to write in 1c)*
- Address: `/`, the front page, unchanged. Yoast does not run its phrase-in-address check on a
  front page (`slugKeyword` applies only when the page is not the front page, Yoast 28.8's
  code, checked 2026-11-15), so the page can be fully green.
- Links to: *(to decide in 1c)*
- Pictures: *(to decide in 1c)*
- Not green, with reasons: *(after Yoast's check)*

## Book

- Search phrase: book acoustic guitarist Fayetteville
- Search title: *(to write in 1c)*
- Description: *(to write in 1c)*
- Address: *(to decide in 1c; proposed `/book-acoustic-guitarist-fayetteville/`)*
- Links to: *(to decide in 1c)*
- Pictures: *(to decide in 1c)*
- Not green, with reasons: *(after Yoast's check)*

## Music

- Search phrase: acoustic guitar cover videos
- Search title: *(to write in 1c)*
- Description: *(to write in 1c)*
- Address: *(to decide in 1c)*
- Links to: *(to decide in 1c)*
- Pictures: *(to decide in 1c)*
- Not green, with reasons: *(after Yoast's check)*

## Songs

- Search phrase: acoustic cover song list
- Search title: *(to write in 1c)*
- Description: *(to write in 1c)*
- Address: *(to decide in 1c; `/songlist/` was kept on purpose by D22)*
- Links to: *(to decide in 1c)*
- Pictures: *(to decide in 1c)*
- Not green, with reasons: *(after Yoast's check)*

## About

- Search phrase: acoustic guitarist Southern Pines
- Search title: *(to write in 1c)*
- Description: *(to write in 1c)*
- Address: *(to decide in 1c)*
- Links to: *(to decide in 1c)*
- Pictures: *(to decide in 1c)*
- Not green, with reasons: *(after Yoast's check)*

## Privacy Policy

- Search phrase: privacy policy
- Search title: *(to write in 1c)*
- Description: *(to write in 1c)*
- Address: `/privacy-policy/`, set 2026-11-15 (plan item 1).
- Links to: *(to decide in 1c)*
- Pictures: *(to decide in 1c)*
- Not green, with reasons: *(after Yoast's check)*; readability green since 2026-11-15. Known:
  Yoast's "Word complexity" line is an advertisement for its paid version and checks nothing.
