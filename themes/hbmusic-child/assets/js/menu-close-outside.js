/**
 * Closes the open hamburger menu when the visitor taps or clicks the page outside it (plan 9t-5;
 * the user: "clicking on the page while it's visible should hide it").
 *
 * WordPress closes its menu when the focus leaves it for nothing, which is what most browsers do
 * when a plain part of the page is tapped; Safari on iPhones moves no focus there, so the menu
 * stayed open beside the page (found on live, 2026-11-17). This presses the menu's own close
 * button instead of closing it by other means, so WordPress keeps doing the closing and returns the
 * focus as it always does. Taps inside the open menu, the close button included, are WordPress's.
 *
 * "pointerdown" rather than "click": Safari sends no click for a tap on plain text. Without this
 * script the menu still closes with its button, Escape, or a tap on a link or button.
 */
( () => {
	'use strict';

	const OPEN_PANEL_SELECTOR = '.wp-block-navigation__responsive-container.is-menu-open';
	const CLOSE_BUTTON_SELECTOR = '.wp-block-navigation__responsive-container-close';

	/**
	 * Presses the open menu's close button when a press lands outside the menu.
	 *
	 * @param {PointerEvent} event The press.
	 */
	function closeMenuOnPressOutside( event ) {
		const panel = document.querySelector( OPEN_PANEL_SELECTOR );
		const pressed = event.target;
		if ( ! panel || ! ( pressed instanceof Node ) || panel.contains( pressed ) ) {
			return;
		}
		const closeButton = panel.querySelector( CLOSE_BUTTON_SELECTOR );
		if ( closeButton instanceof HTMLElement ) {
			closeButton.click();
		}
	}

	document.addEventListener( 'pointerdown', closeMenuOnPressOutside );
} )();
