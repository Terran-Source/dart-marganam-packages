library marganam.utils.worker;

import 'dart:async';

/// SIngleton async (or not) function type
typedef ReadyOrNotWorker<T> = FutureOr<T> Function();

/// Helper mixin to help defining a singleton function execution.
///
/// dart has no provision for async constructor. In case we need to execute an
/// async function before a class is actually usable (e.g. get data from web
/// through an async http get call & then parse the data & provide data). The
/// process complicates even further when the class is used with singleton
/// instance. The outside world would not have the intimation if such functions
/// have already been invoked or is currently under process. That's a awful lot
/// of code & messy state handling.
///
/// Example:
/// ```dart
/// /// A class designed for singleton use
/// class SomeClass with ReadyOrNotMixin {
///   // constructor
///   SomeClass._() {
///     // **attach the helper executer**
///     getReadyWorker = _initialize; // can be used with `super.` prefix, too
///     // Optionally, you can add more singleton FUture jobs
///     additionalSingleJobs["cleanUpJob"] = _cleanUp;
///     additionalSingleJobs["dumpJob"] = _dump;
///   }
///
///   static SomeClass _cache = SomeClass._();
///   // factory to implement singleton instance
///   factory SomeClass() => _cache;
///
///   // this private value is set only if the [_initialize] function complete successfully
///   late Object _readyObject;
///
///   // thus, this publicly accessible [value] depends on the successful execution
///   // of [_initialize] & it only needs to happen once
///   Object get value => _readyObject;
///
///   // the async job that need to be executed in singleton manner
///   Future _initialize() async {
///     _readyObject = await someAsyncJob();
///   }
///
///   // Other singleton jobs
///   Future _cleanUp(){
///     // Do some cleanup jobs after heavy-lifting, that *may* take some time
///   }
///
///   // Other singleton jobs
///   Future _dump(){
///     // Dumps some craps, maybe.
///     // Be sure not to use [_readyObject] or [value] as we'll run this job
///     // despite the parent instance has achieved [ready] state or not. Hence,
///     // [_readyObject] or [value] will not be materialized.
///   }
/// }
///
/// void main() async {
///   SomeClass someClass = SomeClass();
///
///   // sometimes, we need to dump craps whether we're ready or not
///   someClass.triggerJob("dumpJob");
///
///   // either check before running
///   if (!someClass.ready) await someClass.getReady();
///   // or, it doesn't matter if someone has already run it or it's in progress
///   await someClass.getReady();
///
///   // now it is safe to use
///   someClass.value;
///
///   // No need to await for cleanUp, along with [onReady] safety net
///   someClass.triggerJob("cleanUpJob", onReady: true);
/// }
/// ```
mixin ReadyOrNotMixin<T> {
  bool _initialized = false;
  bool _working = false;
  FutureOr<T>? _future;

  /// Registers the [getReady] singleton job
  late ReadyOrNotWorker<T>? getReadyWorker;

  /// Register additional singleton jobs
  final additionalSingleJobs = <String, ReadyOrNotWorker>{};
  final _workingJobs = <String>{};
  final _workingFutures = <String, FutureOr>{};

  /// Whether the [getReady] has been executed ***once*** successfully or not
  bool get ready => _initialized;

  /// The singleton executor of [getReadyWorker]
  FutureOr getReady() async {
    if (null != getReadyWorker) {
      if (!_initialized && !_working) {
        _working = true;
        try {
          _future = getReadyWorker!();
          await _future;
          _initialized = true;
        } finally {
          _future = null;
          _working = false;
        }
      } else if (_working) {
        await _future;
      }
    }
  }

  /// Whether the [getReady] has been executed ***once*** successfully or not
  bool get working => _working || _workingJobs.isNotEmpty;

  /// Get a set of any of the the running jobs in [additionalSingleJobs]
  Set<String> get workingJobs => _workingJobs;

  /// The singleton executor of a job in [additionalSingleJobs]
  ///
  /// [jobName] should be one of the job in the [additionalSingleJobs] list.
  /// If [onReady] is true, it makes sure the target job should run only if the
  /// current instance achieved [ready] state
  FutureOr<R?> triggerJob<R>(String jobName, {bool onReady = false}) async {
    var shouldProceed = additionalSingleJobs.containsKey(jobName);
    if (shouldProceed) {
      final alreadyWorking = _workingJobs.contains(jobName);
      if (onReady) {
        shouldProceed = ready;
      }
      if (shouldProceed && !alreadyWorking) {
        _workingJobs.add(jobName);
        try {
          final jobFuture = additionalSingleJobs[jobName]!() as FutureOr<R>;
          _workingFutures[jobName] = jobFuture;
          return await jobFuture;
        } finally {
          _workingFutures.remove(jobName);
          _workingJobs.remove(jobName);
        }
      } else if (alreadyWorking) {
        return await (_workingFutures[jobName] as FutureOr<R>);
      }
    }
    return null;
  }
}
