import 'package:coding_dorado/core/error/failure.dart';
import 'package:coding_dorado/core/error/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Ok expone el valor y transforma con map', () {
    const Result<int> result = Ok(2);

    expect(result.isOk, isTrue);
    expect(result.valueOrNull, 2);
    expect(result.failureOrNull, isNull);
    expect(result.map((v) => v * 10), const Ok(20));
    expect(result.fold(onFailure: (_) => 'error', onSuccess: (v) => '$v'), '2');
  });

  test('Err conserva el Failure al transformar', () {
    const Result<int> result = Err(NetworkFailure());

    expect(result.isOk, isFalse);
    expect(result.valueOrNull, isNull);
    expect(result.failureOrNull, const NetworkFailure());
    expect(result.map((v) => v * 10), const Err<int>(NetworkFailure()));
    expect(
      result.fold(onFailure: (f) => f.runtimeType, onSuccess: (_) => null),
      NetworkFailure,
    );
  });

  test('ServerFailure identifica el límite de consultas', () {
    expect(const ServerFailure(429).isRateLimited, isTrue);
    expect(const ServerFailure(500).isRateLimited, isFalse);
  });
}
