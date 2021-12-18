import 'dart:io';

import 'package:dart_marganam/utils/formatted_exception.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interpolation/interpolation.dart';

final _interpolation = Interpolation();
final Map<Type, String> _backUp = {};
const newExceptionMessage = 'This is a dummy exception message';
const _defaultAppName = 'Marganam.FormattedException';

void main() {
  cloneMap(exceptionDisplay, _backUp);

  tearDown(() {
    cloneMap(_backUp, exceptionDisplay);
    // FormattedException.appName = null;
    FormattedException.reset();
  });

  group('exceptionDisplay extended test', () {
    test('new type can be added', () {
      // act
      exceptionDisplay[Future] = newExceptionMessage;

      // assert
      expect(exceptionDisplay.containsKey(Future), isTrue);
      expect(exceptionDisplay[Future], newExceptionMessage);
    });
    test('new type can be added via enhanceExceptionDisplay()', () {
      // act
      enhanceExceptionDisplay<Future>(newExceptionMessage);

      // assert
      expect(exceptionDisplay.containsKey(Future), isTrue);
      expect(exceptionDisplay[Future], newExceptionMessage);
    });
    test('should not contain other type', () {
      // assert
      expect(exceptionDisplay.containsKey(Future), isFalse);
    });
  });

  const appName = 'Sprightly';
  const moduleName = 'someModule';
  final messageParams = {
    'message': newExceptionMessage,
    'method': 'GET',
    'host': 'https://www.example.com',
  };
  final exceptions = <Exception>[
    Exception(newExceptionMessage),
    FormatException(newExceptionMessage, Uri.parse('https://www.example.com')),
    const FileSystemException(
      newExceptionMessage,
      '/path/to/something',
      OSError(newExceptionMessage, 404),
    ),
    HttpException(
      newExceptionMessage,
      uri: Uri.parse('https://www.example.com'),
    ),
    SocketException(
      newExceptionMessage,
      osError: const OSError(newExceptionMessage, 404),
      address: InternetAddress('127.0.0.1'),
      port: 80,
    ),
    const WebSocketException(newExceptionMessage),
    const SignalException(
      newExceptionMessage,
      OSError(newExceptionMessage, 404),
    ),
    const StdinException(
      newExceptionMessage,
      OSError(newExceptionMessage, 404),
    ),
    const StdoutException(
      newExceptionMessage,
      OSError(newExceptionMessage, 404),
    ),
    ProcessException(
      'SomeProcess',
      List<String>.generate(3, (i) => WordPair.random().asString),
      newExceptionMessage,
      404,
    ),
    const TlsException(newExceptionMessage, OSError(newExceptionMessage, 404)),
    _CustomException(newExceptionMessage, 'My Custom Exception MEssage'),
  ];

  for (final exception in exceptions) {
    formattedExceptionGroupTest(
      exception,
      appName,
      moduleName,
      messageParams,
      runtimeType:
          exception.runtimeType.toString().startsWith('_') ? Exception : null,
    );
  }

  // check with a custom exception with added details to exceptionDisplay
  final customException =
      _CustomException(newExceptionMessage, 'My Custom Exception Message');
  formattedExceptionGroupTest(
    customException,
    appName,
    moduleName,
    messageParams,
    doSetup: true,
  );

  // check with a existing exception with changed details to exceptionDisplay
  final customHttpException = HttpException(
    newExceptionMessage,
    uri: Uri.parse('https://www.example.com'),
  );
  formattedExceptionGroupTest(
    customHttpException,
    appName,
    moduleName,
    messageParams,
    doSetup: true,
  );
}

void cloneMap<K, V>(Map<K, V> source, Map<K, V> dest) {
  dest.clear();
  source.forEach((key, value) => dest[key] = value);
}

String getExceptionDisplayMessage(Type runtimeType) =>
    exceptionDisplay[runtimeType] ?? newExceptionMessage;

