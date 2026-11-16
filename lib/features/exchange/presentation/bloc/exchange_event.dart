part of 'exchange_bloc.dart';

sealed class ExchangeEvent extends Equatable {
  const ExchangeEvent();

  @override
  List<Object?> get props => const [];
}

/// Carga inicial: disponibilidad de pares.
final class ExchangeStarted extends ExchangeEvent {
  const ExchangeStarted();
}

/// Texto del campo de monto.
final class ExchangeAmountChanged extends ExchangeEvent {
  const ExchangeAmountChanged(this.text);

  final String text;

  @override
  List<Object?> get props => [text];
}

/// Moneda elegida para TENGO.
final class ExchangeFromCurrencySelected extends ExchangeEvent {
  const ExchangeFromCurrencySelected(this.currency);

  final Currency currency;

  @override
  List<Object?> get props => [currency];
}

/// Moneda elegida para QUIERO.
final class ExchangeToCurrencySelected extends ExchangeEvent {
  const ExchangeToCurrencySelected(this.currency);

  final Currency currency;

  @override
  List<Object?> get props => [currency];
}

final class ExchangeCurrenciesSwapped extends ExchangeEvent {
  const ExchangeCurrenciesSwapped();
}

/// Lleva par y monto desde otra pestaña (comparación, "Ver en …").
final class ExchangePrefilled extends ExchangeEvent {
  const ExchangePrefilled({required this.pair, required this.amount});

  final ExchangePair pair;
  final Decimal amount;

  @override
  List<Object?> get props => [pair, amount];
}

/// "Reintentar": ignora la caché.
final class ExchangeRatesRefreshed extends ExchangeEvent {
  const ExchangeRatesRefreshed();
}

/// La app volvió al primer plano: recotiza si la caché venció.
final class ExchangeAppResumed extends ExchangeEvent {
  const ExchangeAppResumed();
}

/// El cambio se completó: vuelve al par inicial y sin monto.
final class ExchangeReset extends ExchangeEvent {
  const ExchangeReset();
}

/// Evento interno: todas las cotizaciones pasan por acá.
final class _QuoteRequested extends ExchangeEvent {
  const _QuoteRequested({
    this.delay = Duration.zero,
    this.forceRefresh = false,
  });

  /// Debounce al escribir; 0 en los cambios de par.
  final Duration delay;
  final bool forceRefresh;

  @override
  List<Object?> get props => [delay, forceRefresh];
}
