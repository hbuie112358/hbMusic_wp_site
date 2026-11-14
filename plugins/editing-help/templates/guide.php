<?php
/**
 * The content guide (version EDITINGHELP_GUIDE_VERSION), printed inside the guide's page by
 * editinghelp_render_guide_page(). The company keeps a printed copy with the same version number;
 * a change is made to both at once.
 *
 * Every screen label named here ("View", "Mobile", "Patterns", "Code editor", "Revisions",
 * "Template", "SEO title", "Meta description") is checked against the real editor by the site's
 * browser tests, so an update that renames one is found instead of leaving the guide wrong. Each
 * is the label a sighted editor sees: the phone preview's icon shows "View" on hover, while
 * "View options", the name its menu gives screen readers, never appears on screen.
 *
 * @package editing-help
 */

defined( 'ABSPATH' ) || exit;
?>
<h2><?php esc_html_e( 'Who changes what', 'editing-help' ); ?></h2>
<ul>
	<li><?php esc_html_e( 'You change the content: pages, text and pictures.', 'editing-help' ); ?></li>
	<li><?php esc_html_e( 'DTS looks after the look (colors, fonts, spacing, layouts), the menus, the plugins and the settings. Ask DTS for any of these. Some are left out of your login on purpose, so they cannot be changed by accident.', 'editing-help' ); ?></li>
	<li><?php esc_html_e( "When you choose a color, a text size or a spacing, the choices offered are the site's own.", 'editing-help' ); ?></li>
</ul>

<h2><?php esc_html_e( 'Headings', 'editing-help' ); ?></h2>
<ul>
	<li><?php esc_html_e( "The page title is the page's one main heading.", 'editing-help' ); ?></li>
	<li><?php esc_html_e( 'Sections of the page use "Heading 2"; a part within a section uses "Heading 3". Levels are not skipped.', 'editing-help' ); ?></li>
	<li><?php esc_html_e( 'Bold text is not a heading. Screen readers and search engines find their way through a page by its heading levels.', 'editing-help' ); ?></li>
</ul>

<h2><?php esc_html_e( 'Links', 'editing-help' ); ?></h2>
<p>
	<?php
	/* translators: %s: an example of good link text from this site, such as "See our prices". */
	echo esc_html( sprintf( __( 'The link text says where the link goes: "%s", not "click here" or a bare web address.', 'editing-help' ), editinghelp_link_example() ) );
	?>
</p>

<h2><?php esc_html_e( 'Pictures', 'editing-help' ); ?></h2>
<ul>
	<li><?php esc_html_e( 'Use only pictures you have the right to use: your own, or ones you have permission for.', 'editing-help' ); ?></li>
	<li><?php esc_html_e( 'Photos as JPEG, at most about 2000 pixels wide. WordPress makes the smaller sizes itself.', 'editing-help' ); ?></li>
	<li><?php esc_html_e( 'Give each picture a short description of what it shows ("Alternative text"), for people who cannot see it. A picture that is only decoration gets none: leave the field empty.', 'editing-help' ); ?></li>
	<li><?php esc_html_e( 'Never put text inside a picture; put it on the page, where everyone can read it.', 'editing-help' ); ?></li>
</ul>

<h2><?php esc_html_e( 'Videos', 'editing-help' ); ?></h2>
<p><?php esc_html_e( 'Videos come from YouTube or a similar service: paste the video\'s address on a line of its own. The video must be public or unlisted, with embedding allowed in its settings, or the page shows "Video unavailable". Never upload a video file to the site.', 'editing-help' ); ?></p>

<h2><?php esc_html_e( 'Ready-made sections', 'editing-help' ); ?></h2>
<p><?php esc_html_e( 'Your site has ready-made sections, listed at the end of this page. Add one with the "+" button, under "Patterns". Never use the "Code editor": it can break the page\'s layout.', 'editing-help' ); ?></p>

<h2><?php esc_html_e( 'Documents', 'editing-help' ); ?></h2>
<p><?php esc_html_e( 'Make a page instead of a PDF wherever you can. PDFs are hard to read on phones and with screen readers.', 'editing-help' ); ?></p>

<h2><?php esc_html_e( 'Pasting text', 'editing-help' ); ?></h2>
<p><?php esc_html_e( 'Paste text without its formatting (Ctrl+Shift+V, or Cmd+Shift+V on a Mac). Text pasted from Word or an email brings hidden styles with it.', 'editing-help' ); ?></p>

<h2><?php esc_html_e( "Other people's details", 'editing-help' ); ?></h2>
<ul>
	<li><?php esc_html_e( "Publish other people's names, photos or contact details only with their consent.", 'editing-help' ); ?></li>
	<li><?php esc_html_e( "Before adding a form, or anything else that asks visitors for information, ask DTS: the site's privacy policy must be updated first.", 'editing-help' ); ?></li>
</ul>

<h2><?php esc_html_e( 'Before you publish', 'editing-help' ); ?></h2>
<p><?php esc_html_e( 'Look at the page as a phone shows it (the screen icon at the top, labeled "View", then "Mobile"), and look at it on a real phone too.', 'editing-help' ); ?></p>

<h2><?php esc_html_e( 'If something goes wrong', 'editing-help' ); ?></h2>
<p><?php esc_html_e( 'WordPress keeps the earlier versions of every page. In the page\'s settings, "Revisions" shows them and can restore an earlier one. Or ask DTS.', 'editing-help' ); ?></p>

<h2><?php esc_html_e( "Each page's search title and description", 'editing-help' ); ?></h2>
<p><?php esc_html_e( 'Search engines show these when your page appears in their results. They are in the Yoast SEO box below the page, as "SEO title" and "Meta description".', 'editing-help' ); ?></p>
<ul>
	<li><?php esc_html_e( 'SEO title: different on every page, about 50-60 characters, with the page\'s subject first. Keep the "Site title" part at the end: it adds your business name, so you do not type it.', 'editing-help' ); ?></li>
	<li><?php esc_html_e( 'Meta description: one or two plain sentences, about 120-155 characters, different on every page, saying what the page offers and, for a local business, where. Google sometimes shows its own text instead; that is normal.', 'editing-help' ); ?></li>
	<li><?php esc_html_e( 'Yoast\'s colored scores and its "focus keyphrase" are not targets. Accurate, natural text comes first.', 'editing-help' ); ?></li>
	<li><?php esc_html_e( 'DTS wrote them for every page at launch. Whoever adds a new page writes its own.', 'editing-help' ); ?></li>
</ul>

<h2><?php esc_html_e( 'Your login', 'editing-help' ); ?></h2>
<ul>
	<li><?php esc_html_e( 'Use your own login, and never share it.', 'editing-help' ); ?></li>
	<li><?php esc_html_e( 'Tell DTS when someone with a login to the site leaves.', 'editing-help' ); ?></li>
</ul>
