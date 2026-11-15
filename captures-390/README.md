# Screenshots for the review of the 390 px rendering lot (not for merging)

This branch only hosts the images shown in the pull request that aligns the app's rendering
on the web application's. Each image puts side by side, at 390 x 844 (an iPhone), in French:

- the web application at its reference commit (v0.3.1, `f4e732b`), with its demonstration data
  (`manage.py load_demo_data --language fr`, one item and one contractor added), in headless
  Chromium at device scale factor 3 (`tool/web_parity.py`);
- the app before the lot (`main` at `7af293b`), and the app after it, drawn by
  `test/web_parity_test.dart` with the same data
  (`flutter test --update-goldens --dart-define=PARITY_CAPTURE=true test/web_parity_test.dart`).

The images are reduced to a third (one pixel per logical pixel).
