// The paths of the test pages bin/dev-site creates (TEST_PAGES; "Home" is the front page), shared
// by the specs that check every page. Fixed here, not read from the site's menu: a page missing
// from the menu must still fail.
export const TEST_PATHS = ['/', '/music/', '/songlist/', '/about/', '/book/', '/privacy-policy/'];
