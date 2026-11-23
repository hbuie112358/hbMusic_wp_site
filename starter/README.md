# DTS Starter

*In this file "the user" is the person Claude works with, and "Claude" is the assistant.*

The site layer a new DTS brochure site starts from (template plan 1.6, T12 and T13): a neutral,
light placeholder look, logo and wording that work out of the box and are replaced by the
site's own. At template plan 2.4 this folder becomes the `dts-site-starter` repository's site
layer; until then it lives here, checked by this repository's `bin/check` and proven weekly on a
dev site of its own (1.6c).

## What is here

- `site.json`: the starter's site facts, in the same form as every site's (`tools/site-settings.md`):
  four test pages (Home, About, Contact, Privacy Policy) and the site's own plugins, Site
  Hardening and Editing Help. No `deploy` section: the starter is never deployed.
- `theme/`: only the site layer, the files listed in `tools/site-layer-files.txt`, each at the path
  of the file it replaces in a full child theme, plus the logo in `assets/images/`. Everything
  else (the component stylesheets, the scripts, `functions.php`, the page templates) is the shared
  theme code, which the starter's dev site takes from this repository's theme (1.6c) until
  template plan 2.3 moves it into the shared components plugin.
  - `theme.json`: the palette below and every design token the components read.
  - `style.css`: the theme's name and description, which a new site changes.
  - `parts/`: the header, the footer and the call to action ("Ready to talk?", a button "Get in
    touch" to `/contact/`).
  - `patterns/site-logo.php` and `assets/images/site-logo.svg`: a placeholder mark.
  - `includes/site-facts.php`: no old addresses, no areas served, the plain schema.org
    Organization, and the Content-Security-Policy's outside sources for the contact form's
    Turnstile check only. A site with videos adds YouTube's players there.
- `dev-content/`: neutral text for the four pages. The Contact page holds the contact form's
  shortcode; its form is this site's booking form from `config/`, a stand-in until 2.4 brings the
  starter's own.

The text domain and prefix `hbmusic` are the shared theme code's until template plan 2.3 renames
them; `bin/check` allows that one name here and refuses the site's others.

## The palette and its contrast

Computed with WCAG 2.2's formula for each pair of colors the components put together (exception
E8: contrast is checked by the pairs in use); every pair passes level AA, 4.5:1 for text and 3:1
for controls and focus rings. The tightest is the muted text on the placeholder panel, 4.60:1.

| Role (slug) | Color | Pair | Ratio |
|---|---|---|---|
| Page (`base`) | `#ffffff` | | |
| Text (`contrast`) | `#1b1f24` | on the page / on the light gray panel | 16.56 / 15.03 |
| Paragraphs (`contrast-soft`) | `#3a4048` | on the page / on the light gray panel | 10.46 / 9.50 |
| Accent (`accent-1`) | `#1d5fc2` | white button label on it | 6.06 |
| | | white label at the button highlight's top edge (`#2f6cc7`) | 5.15 |
| | | white label on its hover color (`#1951a5`) | 7.63 |
| | | as a focus ring or outline on the page / on the light gray panel | 6.06 / 5.50 |
| Deep accent (`accent-2`) | `#163f7a` | the call to action: white text on it | 10.36 |
| | | white text on the grain's brightest speck (`#1c447e`) | 9.62 |
| | | its button: deep blue label on white | 10.36 |
| Links (`accent-3`) | `#1a55ad` | on the page / on the light gray panel | 7.13 / 6.47 |
| Light gray (`accent-4`) | `#f2f4f7` | the features panel and form fields | |
| Line gray (`accent-5`) | `#dde2e8` | dividers (decorative) | |
| Muted gray (`accent-6`) | `#5b6470` | field borders on the field / on the page | 5.44 / 6.00 |
| | | placeholder text on line gray | 4.60 |
| Form error | `#b42318` | on the page | 6.57 |
| Header | white at 90% | text over it, black content beneath (worst case) | 13.21 |
| Carousel arrows | white on black at 60% | white content beneath (worst case) | 5.74 |
| Video play triangle | white on black at 75% | white picture beneath (worst case) | 10.41 |

A change to the palette is checked again the same way, every pair it touches, before it is kept.
