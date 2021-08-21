library marganam.utils.initiated;

import 'dart:async';

/// Compels the implementing class to give a concrete [initiate] implementation
abstract class Initiated<T> {
  /// Usually calls [getReady] if the implementing class is with
  /// [ReadyOrNotMixin]
  ///
  /// Example:
  /// ```
  /// @override
  /// FutureOr initiate() => getReady();
  /// ```
  FutureOr<T> initiate();
}
