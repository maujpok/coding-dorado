import 'package:coding_dorado/core/error/result.dart';
import 'package:coding_dorado/features/checkout/domain/entities/exchange_transaction.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_quote.dart';

/// Ejecuta cambios. Hoy solo existe la implementación simulada: ninguna de
/// las APIs públicas que usa la app permite operar.
// Interfaz de un solo método a propósito: separa la ejecución simulada de
// una futura implementación HTTP.
// ignore: one_member_abstracts
abstract interface class TransactionRepository {
  Future<Result<ExchangeTransaction>> submit(ExchangeQuote quote);
}
