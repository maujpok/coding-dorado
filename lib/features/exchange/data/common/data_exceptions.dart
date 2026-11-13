/// Errores de la capa de datos. Los repositorios los traducen a `Failure`.
sealed class ExchangeDataException implements Exception {
  const ExchangeDataException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// La fuente no cotiza el par pedido.
final class UnsupportedPairException extends ExchangeDataException {
  const UnsupportedPairException(super.message);
}

/// La fuente cotiza el par pero no tiene ofertas.
final class NoOffersException extends ExchangeDataException {
  const NoOffersException(super.message);
}

/// El API devolvió un error en el body (HTTP 200 con `error`).
final class ApiErrorException extends ExchangeDataException {
  const ApiErrorException(super.message, {this.code});

  final String? code;
}

/// La respuesta no tiene la forma esperada.
final class ParsingException extends ExchangeDataException {
  const ParsingException(super.message);
}
