import 'package:coding_dorado/features/exchange/data/common/data_exceptions.dart';
import 'package:coding_dorado/features/exchange/data/common/json_values.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_pair.dart';
import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

/// Lado del libro de El Dorado, visto desde el usuario.
enum PriceSide {
  /// El usuario vende USDT: `in` en USDT, `out` en fiat.
  sell('SELL', ExchangeDirection.cryptoToFiat),

  /// El usuario compra USDT: `in` en fiat, `out` en USDT.
  buy('BUY', ExchangeDirection.fiatToCrypto)
  ;

  const PriceSide(this.key, this.direction);

  final String key;
  final ExchangeDirection direction;

  static PriceSide of(ExchangeDirection direction) => switch (direction) {
    ExchangeDirection.cryptoToFiat => sell,
    ExchangeDirection.fiatToCrypto => buy,
  };
}

final class PriceEntry extends Equatable {
  const PriceEntry({required this.price, this.inMin, this.outMin});

  /// Fiat por 1 USDT.
  final Decimal price;

  /// Mínimo de lo que entrega el usuario (la moneda de TENGO).
  final Decimal? inMin;

  /// Mínimo de lo que recibe el usuario.
  final Decimal? outMin;

  @override
  List<Object?> get props => [price, inMin, outMin];
}

/// Respuesta de `GET /api/prices`:
/// `{ "SELL": { "VES": { "price": "…", "limits": { "in": { "min": "…" },
/// "out": { "min": "…" } } } }, "BUY": { … } }`.
final class PricesResponse extends Equatable {
  const PricesResponse(this._sides);

  /// Tolera precios como string o número, `limits` ausente y entradas
  /// inválidas (se ignoran). Si la raíz no es un objeto con `SELL` o `BUY`,
  /// lanza [ParsingException].
  factory PricesResponse.fromJson(Object? json) {
    if (json is! Map<String, dynamic>) {
      throw const ParsingException('La respuesta de /prices no es un objeto.');
    }
    if (!PriceSide.values.any((side) => json.containsKey(side.key))) {
      throw const ParsingException('La respuesta de /prices no trae SELL/BUY.');
    }
    final sides = <PriceSide, Map<String, PriceEntry>>{};
    for (final side in PriceSide.values) {
      final rawSide = json[side.key];
      if (rawSide == null) {
        sides[side] = const {};
        continue;
      }
      if (rawSide is! Map<String, dynamic>) {
        throw ParsingException('${side.key} no es un objeto.');
      }
      sides[side] = {
        for (final MapEntry(:key, :value) in rawSide.entries)
          key.toUpperCase(): ?_parseEntry(value),
      };
    }
    return PricesResponse(sides);
  }

  final Map<PriceSide, Map<String, PriceEntry>> _sides;

  Set<String> fiatsFor(PriceSide side) =>
      (_sides[side] ?? const {}).keys.toSet();

  /// Lanza [UnsupportedPairException] si El Dorado no cotiza esa fiat en ese
  /// lado (por ejemplo, VES en `BUY`).
  PriceEntry entryFor(PriceSide side, String fiatCode) {
    final entry = _sides[side]?[fiatCode.toUpperCase()];
    if (entry == null) {
      throw UnsupportedPairException(
        'El Dorado no cotiza $fiatCode en ${side.key}.',
      );
    }
    return entry;
  }

  static PriceEntry? _parseEntry(Object? raw) {
    if (raw is! Map<String, dynamic>) return null;
    final price = parseDecimal(raw['price']);
    if (price == null) return null;
    final limits = raw['limits'];
    final inMin = switch (limits) {
      {'in': {'min': final Object? min}} => parseDecimal(min),
      _ => null,
    };
    final outMin = switch (limits) {
      {'out': {'min': final Object? min}} => parseDecimal(min),
      _ => null,
    };
    return PriceEntry(price: price, inMin: inMin, outMin: outMin);
  }

  @override
  List<Object?> get props => [_sides];
}
