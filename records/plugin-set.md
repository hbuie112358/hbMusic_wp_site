# Expected plugin set

*In this file "the user" is the person Claude works with, and "Claude" is the assistant.*

What howardbuiemusic.com should have installed, each with its reason (the handbook's chapter 12,
5.5; H85). The monthly check compares live with it (`docs/ROUTINES.md`, step 12): anything
installed and not listed here is handled as a possible break-in. Staging has the same set,
except where noted. Read on both by the user on 2026-11-23 (WP-CLI over the password login),
matching this list.

## Plugins

| Plugin | Comes from | Why |
|---|---|---|
| Contact Form 7 (`contact-form-7`) | `bin/deploy`, pinned in `site-packages/` | The booking form (handbook toolkit) |
| Yoast SEO (`wordpress-seo`) | `bin/deploy`, pinned in `site-packages/` | Search titles, descriptions, page data (toolkit) |
| Simple History (`simple-history`) | `bin/deploy`, pinned in `site-packages/` | The activity log (H94, template plan 1.5b) |
| Song List (`song-list`) | `bin/deploy`, the site's own (`plugins/`) | The song list page and its admin form |
| Site Hardening (`site-hardening`) | `bin/deploy`, the site's own | Security headers and small hardening settings (chapter 12, 3.2) |
| Editing Help (`editing-help`) | `bin/deploy`, the site's own | The content guide in the admin (H89) |
| Wordfence (`wordfence`) | installed by hand, updated in the monthly check | Firewall, login limits, two-factor login (toolkit) |
| FluentSMTP (`fluent-smtp`) | installed by hand, updated in the monthly check | Sends the site's mail through Brevo (toolkit) |

All active. No drop-ins.

## Must-use plugins (`wp-content/mu-plugins/`)

| File | Comes from | Why |
|---|---|---|
| `hostinger-auto-updates.php` | Hostinger | Its automatic updates, set to security updates only (`docs/SITE_SPECIFIC_ROUTINES.md`, "Host") |

## Themes

| Theme | Status | Why |
|---|---|---|
| Howard Buie Music (`hbmusic-child`) | active, from `bin/deploy` | The site's child theme |
| Twenty Twenty-Five (`twentytwentyfive`) | its parent | The parent theme, also WordPress's default fallback (chapter 12, 5.2) |
| Music Lite (`music-lite`) and its child (`music-lite-child`) | inactive, live only | The old site's look, kept as the way back until rebuild plan 9n, then deleted ([E4](exceptions.md#e4)) |

## Accounts and keys

- **Administrators:** the user's go-live admin, and the old site's admin until 9n (E4). **Other
  accounts:** the user's Editor. No other account.
- **Server SSH keys:** the two deploy keys (`docs/SITE_SPECIFIC_ROUTINES.md`, "Expected set").
