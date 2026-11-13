import 'package:coding_dorado/core/error/failure.dart';
import 'package:equatable/equatable.dart';

/// Resultado de una operación que puede fallar de forma esperable.
sealed class Result<T> extends Equatable {
  const Result();

  bool get isOk => this is Ok<T>;

  T? get valueOrNull => switch (this) {
    Ok(:final value) => value,
    Err() => null,
  };

  Failure? get failureOrNull => switch (this) {
    Ok() => null,
    Err(:final failure) => failure,
  };

  R fold<R>({
    required R Function(Failure failure) onFailure,
    required R Function(T value) onSuccess,
  }) => switch (this) {
    Ok(:final value) => onSuccess(value),
    Err(:final failure) => onFailure(failure),
  };

  Result<R> map<R>(R Function(T value) transform) => switch (this) {
    Ok(:final value) => Ok(transform(value)),
    Err(:final failure) => Err(failure),
  };
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;

  @override
  List<Object?> get props => [value];
}

final class Err<T> extends Result<T> {
  const Err(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
