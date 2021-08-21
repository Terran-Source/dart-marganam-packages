library marganam.utils.crypto;

import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:convert/convert.dart';
import 'package:dart_marganam/extensions.dart';

enum HashLibrary {
  md5,
  sha1,
  sha224,
  sha256,
  sha384,
  sha512,
  hmacMd5,
  hmacSha1,
  hmacSha224,
  hmacSha256,
  hmacSha384,
  hmacSha512
}

final Random _random = Random.secure();

String hashedAll(
  List<String> items, {
  int? hashLength = 16,
  HashLibrary library = HashLibrary.sha1,
  String? key,
  bool prefixLibrary = true,
}) {
  final keyLength = null == hashLength || hashLength < 16
      ? 16
      : hashLength < 4096
          ? hashLength
          : 4096;
  final _key = key ?? randomString(keyLength);
  final utf8Key = utf8.encode(_key);
  final sink = AccumulatorSink<Digest>();
  final byteChunks = items.map((str) => utf8.encode(str));
  ByteConversionSink chunks;
  switch (library) {
    case HashLibrary.md5:
      chunks = md5.startChunkedConversion(sink);
      break;
    case HashLibrary.sha224:
      chunks = sha224.startChunkedConversion(sink);
      break;
    case HashLibrary.sha256:
      chunks = sha256.startChunkedConversion(sink);
      break;
    case HashLibrary.sha384:
      chunks = sha384.startChunkedConversion(sink);
      break;
    case HashLibrary.sha512:
      chunks = sha512.startChunkedConversion(sink);
      break;
    case HashLibrary.hmacMd5:
      final hmac = Hmac(md5, utf8Key);
      chunks = hmac.startChunkedConversion(sink);
      break;
    case HashLibrary.hmacSha1:
      final hmac = Hmac(sha1, utf8Key);
      chunks = hmac.startChunkedConversion(sink);
      break;
    case HashLibrary.hmacSha224:
      final hmac = Hmac(sha224, utf8Key);
      chunks = hmac.startChunkedConversion(sink);
      break;
    case HashLibrary.hmacSha256:
      final hmac = Hmac(sha256, utf8Key);
      chunks = hmac.startChunkedConversion(sink);
      break;
    case HashLibrary.hmacSha384:
      final hmac = Hmac(sha384, utf8Key);
      chunks = hmac.startChunkedConversion(sink);
      break;
    case HashLibrary.hmacSha512:
      final hmac = Hmac(sha512, utf8Key);
      chunks = hmac.startChunkedConversion(sink);
      break;
    case HashLibrary.sha1:
    default:
      chunks = sha1.startChunkedConversion(sink);
      break;
  }
  for (final bt in byteChunks) {
    chunks.add(bt);
  }
  chunks.close();
  var result = "${prefixLibrary ? '${library.toEnumString()}:' : ''}"
      "${sink.events.single}";
  if (null == hashLength) return result;
  if (result.length < hashLength) {
    result += _key;
    if (result.length < hashLength) {
      result += randomString(hashLength - result.length);
    }
  }
  return result.substring(0, hashLength);
}

String hashed(
  String item, {
  int hashLength = 16,
  HashLibrary library = HashLibrary.sha1,
  String? key,
  bool prefixLibrary = true,
}) =>
    hashedAll(
      [item],
      hashLength: hashLength,
      library: library,
      key: key,
      prefixLibrary: prefixLibrary,
    );

String randomString([int length = 16]) {
  final unicodeIntegers =
      List<int>.generate(length, (index) => _random.nextInt(256));
  return base64Encode(unicodeIntegers).substring(0, length);
}
