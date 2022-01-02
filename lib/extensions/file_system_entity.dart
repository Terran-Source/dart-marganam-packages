library marganam.extensions.file_system_entity;

import 'dart:io';
import 'package:path/path.dart' as p;

extension FileSystemExtension on FileSystemEntity {
  String get name => p.basename(path);
  String get basePath => p.dirname(path);
}
