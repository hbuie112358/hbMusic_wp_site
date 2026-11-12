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
- **An exact visual comparison means exact in every dimension.** Playwright's comparison has a
  pixel count and a per-pixel colour tolerance; with only the count at zero, a subtle gradient and
  glow on the buttons passed as "identical". For subtle polish, both are zero.
- **Components talk through custom properties, not stronger selectors.** A band that needs its
  buttons different (no glow on green, a white focus ring) sets `--site-button-shadow`,
  `--site-button-shadow-raised` and `--site-focus-ring-color`; the button component reads them with
  its own defaults. The contract is written at the top of the component.
- **Equal size includes the border.** An outlined button beside a filled one was 4px larger
  because only its padding matched (the user noticed it by pointing at both); every button now
  carries the same border width, transparent where it should not show, and a test compares
  their heights.
- **The parent theme has its own interaction states.** Twenty Twenty-Five turned the main button
  beige on hover; hover and focus colours are set in `theme.json` (`elements.button` `:hover`,
  `:focus`), WordPress's own place for them.
- **Interaction states need their own checks.** axe sees the page at rest; hover, focus and
  reduced-motion behaviour get browser tests (ring width, ring contrast against its band, no
  movement with reduced motion), each shown failing on a planted fault.
- **Judge interaction in a browser, not in still pictures.** The user could not tell much from
  screenshots and judged the buttons live on the dev site; screenshots stay the record of what
  changed.
- **A sticky element sticks within its parent.** Making the theme's own header sticky did
  nothing: WordPress wraps it in a template-part element of exactly its height. The wrapper,
  a direct child of the page, is the one that sticks (`header.wp-block-template-part:has(> …)`).
- **A sticky header owes the page its height.** `scroll-padding-top` set from the same values
  that size the header (one custom property for both), so the browser never scrolls a focused
  link or a jump target under it (WCAG 2.2, 2.4.11); a test reaches a button with Shift+Tab and
  checks it lands below the header.
- **An inline style from the parent theme is the one justified `!important`,** scoped with
  `:has()` to exactly the pages it concerns and with its reason in the required disable comment.
- **Measure before fixing.** The "black strip" was traced element by element to 70px of template
  padding plus 19px of footer margin before any rule was written.
- **Check a design at the widths people use, not one.** The 40-60 hero looked right at 1280px;
  the user's narrower window broke the headline differently. A sweep of ten widths showed where.
- **Zero specificity can lose.** A `:where()` rule meant to be easy to override was itself
  overridden by WordPress's element rule (`h1 { text-wrap: pretty }`); the block's class is the
  right weight.
- **Measure an image before treating it.** A "grey edge" around the photo was a misreading of a
  scaled-down preview; the file and the browser both showed pure black (1 of 255). Sampling
  pixels settled it in a minute.
- **Blend modes act on the whole picture.** `mix-blend-mode: lighten` let a stage light through
  the photo's black background, but also through the black shirt; a cut-out with real
  transparency puts light behind the figure only.
- **Lay out by the container, not one screen width.** Two buttons wrapped wherever their column
  got too narrow (782-900px and on phones); equal flexible widths (`flex: 1 1 0` with a
  `max-content` minimum) keep them the same length at every width, where a breakpoint would not.
- **A texture is checked for contrast at its brightest speck,** not its average: white text on
  the grainy green band fell to 4.7:1 there, so its grain is at half strength.
- **New platform features as progressive enhancement.** CSS's native carousel buttons exist only
  in Chromium so far; the carousel works everywhere without them (snap, swipe, scrollbar), and
  browsers that have them show them. The decision was checked against MDN's status first.
- **A linter lagging the language is configured, not silenced in place:** the config names the
  exact new syntax it does not know yet, with the reason and when to remove it.
- **A scrolling region needs keyboard access of its own.** Browsers do not reliably make a
  scrolling row focusable; axe caught it, and the theme adds `tabindex="0"` with a focus ring at
  render time. The assumption that the browser would handle it was wrong.
- **Snap the last slide to the end.** A last snap point the row can never reach is approximated
  and can stop a fraction short, which left the "next" button showing in one browser. (Later,
  with every slide centred: equal spacers before the first and after the last make each
  centre stop reachable exactly.)
- **Use the framework's own setting before adding a token.** The page's frame first became a
  custom token; WordPress's wide width (`settings.layout.wideSize`) already is that value, and its
  wide blocks follow it with no extra rule. Page content, too, names the variable, never the
  number: a width repeated in content drifts from the theme the first time the theme changes.
- **Size a component's parts against the component with container units.** Percentages in a grid
  refer to the track, not the row; `container-type: inline-size` and `cqi` give the row's own width.
- **A shared behaviour is one component, joined by a class, not copied.** The three panels first
  each copied the frame width and corners; their spacing then disagreed and two panels touched.
  An exception per pair would have patched it; one `site-panel` class and file fixed the cause,
  and a new panel needs no CSS (the user asked why one would exclude rather than conform).
- **Page spacing belongs to the template, not to the last block.** Removing the template's
  padding with `!important` for one kind of last block, then adding the block's own margin,
  gave each template a different result; the template's own spacing needs no override.
- **Content names, the theme decides.** Page content that carries sizes or repeated pieces
  (a width on every band, the same call to action on four pages) needs pasting again whenever
  the look changes. Content carrying only component names and WordPress's own alignments, with
  repeated pieces in template parts, takes every later change from the theme folder.
- **Style by role, not by heading level.** `.site-section h2` tied the look to the level; an
  editor fixing the outline for screen readers would change the look. `.wp-block-heading`
  within the component, with `>` where a component holds others' headings, separates the two.
- **A child theme's lists replace the parent's.** `templateParts` with one new entry dropped the
  header's and footer's areas (rendered as `div`s, the sticky header broke); tests caught it.
- **One frame, every part:** a full-width band whose colour differs from the page shows where the
  frame ends; the eye then measures everything else (the menu looked misplaced) against it.
- **In browsers without native controls, the scrollbar is the control;** coloured in the accent,
  checked for 3:1 like any control.
- **Judge in the browsers visitors use.** VS Code's built-in browser behaved differently from
  Chrome; design decisions are checked in Chrome or Edge and Firefox.
- **An accent colour is for accents.** Green on a whole band and on every control "honked" (the
  user); used only on what can be pressed, with the band a dark fog, the main button draws more
  attention, not less, and every text gained contrast.
- **Show options live, not only as pictures.** Three fog versions on temporary local pages let the
  user judge in a real browser; the pages were deleted after the choice.
- **Mock-ups injected after load can catch a transition mid-way.** The first fog mock-ups showed
  a faded button; the colour fade was still running. A pause before the screenshot fixed it.
- **Verify by looking, at more than one width.** Each change was screenshotted at desktop and
  phone width; two layout faults showed only at desktop width.
