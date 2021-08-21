library marganam.utils.functional_execution;

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'formatted_exception.dart';

abstract class UseCase<T, Params> {
  Future<Either<FormattedException, T>> call(Params params);
}

// This will be used by the [UseCase] which
// doesn't accept any parameters.
class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}
