library marganam.extensions;

import 'dart:io';
import 'package:path/path.dart' as p;

extension FileSystemExtension on FileSystemEntity {
  String get name => p.basename(path);
  String get basePath => p.dirname(path);
}
