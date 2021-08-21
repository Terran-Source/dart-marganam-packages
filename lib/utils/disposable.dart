library marganam.utils.disposable;

import 'dart:async';

/// Compels the implementing class to give a concrete [dispose] implementation
abstract class Disposable<T> {
  /// Clear out anything, you don't want other prying eyes (or ears) to find out
  /// after you're done.
  FutureOr dispose([T? obj]);
}
