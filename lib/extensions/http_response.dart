library marganam.extensions;

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';

import 'string.dart';

/// Updated from https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types/Common_types
/// till 28th April, 2020 AC (After Corona) :P
final Map<String, String> mimeTypes = {
  'audio/aac': '.aac',
  'application/x-abiword': '.abw',
  'application/x-freearc': '.arc',
  'video/x-msvideo': '.avi',
  'application/vnd.amazon.ebook': '.azw',
  'application/octet-stream': '.bin',
  'image/bmp': '.bmp',
  'application/x-bzip': '.bz',
  'application/x-bzip2': '.bz2',
  'application/x-csh': '.csh',
  'text/css': '.css',
  'text/csv': '.csv',
  'application/msword': '.doc',
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
      '.docx',
  'application/vnd.ms-fontobject': '.eot',
  'application/epub+zip': '.epub',
  'application/gzip': '.gz',
  'image/gif': '.gif',
  'text/html': '.html',
  'image/vnd.microsoft.icon': '.ico',
  'text/calendar': '.ics',
  'application/java-archive': '.jar',
  'image/jpeg': '.jpg',
  'text/javascript': '.js',
  'application/json': '.json',
  'application/ld+json': '.jsonld',
  'audio/midi': '.midi',
  'audio/x-midi': '.midi',
  'audio/mpeg': '.mp3',
  'video/mpeg': '.mpeg',
  'application/vnd.apple.installer+xml': '.mpkg',
  'application/x-newton-compatible-pkg': '.pkg',
  'application/vnd.oasis.opendocument.presentation': '.odp',
  'application/vnd.oasis.opendocument.spreadsheet': '.ods',
  'application/vnd.oasis.opendocument.text': '.odt',
  'audio/ogg': '.oga',
  'video/ogg': '.ogv',
  'application/ogg': '.ogx',
  'audio/opus': '.opus',
  'font/otf': '.otf',
  'image/png': '.png',
  'application/pdf': '.pdf',
  'application/php': '.php',
  'application/vnd.ms-powerpoint': '.ppt',
  'application/vnd.openxmlformats-officedocument.presentationml.presentation':
      '.pptx',
  'application/vnd.rar': '.rar',
  'application/rtf': '.rtf',
  'application/x-sh': '.sh',
  'application/sql': '.sql',
  'image/svg+xml': '.svg',
  'application/x-shockwave-flash': '.swf',
  'application/x-tar': '.tar',
  'image/tiff': '.tiff',
  'video/mp2t': '.ts',
  'font/ttf': '.ttf',
  'text/plain': '.txt',
  'application/vnd.visio': '.vsd',
  'audio/wav': '.wav',
  'audio/webm': '.weba',
  'video/webm': '.webm',
  'image/webp': '.webp',
  'font/woff': '.woff',
  'font/woff2': '.woff2',
  'application/xhtml+xml': '.xhtml',
  'application/vnd.ms-excel': '.xls',
  'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet': '.xlsx',
  'application/xml': '.xml',
  'text/xml': '.xml',
  'application/vnd.mozilla.xul+xml': '.xul',
  'application/zip': '.zip',
  'video/3gpp': '.3gp',
  'audio/3gpp': '.3gp',
  'video/3gpp2': '.3g2',
  'audio/3gpp2': '.3g2',
  'application/x-7z-compressed': '.7z',
};

extension HttpHeaderParser on String {
  Map<String, dynamic> parseHeaderValue({
    String fieldSeparator = ';',
    String valueSeparator = '=',
    List<String> valueTrimmer = const ["'", '"'],
  }) {
    final fields = split(fieldSeparator).map((c) => c.trim());
    final result = <String, dynamic>{};
    for (final field in fields) {
      if (field.contains(valueSeparator)) {
        final parts = field.split(valueSeparator);
        result[parts[0].trim()] = parts[1].trimmed(valueTrimmer);
      } else {
        result[field] = true;
      }
    }
    return result;
  }
}

const _defaultCharset = 'utf-8';

extension HttpResponseExtension on BaseResponse {
  bool get isSuccessStatusCode => 200 <= statusCode && statusCode <= 299;

  bool hasHeader(String name) {
    return headers.keys
        .any((header) => header.toLowerCase() == name.toLowerCase());
  }

  String? headerValue(String name) =>
      headers[name] ?? headers[name.toLowerCase()];

  ContentType? get contentType {
    final currentContentType = headerValue(HttpHeaders.contentTypeHeader);
    return currentContentType != null
        ? ContentType.parse(currentContentType)
        : null;
  }

  Encoding? get encoding =>
      Encoding.getByName(contentType?.charset ?? _defaultCharset);

  String? get fileName {
    final contentHeader = headerValue('Content-Disposition');
    if (null != contentHeader) {
      final parts = contentHeader.parseHeaderValue();
      if (parts.containsKey('filename*')) return parts['filename*']?.toString();
      if (parts.containsKey('filename')) return parts['filename']?.toString();
    }
    return null;
  }

  String? get fileExtension {
    final currentContentType = contentType;
    if (null != currentContentType) {
      return (mimeTypes.containsKey(currentContentType.mimeType))
          ? mimeTypes[currentContentType.mimeType]
          : '.${currentContentType.subType}';
    }
    return null;
  }
}
