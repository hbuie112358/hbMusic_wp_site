<?php
/**
 * Plugin Name:       Editing Help
 * Description:       Shows the content guide inside WordPress: an "Editing help" box on the dashboard and a page with the guide, ending with the site's own page templates and ready-made sections, read from the active theme. Each site adds its templates' descriptions and a contact line.
 * Version:           0.1.0
 * Requires at least: 7.0
 * Requires PHP:      8.4
 * License:           GPL-2.0-or-later
 * License URI:       https://www.gnu.org/licenses/gpl-2.0.html
 * Text Domain:       editing-help
 * Update URI:        false
 *
 * "Update URI: false" keeps WordPress from offering a plugin of the same name from WordPress.org
 * as an update of this one, which would replace the site's code with a stranger's.
 *
 * @package editing-help
 */

defined( 'ABSPATH' ) || exit;

/**
 * The guide's version, shown at the bottom of its page. The company's printed copy of the guide
 * carries the same number, and a change is made to both at once, so a copy left behind shows.
 */
const EDITINGHELP_GUIDE_VERSION = '1';

/**
 * WordPress's right to edit content. Administrators, Editors and Authors have it, and they are
 * the people who edit pages, so they are the ones the guide is for.
 */
const EDITINGHELP_CAPABILITY = 'edit_posts';

/**
 * The guide page's name in its address (wp-admin/index.php?page=editing-help).
 */
const EDITINGHELP_PAGE_SLUG = 'editing-help';

require_once __DIR__ . '/includes/class-editinghelp-site-part.php';
require_once __DIR__ . '/includes/site-parts.php';
require_once __DIR__ . '/includes/admin-screens.php';
