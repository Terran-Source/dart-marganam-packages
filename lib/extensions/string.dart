library marganam.extensions;

extension Trimmer on String {
  String get escapedTrim => RegExp.escape(trim());

  String trimming(String trimmer) {
    final pattern = RegExp(
      '^[${trimmer.escapedTrim}]+'
      '(.*(?<![${trimmer.escapedTrim}]+))'
      '[${trimmer.escapedTrim}]+',
      caseSensitive: true,
      multiLine: false,
      dotAll: true,
    );
    return trim().replaceAllMapped(pattern, (match) => match[1]!).trim();
  }

  String trimmed(List<String> trimmer) =>
      trimmer.fold(this, (str, trm) => str.trimming(trm));

  List<String> toList() => runes.map((e) => String.fromCharCode(e)).toList();

  Set<String> toSet() => Set.from(toList());
}

final _allowedCharacters =
    RegExp(r'[\w_]+', multiLine: false, unicode: true, dotAll: true);

extension CleanString on String {
  String escapeMessy([String escapeWith = '_']) => _allowedCharacters
      .allMatches(trim())
      .map((match) => match.group(0))
      .where((s) => null != s && s.isNotEmpty)
      .join(escapeWith);
}
