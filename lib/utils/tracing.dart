library marganam.utils.tracing;

/// Get the parsed StackTrace
///
/// As described in https://stackoverflow.com/a/60022328
class Tracing {
  final StackTrace stackTrace;
  late RegExpMatch _match;

  /// Define regex for each entry in the stack
  ///
  /// group 0: full line
  ///
  /// group 1: stack index
  ///
  /// group 2: function name
  ///
  /// group 3: package
  ///
  /// group 4: file name
  ///
  /// group 5: line number
  ///
  /// group 6: column number
  /// ```dart
  /// final _matchList = {
  ///   0: 'trace',
  ///   1: 'stackIndex',
  ///   2: 'functionName',
  ///   3: 'package',
  ///   4: 'fileName',
  ///   5: 'lineNumber',
  ///   6: 'columnNumber',
  /// };
  /// ```
  final RegExp _regExp =
      RegExp(r'^#(\d+) +(.+) +\(package:([^/]+)/(.+\.\w):(\d+):(\d+)\)$');

  Tracing(this.stackTrace) {
    final frames = stackTrace.toString().split('\n');
    final matches = _regExp.allMatches(frames[1]);
    _match = matches.elementAt(0);
  }

  String? get trace => _match.group(0);
  String? get stackIndex => _match.group(1);
  String? get functionName => _match.group(2);
  String? get package => _match.group(3);
  String? get fileName => _match.group(4);
  String? get lineNumber => _match.group(5);
  String? get columnNumber => _match.group(6);
  String? get identifier => '$package.$functionName';
}
