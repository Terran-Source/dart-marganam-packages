import 'dart:async';

import '../formatted_exception.dart';
import '../initiated.dart';
import '../ready_or_not.dart';
import 'pre_condition_failed.dart';

class ExceptionPackage with ReadyOrNotMixin implements Initiated {
  factory ExceptionPackage() => universal;
  static ExceptionPackage universal = ExceptionPackage._();
  ExceptionPackage._() {
    getReadyWorker = enhanceFormattedException;
  }

  void enhanceFormattedException() {
    enhanceExceptionDisplay<PreConditionFailedException>(
      PreConditionFailedException.formattedMessage(),
    );
  }

  @override
  FutureOr initiate() => getReady();
}
