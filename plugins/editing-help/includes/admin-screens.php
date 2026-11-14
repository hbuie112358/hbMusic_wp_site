<?php
/**
 * The two places the guide appears in the admin: a box on the dashboard, and the guide's own
 * page under Dashboard. Both use WordPress's own admin markup and styles, so the plugin loads no
 * stylesheet or script.
 *
 * @package editing-help
 */

defined( 'ABSPATH' ) || exit;

/**
 * Adds the dashboard box for the people the guide is for.
 */
function editinghelp_add_dashboard_box(): void {
	if ( ! current_user_can( EDITINGHELP_CAPABILITY ) ) {
		return;
	}
	wp_add_dashboard_widget(
		'editinghelp_dashboard_box',
		__( 'Editing help', 'editing-help' ),
		'editinghelp_render_dashboard_box'
	);
}
add_action( 'wp_dashboard_setup', 'editinghelp_add_dashboard_box' );

/**
 * Adds the guide's page under Dashboard; WordPress shows it only to users with the capability.
 */
function editinghelp_add_guide_page(): void {
	add_dashboard_page(
		__( 'Editing help', 'editing-help' ),
		__( 'Editing help', 'editing-help' ),
		EDITINGHELP_CAPABILITY,
		EDITINGHELP_PAGE_SLUG,
		'editinghelp_render_guide_page'
	);
}
add_action( 'admin_menu', 'editinghelp_add_guide_page' );

/**
 * The guide's address in the admin.
 *
 * @return string
 */
function editinghelp_guide_url(): string {
	return admin_url( 'index.php?page=' . EDITINGHELP_PAGE_SLUG );
}

/**
 * Why the guide matters, in two sentences; it opens both the box and the page.
 */
function editinghelp_print_purpose(): void {
	esc_html_e( "Edits can quietly make your site harder for customers to find. This guide keeps your pages easy to find in search engines and easy for everyone to read: headings, links, pictures, videos, ready-made sections and each page's search title.", 'editing-help' );
}

/**
 * The dashboard box: the purpose and the way to the guide.
 */
function editinghelp_render_dashboard_box(): void {
	?>
	<p><?php editinghelp_print_purpose(); ?></p>
	<p>
		<a class="button button-primary" href="<?php echo esc_url( editinghelp_guide_url() ); ?>"><?php esc_html_e( 'Read the guide', 'editing-help' ); ?></a>
	</p>
	<p><?php esc_html_e( "This site's templates and ready-made sections are listed at the end.", 'editing-help' ); ?></p>
	<?php
}

/**
 * The guide's page: the purpose, the guide, then this site's own parts and the guide's version.
 */
function editinghelp_render_guide_page(): void {
	?>
	<div class="wrap">
		<h1><?php esc_html_e( 'Editing help', 'editing-help' ); ?></h1>
		<p><?php editinghelp_print_purpose(); ?></p>
		<?php require __DIR__ . '/../templates/guide.php'; ?>
		<?php editinghelp_render_site_section(); ?>
		<p class="description">
			<?php
			/* translators: %s: the guide's version number. */
			echo esc_html( sprintf( __( 'Guide version %s', 'editing-help' ), EDITINGHELP_GUIDE_VERSION ) );
			?>
		</p>
	</div>
	<?php
}

/**
 * "Your site": the page templates, the ready-made sections and who to ask.
 */
function editinghelp_render_site_section(): void {
	$patterns = editinghelp_theme_patterns();
	?>
	<h2><?php esc_html_e( 'Your site', 'editing-help' ); ?></h2>
	<h3><?php esc_html_e( 'Page templates', 'editing-help' ); ?></h3>
	<p><?php esc_html_e( 'Chosen in the page\'s settings, under "Template".', 'editing-help' ); ?></p>
	<?php editinghelp_render_parts_table( editinghelp_page_templates(), __( 'Template', 'editing-help' ) ); ?>
	<h3><?php esc_html_e( 'Ready-made sections', 'editing-help' ); ?></h3>
	<?php if ( array() === $patterns ) : ?>
		<p><?php esc_html_e( 'This site has no ready-made sections yet.', 'editing-help' ); ?></p>
	<?php else : ?>
		<?php editinghelp_render_parts_table( $patterns, __( 'Section', 'editing-help' ) ); ?>
	<?php endif; ?>
	<?php
	editinghelp_render_contact();
}

/**
 * A two-column table of the site's parts, in WordPress's own table style.
 *
 * @param EditingHelp_Site_Part[] $parts        The lines.
 * @param string                  $name_heading The first column's heading.
 */
function editinghelp_render_parts_table( array $parts, string $name_heading ): void {
	?>
	<table class="widefat striped">
		<thead>
			<tr>
				<th scope="col"><?php echo esc_html( $name_heading ); ?></th>
				<th scope="col"><?php esc_html_e( 'What it does', 'editing-help' ); ?></th>
			</tr>
		</thead>
		<tbody>
			<?php foreach ( $parts as $part ) : ?>
				<tr>
					<td><?php echo esc_html( $part->name ); ?></td>
					<td><?php echo esc_html( $part->description ); ?></td>
				</tr>
			<?php endforeach; ?>
		</tbody>
	</table>
	<?php
}

/**
 * The "Questions" line, when the site gives a contact: an email address becomes a link.
 */
function editinghelp_render_contact(): void {
	$contact = editinghelp_contact();
	if ( '' === $contact ) {
		return;
	}
	?>
	<p>
		<?php esc_html_e( 'Questions:', 'editing-help' ); ?>
		<?php if ( is_email( $contact ) ) : ?>
			<a href="<?php echo esc_url( 'mailto:' . $contact ); ?>"><?php echo esc_html( $contact ); ?></a>
		<?php else : ?>
			<?php echo esc_html( $contact ); ?>
		<?php endif; ?>
	</p>
	<?php
}
