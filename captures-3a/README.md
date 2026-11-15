# Screenshots for the review of lot 3a, the stock (not for merging)

This branch only hosts the images shown in the pull request of lot 3a. The files `*-fr.png` put
side by side, at 390 x 844 (an iPhone), in French:

- on the left, the web application at the commit pinned in `tool/web_alignment.json` (v0.3.2,
  `a76837f`), with its demonstration data and the three stock items, the supplier and the
  movements that `tool/web_parity.py` describes, in headless Chromium at device scale factor 3;
- on the right, the app drawn by `test/web_parity_test.dart` with the same data
  (`flutter test --update-goldens --dart-define=PARITY_CAPTURE=true test/web_parity_test.dart`).

The images are reduced to one pixel per logical pixel. The files `golden-*.png` are copies of
golden files of the pull request (360 px, English and French, text scale 1 and 2), with the
neutral data of `test/support/lot3a.dart`.
