// SPDX-License-Identifier: AGPL-3.0-only

/// What a search compares: the text in lower case and without the accents of
/// the Latin alphabets the app is written in, so that `ecole` finds `École`
/// and `ETE` finds `été`. The web matches without regard to case only (its
/// database's `icontains`); folding the accents too never hides a result the
/// web shows.
String foldForSearch(String text) {
  final lower = text.toLowerCase();
  var plain = true;
  for (var i = 0; i < lower.length; i++) {
    if (lower.codeUnitAt(i) > 127) {
      plain = false;
      break;
    }
  }
  if (plain) return lower;
  final out = StringBuffer();
  for (final rune in lower.runes) {
    out.write(_folded[rune] ?? String.fromCharCode(rune));
  }
  return out.toString();
}

/// Whether the already folded [needle] (see [foldForSearch]) is in one of the
/// already folded [haystacks], as the web's search matches: the whole text
/// typed, anywhere in a field. An empty needle matches everything.
bool matchesSearch(String needle, Iterable<String> haystacks) {
  if (needle.isEmpty) return true;
  return haystacks.any((h) => h.contains(needle));
}

final Map<int, String> _folded = () {
  const groups = {
    'a': 'àáâãäåāăą',
    'c': 'çćĉċč',
    'd': 'ďđ',
    'e': 'èéêëēĕėęě',
    'g': 'ĝğġģ',
    'h': 'ĥħ',
    'i': 'ìíîïĩīĭįı',
    'j': 'ĵ',
    'k': 'ķ',
    'l': 'ĺļľŀł',
    'n': 'ñńņňŉ',
    'o': 'òóôõöøōŏő',
    'r': 'ŕŗř',
    's': 'śŝşš',
    't': 'ţťŧ',
    'u': 'ùúûüũūŭůűų',
    'w': 'ŵ',
    'y': 'ýÿŷ',
    'z': 'źżž',
    'oe': 'œ',
    'ae': 'æ',
    'ss': 'ß',
  };
  return {
    for (final entry in groups.entries)
      for (final rune in entry.value.runes) rune: entry.key,
  };
}();
