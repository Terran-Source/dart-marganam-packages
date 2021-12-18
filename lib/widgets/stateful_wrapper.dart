import 'dart:async';

import 'package:flutter/widgets.dart';

typedef AsyncFunction<T> = FutureOr<T> Function();

/// Wrapper for stateful functionality to provide onInit calls in stateless
/// widget.
///
/// got the idea from:
/// https://medium.com/filledstacks/how-to-call-a-function-on-start-in-flutter-stateless-widgets-28d90ab3bf49
class StatefulWrapper<T> extends StatefulWidget {
  final AsyncFunction<T> onInit;
  final Widget? loading;
  final Widget complete;
  final Widget? error;

  const StatefulWrapper({
    Key? key,
    required this.onInit,
    this.loading,
    required this.complete,
    this.error,
  }) : super(key: key);

  @override
  State<StatefulWrapper<T>> createState() => _StatefulWrapperState<T>();
}

class _StatefulWrapperState<T> extends State<StatefulWrapper<T>> {
  late T _state;
  _StatefulWrapperStatus _status = _StatefulWrapperStatus.none;

  T get state => _state; // for annoying analyzer

  @override
  Future initState() async {
    _status = _StatefulWrapperStatus.initiated;
    super.initState();
    try {
      _status = _StatefulWrapperStatus.inProgress;
      final result = await widget.onInit();
      setState(() {
        _status = _StatefulWrapperStatus.completed;
        _state = result;
      });
    } catch (e) {
      setState(() {
        _status = _StatefulWrapperStatus.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_status) {
      case _StatefulWrapperStatus.completed:
        return widget.complete;
      case _StatefulWrapperStatus.error:
        return widget.error ?? widget.complete;
      // case _StatefulWrapperStatus.none:
      // case _StatefulWrapperStatus.initiated:
      // case _StatefulWrapperStatus.inProgress:
      default:
        return widget.loading ?? Container();
    }
  }
}

enum _StatefulWrapperStatus { none, initiated, inProgress, completed, error }
