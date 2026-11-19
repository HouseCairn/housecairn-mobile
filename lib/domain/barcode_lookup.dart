// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:convert';
import 'dart:typed_data';

import 'gtin.dart';

/// What a lookup of a scanned code says (web ADR 0083): the states of the
/// web's answer (`barcodes/api.py`, `BarcodeAnswer`), and two of the phone's
/// own: [unavailable] (the server does not open its lookup to the app) and
/// [offline] (no answer at all).
enum LookupState {
  /// Ask again in two seconds (a server only).
  running,
  done,
  notFound,
  failed,

  /// The lookup is off: on the server, or refused on this phone.
  off,

  /// The server refused the app on its lookup (web v0.5.1 opens only its
  /// sync API to a connected app, `connection_outside_sync`).
  unavailable,

  /// No connection, or no answer in time.
  offline,

  /// Too many codes looked up in a short time (the server's rate limit).
  limited,
}

/// Who a source's data and photos come from, under which licence
/// (`barcodes.providers.Attribution`).
class LookupSource {
  const LookupSource({
    required this.name,
    required this.label,
    required this.host,
    required this.imageHost,
  });

  /// The key the web keeps in its cache (`openproductsfacts`).
  final String name;

  /// Shown to people.
  final String label;

  /// Where its read API is.
  final String host;

  /// Where its photos are.
  final String imageHost;

  String get homeUrl => 'https://$host';

  /// The licence of the photos.
  static const license = 'CC BY-SA 3.0';
  static const licenseUrl = 'https://creativecommons.org/licenses/by-sa/3.0/';

  /// The licence of the data.
  static const dataLicense = 'ODbL';
  static const dataLicenseUrl =
      'https://opendatacommons.org/licenses/odbl/1-0/';
}

/// The sources, in the order of the lookup (`barcodes.providers.PROVIDERS`):
/// the first that knows the code answers.
const lookupSources = [
  LookupSource(
    name: 'openproductsfacts',
    label: 'Open Products Facts',
    host: 'world.openproductsfacts.org',
    imageHost: 'images.openproductsfacts.org',
  ),
  LookupSource(
    name: 'openfoodfacts',
    label: 'Open Food Facts',
    host: 'world.openfoodfacts.org',
    imageHost: 'images.openfoodfacts.org',
  ),
];

/// Every host the lookup may call: the read APIs and the photos of the
/// sources, nothing else (lib/core/open_facts_http_io.dart refuses any
/// other before it connects).
final lookupApiHosts = {for (final s in lookupSources) s.host};
final lookupImageHosts = {for (final s in lookupSources) s.imageHost};

/// The fields asked of a source: those the web asks, nothing else.
const lookupFields =
    'code,product_name,brands,categories,image_front_url,image_url,creator';

/// The one address a lookup reads at [source]: only the code is in it.
Uri lookupUrl(LookupSource source, String code) => Uri.https(
  source.host,
  '/api/v2/product/${asPublishedGtin(code)}.json',
  {'fields': lookupFields},
);

/// The page of the product at [source], for its attribution.
String productPage(LookupSource source, String code) =>
    'https://${source.host}/product/${asPublishedGtin(code)}';

/// The answer of a lookup, for the form that fills itself from it.
class BarcodeAnswer {
  const BarcodeAnswer(
    this.code,
    this.state, {
    this.source = '',
    this.sourceLabel = '',
    this.name = '',
    this.brand = '',
    this.model = '',
    this.category = '',
    this.productUrl = '',
    this.author = '',
    this.license = '',
    this.licenseUrl = '',
    this.imageUrl = '',
    this.hasPhoto = false,
    this.photo,
  });

  final String code;
  final LookupState state;
  final String source;
  final String sourceLabel;
  final String name;
  final String brand;
  final String model;
  final String category;
  final String productUrl;
  final String author;
  final String license;
  final String licenseUrl;

  /// Where the photo is at the source (alone only; a server gives the bytes).
  final String imageUrl;
  final bool hasPhoto;

  /// The photo as it came, not yet re-encoded; `null` when there is none or
  /// it could not be read.
  final Uint8List? photo;

  BarcodeAnswer withPhoto(Uint8List? bytes) => BarcodeAnswer(
    code,
    state,
    source: source,
    sourceLabel: sourceLabel,
    name: name,
    brand: brand,
    model: model,
    category: category,
    productUrl: productUrl,
    author: author,
    license: license,
    licenseUrl: licenseUrl,
    imageUrl: imageUrl,
    hasPhoto: bytes != null,
    photo: bytes,
  );

  /// The credit stored with the photo and shown under it, with the keys of
  /// the web (`barcodes.services.photo_of`).
  Map<String, String> get attribution => {
    'source': sourceLabel,
    'source_url': productUrl,
    'license': license,
    'license_url': licenseUrl,
    'author': author,
  };
}

