#!/usr/bin/env python3
"""Checks the committed configuration of the TestFlight workflow (lot 1b).

Run by the `plan` job of .github/workflows/ios-testflight.yml on every event,
pull requests included, so a broken export options file is seen before a merge
and not on the first upload. Standard library only.

Checks:
- ios/ExportOptions-testflight.plist parses, uploads to App Store Connect with
  automatic signing, and holds no teamID (it is added at run time);
- ios/Runner/Info.plist takes its build number and version from Flutter, so the
  number given by the workflow reaches the build, and declares
  ITSAppUsesNonExemptEncryption (export compliance, see ADR 0009).

Usage: check_testflight_config.py [repository root]   (default: current directory)
"""

import plistlib
import sys
from pathlib import Path

EXPECTED_EXPORT = {
    "method": "app-store-connect",
    "destination": "upload",
    "signingStyle": "automatic",
    "manageAppVersionAndBuildNumber": False,
}
EXPECTED_INFO = {
    "CFBundleVersion": "$(FLUTTER_BUILD_NUMBER)",
    "CFBundleShortVersionString": "$(FLUTTER_BUILD_NAME)",
}


def check(root: Path) -> list[str]:
    errors: list[str] = []
    export_path = root / "ios" / "ExportOptions-testflight.plist"
    info_path = root / "ios" / "Runner" / "Info.plist"
    try:
        export = plistlib.loads(export_path.read_bytes())
        info = plistlib.loads(info_path.read_bytes())
    except (OSError, plistlib.InvalidFileException, ValueError) as error:
        return [f"cannot read a property list: {error}"]

    for key, value in EXPECTED_EXPORT.items():
        if export.get(key) != value:
            errors.append(f"{export_path.name}: {key} is {export.get(key)!r}, expected {value!r}")
    if "teamID" in export:
        errors.append(f"{export_path.name}: teamID must not be committed (added at run time)")
    for key, value in EXPECTED_INFO.items():
        if info.get(key) != value:
            errors.append(f"Info.plist: {key} is {info.get(key)!r}, expected {value!r}")
    # Presence only: the value is the maintainer's decision, revisited in lot 5.
    if not isinstance(info.get("ITSAppUsesNonExemptEncryption"), bool):
        errors.append("Info.plist: ITSAppUsesNonExemptEncryption must be declared (true or false)")
    return errors


def main() -> int:
    root = Path(sys.argv[1]) if len(sys.argv) > 1 else Path.cwd()
    errors = check(root)
    for error in errors:
        print(f"::error::{error}")
    if errors:
        return 1
    print("TestFlight configuration: export options and Info.plist are as expected.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
