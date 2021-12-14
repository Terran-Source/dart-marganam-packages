library marganam.utils.functional_execution;

import 'dart:async';

import 'package:dartz/dartz.dart';

import 'formatted_exception.dart';

FutureOr<Right> dartzExecute<Right>(
  FutureOr<Right> Function() caller, {
  Map<String, dynamic> messageParams = const <String, dynamic>{},
  String? moduleName,
}) {
  try {
    return caller();
  } on Exception catch (exception, stackTrace) {
    throw FormattedException(
      exception,
      stackTrace: stackTrace,
      messageParams: messageParams,
      moduleName: moduleName,
    );
  }
}

Future<Either<FormattedException, Right>> dartzCallEither<Right>(
  FutureOr<Right> Function() caller, {
  StackTrace? stackTrace,
  Map<String, dynamic> messageParams = const <String, dynamic>{},
  String? moduleName,
}) =>
    Task<Right>(() => Future.sync(caller))
        .attempt()
        .mapException<Right>(
          stackTrace: stackTrace,
          messageParams: messageParams,
          moduleName: moduleName,
        )
        .run();

Future<Either<FormattedException, Right>> dartzCall<Right>(
  FutureOr<Right> Function() caller, {
  Map<String, dynamic> messageParams = const <String, dynamic>{},
  String? moduleName,
}) =>
    dartzCallEither<Right>(
      () => dartzExecute(
        caller,
        messageParams: messageParams,
        moduleName: moduleName,
      ),
    );

extension _TaskException<E extends Either<Object, R>, R> on Task<E> {
  Task<Either<FormattedException, Rt>> mapException<Rt>({
    StackTrace? stackTrace,
    Map<String, dynamic> messageParams = const <String, dynamic>{},
    String? moduleName,
  }) =>
      map(
        (either) => either.fold(
          (obj) {
            if (obj is FormattedException) {
              return Left(obj);
            } else if (obj is Exception) {
              return Left(
                FormattedException(
                  obj,
                  stackTrace: stackTrace,
                  messageParams: messageParams,
                  moduleName: moduleName,
                ),
              );
            }
            return Left(
              FormattedException(
                obj as Exception,
                stackTrace: stackTrace,
                messageParams: messageParams,
                moduleName: moduleName,
              ),
            );
          },
          (_) => Right(_ as Rt),
        ),
      );
}
