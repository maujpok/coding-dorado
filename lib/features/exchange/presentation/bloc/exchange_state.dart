part of 'exchange_bloc.dart';

sealed class QuoteStatus extends Equatable {
  const QuoteStatus();

  /// Última cotización conocida; se conserva mientras carga la siguiente.
  ExchangeQuote? get latestQuote => null;

  @override
  List<Object?> get props => const [];
}

/// Sin monto válido.
final class QuoteIdle extends QuoteStatus {
  const QuoteIdle();
}

final class QuoteLoading extends QuoteStatus {
  const QuoteLoading({this.previous});

  final ExchangeQuote? previous;

  @override
  ExchangeQuote? get latestQuote => previous;

  @override
  List<Object?> get props => [previous];
}

final class QuoteLoaded extends QuoteStatus {
  const QuoteLoaded(this.quote);

  final ExchangeQuote quote;

  @override
  ExchangeQuote? get latestQuote => quote;

  @override
  List<Object?> get props => [quote];
}

final class QuoteFailed extends QuoteStatus {
  const QuoteFailed(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

final class ExchangeState extends Equatable {
  const ExchangeState({
    required this.pair,
    this.amountText = '',
    this.amount,
    this.quote = const QuoteIdle(),
    this.availability = const PairAvailability.unknown(),
    this.isSubmitting = false,
    this.submissionCount = 0,
  });

  final ExchangePair pair;

  /// Texto del campo. Cambia desde afuera solo con `ExchangePrefilled`.
  final String amountText;

  /// `null` si el texto está vacío, es inválido o no es mayor que cero.
  final Decimal? amount;

  final QuoteStatus quote;

  /// Para deshabilitar monedas sin cotización en los sheets.
  final PairAvailability availability;

  final bool isSubmitting;

  /// Cambios confirmados; la UI muestra la confirmación cuando aumenta.
  final int submissionCount;

  /// La cotización vigente, solo si corresponde al par y al monto actuales.
  ExchangeQuote? get currentQuote {
    final status = quote;
    if (status is! QuoteLoaded) return null;
    final loaded = status.quote;
    if (loaded.pair != pair || loaded.amount != amount) return null;
    return loaded;
  }

  bool get canSubmit => currentQuote != null && !isSubmitting;

  ExchangeState copyWith({
    ExchangePair? pair,
    String? amountText,
    ValueGetter<Decimal?>? amount,
    QuoteStatus? quote,
    PairAvailability? availability,
    bool? isSubmitting,
    int? submissionCount,
  }) {
    return ExchangeState(
      pair: pair ?? this.pair,
      amountText: amountText ?? this.amountText,
      amount: amount != null ? amount() : this.amount,
      quote: quote ?? this.quote,
      availability: availability ?? this.availability,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submissionCount: submissionCount ?? this.submissionCount,
    );
  }

  @override
  List<Object?> get props => [
    pair,
    amountText,
    amount,
    quote,
    availability,
    isSubmitting,
    submissionCount,
  ];
}
