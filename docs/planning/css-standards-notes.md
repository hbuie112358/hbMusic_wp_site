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
- **Verify by looking, at more than one width.** Each change was screenshotted at desktop and
  phone width; two layout faults showed only at desktop width.
