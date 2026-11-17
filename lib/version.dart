// SPDX-License-Identifier: AGPL-3.0-only

/// Address of the source code, shown on the About screen (AGPL-3.0,
/// section 13: the source of a modified version must be offered).
///
/// The version of the app is not here: the About screen reads it from the
/// platform at run time (package_info_plus), where it comes from the
/// `version` of pubspec.yaml.
const sourceAddress = 'github.com/HouseCairn/housecairn-mobile';

/// Address of the public iPhone beta (TestFlight), shown on the About screen
/// with two actions: open it, copy it. The only place that writes it.
const testFlightAddress = 'https://testflight.apple.com/join/eygTuxTT';

/// The links of the About screen, as the web's `core/about_links.py`: the
/// project site and the repositories. The documentation is
/// `docsAddress` (help_button.dart); the Android store has no address yet.
const siteAddress = 'https://housecairn.app';
const webSourceAddress = 'https://github.com/HouseCairn/housecairn';
const addonAddress = 'https://github.com/HouseCairn/home-assistant-addons';
const integrationAddress =
    'https://github.com/HouseCairn/home-assistant-housecairn';
