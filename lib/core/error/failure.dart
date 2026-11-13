import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

/// Errores esperables, ya traducidos desde excepciones. La UI decide el
/// mensaje según el tipo.
sealed class Failure extends Equatable {
  const Failure();

  @override
  List<Object?> get props => const [];
}

/// Sin conexión.
final class NetworkFailure extends Failure {
  const NetworkFailure();
}

/// El servicio no respondió a tiempo.
final class TimeoutFailure extends Failure {
  const TimeoutFailure();
}

/// Respuesta HTTP de error (429 incluido).
final class ServerFailure extends Failure {
  const ServerFailure([this.statusCode]);

  final int? statusCode;

  bool get isRateLimited => statusCode == 429;

  @override
  List<Object?> get props => [statusCode];
}

/// La fuente no cotiza ese par (por ejemplo, USDC en El Dorado).
final class PairUnavailableFailure extends Failure {
  const PairUnavailableFailure();
}

/// La fuente cotiza el par pero ahora no tiene ofertas.
final class NoOffersFailure extends Failure {
  const NoOffersFailure();
}

/// El API rechazó los parámetros (`error` en el body).
final class InvalidRequestFailure extends Failure {
  const InvalidRequestFailure([this.code]);

  final String? code;

  @override
  List<Object?> get props => [code];
}

/// La respuesta no tiene la forma esperada.
final class ParsingFailure extends Failure {
  const ParsingFailure();
}

/// La tasa recibida no es válida (≤ 0).
final class InvalidRateFailure extends Failure {
  const InvalidRateFailure();
}

/// El monto está por debajo del mínimo de la fuente.
final class BelowMinimumFailure extends Failure {
  const BelowMinimumFailure(this.minAmount);

  /// En la moneda del monto ingresado (TENGO).
  final Decimal minAmount;

  @override
  List<Object?> get props => [minAmount];
}

final class UnknownFailure extends Failure {
  const UnknownFailure();
}
