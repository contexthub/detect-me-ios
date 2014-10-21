DetectMe (Beacons) Release Notes
---

## v1.1.4 (Build 248) - October 21, 2014
- Update to ContextHub v1.3.3 framework
- Update compatability for iPhone 6 and iPhone 6 Plus
- Only show simulator warning once

## v1.1.3 (Build 241) - September 16, 2014
- Update to ContextHub v1.3.1 framework
- Update compatibility for iOS 8 
- Add NSLocationAlwaysUsageDescription key and description to Info.plist

## v1.1.2 (Build 228) - August 17, 2014
- Update to ContextHub v1.2.0 framework
- Add Table of Contents to README

## v1.1.1 (Build 227) - August 10, 2014
- Fix bug where app would crash when updating and deleting beacons
- Fix bug where proximity state was not changing when "near" or "far"
- Added better event handling for differences between "beacon_in"/"beacon_out" and "beacon_changed" events
- Added alert when trying to run the sample app with the iOS Simulator (beacons only work with real iOS device w/ Bluetooth 4.0)
- Commented out logging statements in DMAppDelegate (uncomment them if you want them back)
- Made footer text in About view readable
- Updated README

## v1.1.0 (Build 181) - August 8, 2014
- Rewrite sample app to more directly show how to use the SDK (previous version still available in separate branch)
- Updated README

## v1.0.0 (Build 161) - August 4, 2014
- Initial release