/// A string of the answer on one line, cut to [length]; `''` for anything
/// else (`barcodes.providers.text`).
String _text(Object? value, int length) {
  if (value is! String) return '';
  final line = value.replaceAll('\u0000', '').trim().split(RegExp(r'\s+'));
  final joined = line.join(' ');
  return joined.length > length ? joined.substring(0, length) : joined;
}

String _cut(String value, int length) =>
    value.length > length ? value.substring(0, length) : value;

/// What the answer of [source] says of [code]; `null` when the source does
/// not know it (`OpenFactsProvider.parse`). The answer is JSON read with
/// `jsonDecode`, never run.
BarcodeAnswer? parseOpenFacts(
  LookupSource source,
  String code,
  List<int> body,
) {
  final Object? data;
  try {
    data = jsonDecode(utf8.decode(body, allowMalformed: true));
  } on FormatException {
    return null;
  }
  if (data is! Map || data['status'] != 1) return null;
  final product = data['product'];
  if (product is! Map) return null;
  final brands = _text(product['brands'], 300);
  final categories = _text(product['categories'], 600);
  var image = _text(product['image_front_url'], 500);
  if (image.isEmpty) image = _text(product['image_url'], 500);
  final imageUri = Uri.tryParse(image);
  if (imageUri == null ||
      imageUri.scheme != 'https' ||
      !lookupImageHosts.contains(imageUri.host)) {
    image = '';
  }
  final answer = BarcodeAnswer(
    code,
    LookupState.done,
    source: source.name,
    sourceLabel: source.label,
    name: _text(product['product_name'], 200),
    brand: _cut(brands.split(',').first.trim(), 120),
    category: categories.isEmpty
        ? ''
        : _cut(categories.split(',').last.trim(), 200),
    imageUrl: image,
    hasPhoto: image.isNotEmpty,
    author: _text(product['creator'], 120),
    productUrl: productPage(source, code),
    license: LookupSource.license,
    licenseUrl: LookupSource.licenseUrl,
  );
  if (answer.name.isEmpty && answer.brand.isEmpty && answer.imageUrl.isEmpty) {
    return null;
  }
  return answer;
}

/// The answer of a server (`barcodes/api.py`, `BarcodeAnswer`).
BarcodeAnswer parseServerAnswer(String code, Map<String, Object?> json) {
  String s(String key) => json[key] is String ? json[key]! as String : '';
  final state = switch (json['state']) {
    'running' => LookupState.running,
    'done' => LookupState.done,
    'not_found' => LookupState.notFound,
    'failed' => LookupState.failed,
    _ => LookupState.off,
  };
  return BarcodeAnswer(
    code,
    state,
    source: s('source'),
    sourceLabel: s('source_label'),
    name: _text(s('name'), 200),
    brand: _text(s('brand'), 120),
    model: _text(s('model'), 120),
    category: _text(s('category'), 200),
    productUrl: s('product_url').startsWith('https://') ? s('product_url') : '',
    author: _text(s('author'), 120),
    license: s('license'),
    licenseUrl: s('license_url').startsWith('https://') ? s('license_url') : '',
    hasPhoto: json['has_photo'] == true,
  );
}

/// Which form is filled.
enum LookupTarget { item, article }

/// The fields of the form of [target] and what the answer puts in each, if
/// it is empty (`barcodes.views.fill_values`).
Map<String, String> fillValues(BarcodeAnswer answer, LookupTarget target) {
  final category = answer.category;
  final Map<String, String> values;
  if (target == LookupTarget.article) {
    var name = answer.name;
    if (answer.brand.isNotEmpty &&
        !name.toLowerCase().contains(answer.brand.toLowerCase())) {
      name = '${answer.brand} $name'.trim();
    }
    values = {
      'name': _cut(name, 120),
      'manufacturer_reference': _cut(answer.model, 120),
      'notes': category,
    };
  } else {
    values = {
      'name': _cut(answer.name, 120),
      'brand': _cut(answer.brand, 120),
      'model': _cut(answer.model, 120),
      'notes': category,
    };
  }
  return {
    for (final MapEntry(:key, :value) in values.entries)
      if (value.isNotEmpty) key: value,
  };
}

/// The credit of a photo stored with it, read back; `null` for a photo
/// without one (taken by a member).
Map<String, String>? readAttribution(String? json) {
  if (json == null || json.isEmpty) return null;
  try {
    final data = jsonDecode(json);
    if (data is! Map || data.isEmpty) return null;
    return {
      for (final MapEntry(:key, :value) in data.entries)
        if (key is String && value is String) key: value,
    };
  } on FormatException {
    return null;
  }
}
