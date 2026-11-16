# Search record

*In this file "the user" is the person Claude works with, and "Claude" is the assistant.*

One entry per page: what the page should be found for in search engines, and how it is set up
for that. Each entry is written as the page's brief before its wording changes, then completed
with the result of the SEO plugin's check (Yoast SEO 28.8). The aim: every check green; any check
that is not green is listed with its reason. Plan item 1c (`docs/planning/rebuild-plan.md`).
Everything here is public anyway in search results; no personal data.

## Search phrases (agreed with the user, 2026-11-15)

Each page answers its own question, so no two pages compete for the same search. Only Home and
Book carry Fayetteville; About carries Southern Pines. Every phrase is a starting point until it is checked against Google's own
search suggestions while the page's brief is written (step 1 of 1c): a phrase comes from what
people actually search for, never from what turns a check green.

**No town in any page address** (the user, 2026-11-16; the handbook's 12, 9.6): addresses stay
valid if the business moves or serves other towns, and the towns go where they are cheap to
change: search titles, descriptions, page text and the page data. Google's SEO Starter Guide:
keywords in the "URL path alone have hardly any effect beyond appearing in breadcrumbs". Yoast's
address check passes without the town when more than half of a 3-word-or-longer phrase is in the
address (Yoast 28.8's code). Where it would need the town, the search phrase stays as people
search it, and the check stays orange with that reason (`toolkit/yoast.md` in the handbook), after
first looking for a change that serves both.

| Page | Current address | Search phrase |
|---|---|---|
| Home | `/` (the front page) | acoustic guitarist in Fayetteville |
| Book | `/hire-acoustic-guitarist/` (was `/book/`) | hire an acoustic guitarist in Fayetteville |
| Music | `/music/` | acoustic guitar cover videos |
| Songs | `/songlist/` | acoustic cover song list |
| About | `/about/` | acoustic guitarist Southern Pines |
| Privacy Policy | `/privacy-policy/` | privacy policy |

## Home

Done on staging 2026-11-16: Yoast's SEO and readability analyses both green.

- Search phrase: acoustic guitarist in Fayetteville. Google completes both "acoustic guitarist
  fayetteville" and "acoustic guitarist in fayetteville" (with "nc", "north carolina", "nc area");
  "in" lets the title read naturally while staying an exact match, and Yoast's other checks
  ignore it.
- Search title: Acoustic Guitarist in Fayetteville, NC: Live Vocals and Guitar, followed by the
  site name (Yoast: `… %%page%% %%sep%% %%sitename%%`). "NC" because every search added it and
  Arkansas, Georgia and West Virginia's Fayettevilles also came up; "Live Vocals and Guitar" says
  he sings and plays at once (the user's choice).
- Description: Hire Howard Buie, an acoustic guitarist and singer, for events and private parties
  in Fayetteville, Hope Mills and Southern Pines, NC. (134 characters)
- Address: `/`, the front page, unchanged. Yoast does not run its phrase-in-address check on a
  front page (`slugKeyword` applies only when the page is not the front page, Yoast 28.8's
  code, checked 2026-11-15).
- Text changed for the checks, each true and useful to visitors: the heading "For any kind of
  event" became "An acoustic guitarist and singer for any kind of event"; "Over 30 years on stage"
  became "Now a solo guitarist and singer in Fayetteville", with the 30 years moved into its
  paragraph (the user's wording, ending "Follow him on Facebook."); a new last section,
  "Questions people ask" (travel, own sound equipment, playing time, what to include in a
  request), from the user's answers.
- Links to: Book (three links, the new section's "booking page" among them, changed from
  `/book/` to `/hire-acoustic-guitarist/` on 2026-11-16), Music, Songs, About; outside, the user's Facebook page (the
  address the Book page already uses).
- Pictures: the hero photo, its alternative text "Howard Buie, acoustic guitarist, smiling as he
  plays" (changed on staging from "… playing an acoustic guitar", which Yoast did not count:
  "guitar" is not "guitarist" to its free version).
- Not green, with reasons: none.
- Found in step 1, for later: "singer" came up in four searches, so Home says "guitarist and
  singer"; "hire" is a real search word ("hire guitarist near me", "hire singer guitarist");
  "guitar" also draws shops and rentals; "live music … tonight" and "this weekend" are people
  looking for public shows, an idea for later (a list of public gigs). Related searches named
  performers by who they are; nothing taken from that (the user's decision).

## Book

- Search phrase: hire an acoustic guitarist in Fayetteville (the user, 2026-11-16: people planning
  an event say "hire"; "book" is the word of venues, agents and musicians). Google suggests "hire
  guitarist near me", "hire a guitar player", "hire an acoustic guitar player"; the small words
  let the title read naturally as an exact match.
- Search title: Hire an Acoustic Guitarist in Fayetteville, NC (then the site name)
- Description: Hire an acoustic guitarist and singer in Fayetteville, NC for weddings, parties,
  clubs and restaurants. Send Howard your event's details.
- Text changed: the first paragraph opens "Looking to hire an acoustic guitarist in
  Fayetteville?"; "the list" links to the song list.
- Address: `/hire-acoustic-guitarist/`, set on staging 2026-11-16 (3 of the phrase's 4 main
  words, so green without the town); the menu label stays "Book". WordPress keeps no record of a
  page's old address (`wp_check_for_changed_slugs()` skips hierarchical post types such as pages),
  so `/book/` answered "not found" until each link was changed: staging's "Main menu" (Site
  Editor, the ⋮ beside the menu's name, then Edit), Home's links (by the user), and in code the
  call-to-action panel's button, the old site's `/contact/` redirect (no redirect from `/book/`:
  it was never live, so nothing outside knows it), and the dev site's page and tests, with a new test that every link between the site's pages
  answers (`links.spec.ts`).
- Links to: the song list (from "the list"); outside, the user's Facebook page.
- Pictures: none (see below).
- Not green, with reasons:
  - Text length (about 55 words; Yoast wants 300): a form page, which visitors open to send a
    request. Google: "there's no magical word count target". A "What happens next" section was
    considered; the user judged the page says enough before sending, and the form's "sent"
    message now tells visitors what happens next (2026-11-16).
  - Images, and keyphrase in image alt attributes (no picture on the page): the user's decision,
    2026-11-16. A form page; Google's guide places images near relevant text and has no rule that
    every page needs one; the only prepared photo is Home's, and repeating it adds nothing. To
    reconsider if a photo of Howard performing at an event becomes available.
  Both overall lights green on 2026-11-16.

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

Done on staging 2026-11-16: both overall lights green in the Pages list.

- Search phrase: acoustic guitarist in Southern Pines (the user, 2026-11-16: so that a search for
  it finds this page, giving Southern Pines a page of its own while Home carries Fayetteville).
  Google completes "acoustic guitarist southern pines" (with "nc"); its suggestions there lean to
  live music and shops, so fewer people may search this way than for Fayetteville.
- Search title: Acoustic Guitarist in Southern Pines, NC: About Howard (then the site name)
- Description: Meet Howard Buie, an acoustic guitarist and singer playing events in Southern
  Pines, Fayetteville and nearby, NC, with over 30 years on stage.
- Address: `/about/`, unchanged. Without the town, any address holds at most 2 of the phrase's 4
  main words ("acoustic guitarist"), exactly half, which Yoast does not count as green.
- Text changed (the user's own text kept): "covering rock and country music" links to the song
  list; a new closing paragraph, "As an acoustic guitarist in Southern Pines and Fayetteville,
  Howard plays local venues as well as private events. Follow him on Facebook to see where he's
  playing next." (no venue named, the user's wish), with the Facebook link moved into it.
- Links to: the song list (`/songlist/`; change it if the Songs page's address changes); outside,
  the user's Facebook page.
- Pictures: none.
- Not green, with reasons (the user, 2026-11-16):
  - Keyphrase in slug (an improvement): green would need the town in the address, against the
    no-town rule, or a phrase chosen for the address, against the rule that phrases come from
    real searches; Google: words in an address have "hardly any effect".
  - Text length (under 300 words): the user's own text, plus one true closing paragraph; nothing
    added for length (Google: "no magical word count target").
  - Images, and keyphrase in image alt attributes: the user's decision; Home already shows his
    photo.

## Privacy Policy

Done on staging 2026-11-16.

- Search phrase: privacy policy. Nobody is expected to find the site through it; the phrase lets
  Yoast's checks make sense for this page.
- Search title: the page's own name, "Privacy Policy", then the site name (Yoast's default).
- Description: This privacy policy explains what this site collects, why, who else handles it,
  how long it is kept, and how to ask about it.
- Address: `/privacy-policy/`, set 2026-11-15 (plan item 1).
- Text changed: the first sentence opens "This privacy policy explains…"; "the Book page" in the
  booking form section links to `/hire-acoustic-guitarist/`.
- Links to: the Book page; outside, Brevo's, Cloudflare's, Google's, Wordfence's and Hostinger's
  privacy policies, and the contact email address.
- Pictures: none.
- Not green, with reasons (the user, 2026-11-16):
  - Keyphrase in subheading: Yoast wants "privacy policy" in at least 30% of the page's 13
    headings, four or more; one more would read naturally ("Changes to this privacy policy"),
    the rest would be repetition, which Google's guide calls tiring and keyword stuffing.
  - Images, and keyphrase in image alt attributes: a privacy policy needs no picture; Google's
    guide has no rule that every page needs one.
  Both overall lights (SEO and readability) green in the Pages list, 2026-11-16. Known: Yoast's
  "Word complexity" line is an advertisement for its paid version and checks nothing.
