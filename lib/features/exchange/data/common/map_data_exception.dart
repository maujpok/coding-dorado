import 'package:coding_dorado/core/error/failure.dart';
import 'package:coding_dorado/features/exchange/data/common/data_exceptions.dart';
import 'package:dio/dio.dart';

/// Traduce las excepciones de la capa de datos a un [Failure].
Failure mapDataException(Object error) => switch (error) {
  UnsupportedPairException() => const PairUnavailableFailure(),
  NoOffersException() => const NoOffersFailure(),
  ApiErrorException(:final code) => InvalidRequestFailure(code),
  ParsingException() => const ParsingFailure(),
  DioException() => _mapDio(error),
  _ => const UnknownFailure(),
};

Failure _mapDio(DioException error) => switch (error.type) {
  DioExceptionType.connectionTimeout ||
  DioExceptionType.sendTimeout ||
  DioExceptionType.receiveTimeout ||
  DioExceptionType.transformTimeout => const TimeoutFailure(),
  DioExceptionType.connectionError ||
  DioExceptionType.badCertificate => const NetworkFailure(),
  DioExceptionType.badResponse => ServerFailure(error.response?.statusCode),
  DioExceptionType.cancel => const UnknownFailure(),
  DioExceptionType.unknown =>
    error.error is FormatException
        ? const ParsingFailure()
        : const UnknownFailure(),
};
