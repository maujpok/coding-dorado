import 'package:coding_dorado/features/exchange/domain/entities/exchange_pair.dart';
import 'package:equatable/equatable.dart';

/// Clave de un par cotizable: crypto, fiat y dirección.
typedef PairKey = ({
  String cryptoCode,
  String fiatCode,
  ExchangeDirection direction,
});

/// Qué pares cotiza una fuente.
final class PairAvailability extends Equatable {
  /// La fuente no lo sabe de antemano: todos los pares se habilitan y la
  /// falta de ofertas se informa al cotizar.
  const PairAvailability.unknown() : _available = null;

  /// Solo [available] está disponible.
  const PairAvailability.only(Set<PairKey> available) : _available = available;

  static PairKey keyOf(ExchangePair pair) => (
    cryptoCode: pair.crypto.code,
    fiatCode: pair.fiat.code,
    direction: pair.direction,
  );

  final Set<PairKey>? _available;

  bool get isKnown => _available != null;

  bool isAvailable(ExchangePair pair) =>
      _available?.contains(keyOf(pair)) ?? true;

  @override
  List<Object?> get props => [_available];
}
