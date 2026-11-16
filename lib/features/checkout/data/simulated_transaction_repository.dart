import 'dart:math';

import 'package:coding_dorado/core/error/result.dart';
import 'package:coding_dorado/features/checkout/domain/entities/exchange_transaction.dart';
import 'package:coding_dorado/features/checkout/domain/repositories/transaction_repository.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_quote.dart';

/// Simula la ejecución: espera [latency] y aprueba el cambio con un ID
/// nuevo. Reemplazarla por una implementación HTTP no toca la presentación.
final class SimulatedTransactionRepository implements TransactionRepository {
  SimulatedTransactionRepository({
    this.latency = const Duration(milliseconds: 1200),
    DateTime Function()? clock,
    Random? random,
  }) : _clock = clock ?? DateTime.now,
       _random = random ?? Random.secure();

  final Duration latency;
  final DateTime Function() _clock;
  final Random _random;

  /// "TX-" y dos grupos de 4 caracteres en base32 de Crockford (sin I, L,
  /// O ni U, para dictarlo sin confusiones).
  static final idPattern = RegExp(
    r'^TX-[0-9A-HJKMNP-TV-Z]{4}-[0-9A-HJKMNP-TV-Z]{4}$',
  );

  static const _alphabet = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';

  @override
  Future<Result<ExchangeTransaction>> submit(ExchangeQuote quote) async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    return Ok(
      ExchangeTransaction(id: _newId(), quote: quote, completedAt: _clock()),
    );
  }

  String _newId() {
    String group() => String.fromCharCodes(
      List.generate(
        4,
        (_) => _alphabet.codeUnitAt(_random.nextInt(_alphabet.length)),
      ),
    );
    return 'TX-${group()}-${group()}';
  }
}