void formattedExceptionGroupTest<T extends Exception>(
  T exception,
  String appName,
  String moduleName,
  Map<String, dynamic> messageParams, {
  Type? runtimeType,
  bool doSetup = false,
}) {
  final overrideRuntimeType = runtimeType ?? exception.runtimeType;
  final actualRuntimeType = exception.runtimeType;
  group(
      'FormattedException test for '
      '$actualRuntimeType${doSetup ? ': with setup' : ''}', () {
    setUp(() {
      if (doSetup) {
        exceptionDisplay[_CustomException] =
            'CustomException: $newExceptionMessage. {message}';
        exceptionDisplay[HttpException] =
            'The HttpException message has been changed. {message}';
        print(
          'New Message set: (_CustomException): '
          '${exceptionDisplay[_CustomException]}',
        );
        print(
          'New Message set: (HttpException): '
          '${exceptionDisplay[HttpException]}',
        );
      }
    });
    test('create new instance', () {
      // act
      final result = FormattedException(exception);
      print('result Type: ${result.runtimeType}');
      print('inner Exception Type: ${result.exceptionType}');

      // assert
      expect(result, isA<FormattedException<Exception>>());
      expect(result, isNot(isA<FormattedException<FormatException>>()));
      expect(result.exception, isA<T>());
      expect(result.exception, exception);
      expect(result.message, exception.toString());
      expect(result.exceptionType, actualRuntimeType);
      expect(result.logSource, '$_defaultAppName:Generic');
      expect(
        result.displayedMessage,
        _interpolation
            .eval(
              getExceptionDisplayMessage(overrideRuntimeType),
              result.messageParams,
            )
            .trim(),
      );
    });
    test('set FormattedException appName', () {
      // arrange
      FormattedException.appName = appName;

      // act
      final result = FormattedException(exception);

      // assert
      expect(result, isA<FormattedException<Exception>>());
      expect(result, isNot(isA<FormattedException<FormatException>>()));
      expect(result.exception, isA<T>());
      expect(result.exception, exception);
      expect(result.message, exception.toString());
      expect(result.exceptionType, actualRuntimeType);
      expect(result.logSource, 'Sprightly:Generic');
      expect(
        result.displayedMessage,
        _interpolation
            .eval(
              getExceptionDisplayMessage(overrideRuntimeType),
              result.messageParams,
            )
            .trim(),
      );
    });
    test('set FormattedException moduleName', () {
      // act
      final result = FormattedException(exception, moduleName: moduleName);

      // assert
      expect(result, isA<FormattedException<Exception>>());
      expect(result, isNot(isA<FormattedException<FormatException>>()));
      expect(result.exception, isA<T>());
      expect(result.exception, exception);
      expect(result.message, exception.toString());
      expect(result.exceptionType, actualRuntimeType);
      expect(result.logSource, '$_defaultAppName:$moduleName');
      expect(
        result.displayedMessage,
        _interpolation
            .eval(
              getExceptionDisplayMessage(overrideRuntimeType),
              result.messageParams,
            )
            .trim(),
      );
    });
    test('set both FormattedException appName & moduleName', () {
      // arrange
      FormattedException.appName = appName;

      // act
      final result = FormattedException(exception, moduleName: moduleName);

      // assert
      expect(result, isA<FormattedException<Exception>>());
      expect(result, isNot(isA<FormattedException<FormatException>>()));
      expect(result.exception, isA<T>());
      expect(result.exception, exception);
      expect(result.message, exception.toString());
      expect(result.exceptionType, actualRuntimeType);
      expect(result.logSource, '$appName:$moduleName');
      expect(
        result.displayedMessage,
        _interpolation
            .eval(
              getExceptionDisplayMessage(overrideRuntimeType),
              result.messageParams,
            )
            .trim(),
      );
    });
    test('set FormattedException messageParams', () {
      // act
      final result =
          FormattedException(exception, messageParams: messageParams);

      // assert
      expect(result, isA<FormattedException<Exception>>());
      expect(result, isNot(isA<FormattedException<FormatException>>()));
      expect(result.exception, isA<T>());
      expect(result.exception, exception);
      expect(result.message, messageParams['message']);
      expect(result.exceptionType, actualRuntimeType);
      expect(result.logSource, '$_defaultAppName:Generic');
      expect(
        result.displayedMessage,
        _interpolation
            .eval(
              getExceptionDisplayMessage(overrideRuntimeType),
              messageParams,
            )
            .trim(),
      );
    });
    test('set all FormattedException parameters', () {
      // arrange
      FormattedException.appName = appName;

      // act
      final result = FormattedException(
        exception,
        messageParams: messageParams,
        stackTrace: StackTrace.current,
        moduleName: moduleName,
      );

      // assert
      expect(result, isA<FormattedException<Exception>>());
      expect(result, isNot(isA<FormattedException<FormatException>>()));
      expect(result.exception, isA<T>());
      expect(result.exception, exception);
      expect(result.message, messageParams['message']);
      expect(result.exceptionType, actualRuntimeType);
      expect(result.logSource, '$appName:$moduleName');
      expect(
        result.displayedMessage,
        _interpolation
            .eval(
              getExceptionDisplayMessage(overrideRuntimeType),
              messageParams,
            )
            .trim(),
      );
      print(result.displayedMessage);
    });
  });
}

class _CustomException implements Exception {
  final String customMessage;
  final Exception exception;

  _CustomException(String message, this.customMessage)
      : exception = Exception(message);

  @override
  String toString() => '${exception.toString()} $customMessage';
}
