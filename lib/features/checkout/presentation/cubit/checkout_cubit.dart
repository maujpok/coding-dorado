import 'package:coding_dorado/core/error/failure.dart';
import 'package:coding_dorado/features/checkout/domain/entities/exchange_transaction.dart';
import 'package:coding_dorado/features/checkout/domain/usecases/submit_exchange.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_quote.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class CheckoutState extends Equatable {
  const CheckoutState({required this.attempt});

  /// Número de intento, desde 1. La animación se reinicia cuando cambia.
  final int attempt;

  @override
  List<Object?> get props => [attempt];
}

final class CheckoutProcessing extends CheckoutState {
  const CheckoutProcessing({super.attempt = 1});
}

final class CheckoutSucceeded extends CheckoutState {
  const CheckoutSucceeded(this.transaction, {required super.attempt});

  final ExchangeTransaction transaction;

  @override
  List<Object?> get props => [transaction, attempt];
}

final class CheckoutFailed extends CheckoutState {
  const CheckoutFailed(this.failure, {required super.attempt});

  final Failure failure;

  @override
  List<Object?> get props => [failure, attempt];
}

/// Ejecuta el cambio confirmado. El procesamiento dura al menos
/// [minDuration], lo que tarda la animación en recorrer sus pasos: así una
/// respuesta instantánea no la corta a la mitad.
class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit({
    required SubmitExchange submitExchange,
    required this.quote,
    this.minDuration = defaultMinDuration,
  }) : _submitExchange = submitExchange,
       super(const CheckoutProcessing());

  static const defaultMinDuration = Duration(milliseconds: 2400);

  final ExchangeQuote quote;
  final Duration minDuration;
  final SubmitExchange _submitExchange;
  bool _running = false;

  /// Primer intento o "Reintentar". No hace nada si ya está en curso o si
  /// el cambio ya se completó.
  Future<void> submit() async {
    if (_running || state is CheckoutSucceeded) return;
    _running = true;
    final attempt = switch (state) {
      CheckoutFailed(:final attempt) => attempt + 1,
      _ => state.attempt,
    };
    if (state is CheckoutFailed) emit(CheckoutProcessing(attempt: attempt));

    final (result, _) = await (
      _submitExchange(quote),
      Future<void>.delayed(minDuration),
    ).wait;
    _running = false;
    if (isClosed) return;
    emit(
      result.fold(
        onFailure: (failure) => CheckoutFailed(failure, attempt: attempt),
        onSuccess: (transaction) =>
            CheckoutSucceeded(transaction, attempt: attempt),
      ),
    );
  }
}
