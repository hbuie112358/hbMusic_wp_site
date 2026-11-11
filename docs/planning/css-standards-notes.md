# CSS standards notes

*In this file "the user" is the person Claude works with, and "Claude" is the assistant.*

Notes for a later CSS section of the global coding standards (`~/.claude/coding_standards.md`
or a language file such as `CSS_STANDARDS.md`), collected while this site's styles are refined
(plan D29, 2026-11-11). **To do, after the refinement:** Claude proposes the wording, item by
item, and the user decides each one; nothing goes into the global files before that
(the user, 2026-11-11). Until then, a list of observations, not rules.

The starting point (the user, 2026-11-11): CSS is held to the same coding standards as any
language: appropriate structure, classes and techniques, enterprise grade, never sloppy.

## Observations so far

- **Every value has one name and one home.** Sizes, spacing, radii, widths, durations and
  colours are design tokens (in WordPress: `theme.json` `settings.custom` and the palette, read
  as `--wp--custom--…` and `--wp--preset--…`); component CSS uses only the tokens. Found because
  the first draft repeated `1100px`, `24px` and colours such as `#fff` across its rules.
- **The platform's own mechanism first.** What the framework can express natively (element and
  block styles, their `:hover` and `:focus-visible` states) goes there; hand-written CSS covers
  only what it cannot.
- **No `!important` to fight the framework.** Overriding a framework's `!important` with another
  one starts an escalation; the framework's own option is used instead (here, a constrained
  group justified left instead of overriding the layout's centring margins). Found when a
  reading-measure rule pulled a paragraph off its heading's alignment twice.
- **Readable source, comments on why.** No single minified string as source; each rule group
  says why it exists. Minifying, if ever wanted, is a build step.
- **One file per component, loaded only where used** (in WordPress `wp_enqueue_block_style()`),
  versioned for cache busting.
- **A linter in the checks** (here Stylelint with the WordPress configuration), pinned like every
  other tool.
- **Accessibility is part of every style change:** contrast (4.5:1 text, 3:1 large text and
  interface edges), a visible `:focus-visible` style, motion behind
  `prefers-reduced-motion`, touch targets of at least 24 × 24 px, no sideways scrolling at
  phone width.
- **A text colour change is checked against every background it sits on,** not only the main
  one (the light warm grey was checked on black and on the grey band).
- **Load order is part of the design; selectors should not depend on it.** Moving rules from one
  place to another can change which of two equally specific rules wins. In WordPress, block
  stylesheets print before the global styles, and the global styles write the theme's element
  styles as `:root :where(…)`, as specific as one class. A dependency on `global-styles` fixed the
  order but WordPress logs a notice for it (the handle is registered only after the blocks
  render), so each component's main selector names its block as well
  (`.wp-block-group.site-section`, `.wp-block-button .wp-block-button__link`): two classes win
  at any load order. The reason is commented where it applies, so the extra class is not taken
  for carelessness.
- **Site-wide rules belong to the platform's global styles; components carve out exceptions.**
  The paragraph colour is one theme.json setting for every paragraph; the call-to-action band and
  the media placeholder set their own, each saying why. A component that re-declares the global
  colour for its own paragraphs would scatter one decision across many files.
- **Layout constraints use the framework's layout settings.** A reading measure is a constrained
  group with the measure token as its content width (WordPress generates the rule), not a
  max-width fighting the layout's own margins.
- **Every registry is checked against what it lists.** A list of components that load by name
  fails silently when a name and a file drift apart; `bin/check` compares them both ways.
- **A restructuring is proven by pixel comparison.** Reference screenshots of every page at two
  widths before, the same after, compared pixel by pixel: "looks the same" is not a check. It
  found the load-order fault at once.
- **Name components by structure, not subject** (`site-hero`, `site-cta`, not `music-hero` or
  `book-band`), so a template serves any kind of site; subject-specific styles live with the
  feature that brings them (the song table's in the Song List plugin).
- **A visual check must fail on a missing page.** The first screenshot runs "passed" while 20 of
  24 screenshots showed an error page, matched against an equally broken baseline; each page is
  now required to answer 200, and outside services are answered locally so a screenshot depends
  on nothing but the site.
- **Verify by looking, at more than one width.** Each change was screenshotted at desktop and
  phone width; two layout faults showed only at desktop width.
