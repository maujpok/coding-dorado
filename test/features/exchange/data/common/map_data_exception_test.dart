import 'package:coding_dorado/core/error/failure.dart';
import 'package:coding_dorado/features/exchange/data/common/data_exceptions.dart';
import 'package:coding_dorado/features/exchange/data/common/json_values.dart';
import 'package:coding_dorado/features/exchange/data/common/map_data_exception.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_currencies.dart';

void main() {
  final options = RequestOptions(path: '/x');

  DioException dio(DioExceptionType type, {int? status, Object? error}) =>
      DioException(
        requestOptions: options,
        type: type,
        error: error,
        response: status == null
            ? null
            : Response(requestOptions: options, statusCode: status),
      );

  final cases = <String, (Object, Failure)>{
    'par no soportado': (
      const UnsupportedPairException('x'),
      const PairUnavailableFailure(),
    ),
    'sin ofertas': (const NoOffersException('x'), const NoOffersFailure()),
    'error del API': (
      const ApiErrorException('x', code: 'INVALID_REQUEST'),
      const InvalidRequestFailure('INVALID_REQUEST'),
    ),
    'parseo': (const ParsingException('x'), const ParsingFailure()),
    'sin conexión': (
      dio(DioExceptionType.connectionError),
      const NetworkFailure(),
    ),
    'timeout de conexión': (
      dio(DioExceptionType.connectionTimeout),
      const TimeoutFailure(),
    ),
    'timeout de respuesta': (
      dio(DioExceptionType.receiveTimeout),
      const TimeoutFailure(),
    ),
    'HTTP 429': (
      dio(DioExceptionType.badResponse, status: 429),
      const ServerFailure(429),
    ),
    'HTTP 500': (
      dio(DioExceptionType.badResponse, status: 500),
      const ServerFailure(500),
    ),
    'JSON inválido': (
      dio(DioExceptionType.unknown, error: const FormatException()),
      const ParsingFailure(),
    ),
    'cancelada': (dio(DioExceptionType.cancel), const UnknownFailure()),
    'otra excepción': (Exception('x'), const UnknownFailure()),
  };

  for (final MapEntry(key: name, value: (error, failure)) in cases.entries) {
    test('$name → ${failure.runtimeType}', () {
      expect(mapDataException(error), failure);
    });
  }

  group('parseDecimal', () {
    test('acepta string y número', () {
      expect(parseDecimal('1014.8292'), dec('1014.8292'));
      expect(parseDecimal(' 12 '), dec('12'));
      expect(parseDecimal(1052), dec('1052'));
      expect(parseDecimal(3.4542), dec('3.4542'));
    });

    test('rechaza valores no numéricos', () {
      for (final value in <Object?>[null, 'n/a', '', double.nan, true]) {
        expect(parseDecimal(value), isNull, reason: '$value');
      }
    });
  });
}
