import 'package:equatable/equatable.dart';

enum CurrencyType { fiat, crypto }

/// Moneda soportada por la app. Los IDs propios de cada API (por ejemplo,
/// `TATUM-TRON-USDT`) no viven acá: los traduce cada data source.
final class Currency extends Equatable {
  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
    required this.type,
    this.iconAsset,
    this.country,
  });

  /// Código ISO o ticker: 'USDT', 'VES'.
  final String code;

  /// Nombre para mostrar: 'Tether', 'Bolívares'.
  final String name;

  /// Símbolo: 'USDT', 'Bs'.
  final String symbol;

  final CurrencyType type;

  /// Ruta del ícono; `null` muestra un avatar con iniciales.
  final String? iconAsset;

  /// País de una fiat ('Venezuela'); ordena el selector FIAT. `null` en las
  /// crypto.
  final String? country;

  bool get isCrypto => type == CurrencyType.crypto;
  bool get isFiat => type == CurrencyType.fiat;

  @override
  List<Object?> get props => [code, type];

  @override
  String toString() => code;
}
