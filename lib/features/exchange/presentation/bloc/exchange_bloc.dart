import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:coding_dorado/core/error/failure.dart';
import 'package:coding_dorado/core/formatting/amount_formatter.dart';
import 'package:coding_dorado/features/exchange/domain/catalog/currency_catalog.dart';
import 'package:coding_dorado/features/exchange/domain/entities/currency.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_pair.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_quote.dart';
import 'package:coding_dorado/features/exchange/domain/entities/pair_availability.dart';
import 'package:coding_dorado/features/exchange/domain/repositories/exchange_repository.dart';
import 'package:coding_dorado/features/exchange/domain/usecases/get_exchange_quote.dart';
import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'exchange_event.dart';
part 'exchange_state.dart';

/// Estado de una calculadora. Hay una instancia por pestaña; el bloc no sabe
/// de qué proveedor es: recibe su `GetExchangeQuote` y su repositorio.
///
/// Concurrencia: todas las cotizaciones pasan por un único handler
/// `restartable`. El debounce vive dentro de ese handler (espera y, si llegó
/// otro evento mientras tanto, termina sin consultar), así una respuesta
/// vieja nunca pisa a una nueva.
class ExchangeBloc extends Bloc<ExchangeEvent, ExchangeState> {
  ExchangeBloc({
    required GetExchangeQuote getQuote,
    required ExchangeRepository repository,
    ExchangePair? initialPair,
    this.quoteDebounce = const Duration(milliseconds: 300),
  }) : _getQuote = getQuote,
       _repository = repository,
       _initialPair = initialPair ?? defaultPair(),
       super(ExchangeState(pair: initialPair ?? defaultPair())) {
    on<ExchangeStarted>(_onStarted);
    on<ExchangeAmountChanged>(_onAmountChanged);
    on<ExchangeFromCurrencySelected>(_onFromSelected);
    on<ExchangeToCurrencySelected>(_onToSelected);
    on<ExchangeCurrenciesSwapped>(_onSwapped);
    on<ExchangePrefilled>(_onPrefilled);
    on<ExchangeRatesRefreshed>(_onRefreshed);
    on<ExchangeAppResumed>(_onResumed);
    on<ExchangeReset>(_onReset);
    on<_QuoteRequested>(_onQuoteRequested, transformer: restartable());
  }

  /// Par inicial del diseño: USDT → VES.
  static ExchangePair defaultPair() =>
      ExchangePair(from: CurrencyCatalog.usdt, to: CurrencyCatalog.ves);

  final Duration quoteDebounce;
  final GetExchangeQuote _getQuote;
  final ExchangeRepository _repository;
  final ExchangePair _initialPair;

  Future<void> _onStarted(
    ExchangeStarted event,
    Emitter<ExchangeState> emit,
  ) async {
    final availability = await _repository.getAvailability();
    emit(state.copyWith(availability: availability));
  }

  void _onAmountChanged(
    ExchangeAmountChanged event,
    Emitter<ExchangeState> emit,
  ) {
    final amount = AmountFormatter.tryParsePositive(event.text);
    emit(
      state.copyWith(
        amountText: event.text,
        amount: () => amount,
        quote: amount == null ? const QuoteIdle() : null,
      ),
    );
    add(_QuoteRequested(delay: amount == null ? Duration.zero : quoteDebounce));
  }

  void _onFromSelected(
    ExchangeFromCurrencySelected event,
    Emitter<ExchangeState> emit,
  ) {
    final current = state.pair;
    if (event.currency == current.from ||
        event.currency.type != current.from.type) {
      return;
    }
    emit(state.copyWith(pair: current.withFrom(event.currency)));
    add(const _QuoteRequested());
  }

  void _onToSelected(
    ExchangeToCurrencySelected event,
    Emitter<ExchangeState> emit,
  ) {
    final current = state.pair;
    if (event.currency == current.to ||
        event.currency.type != current.to.type) {
      return;
    }
    emit(state.copyWith(pair: current.withTo(event.currency)));
    add(const _QuoteRequested());
  }

  void _onSwapped(
    ExchangeCurrenciesSwapped event,
    Emitter<ExchangeState> emit,
  ) {
    emit(state.copyWith(pair: state.pair.swapped()));
    add(const _QuoteRequested());
  }

  void _onPrefilled(ExchangePrefilled event, Emitter<ExchangeState> emit) {
    emit(
      state.copyWith(
        pair: event.pair,
        amount: () => event.amount,
        amountText: AmountFormatter.editable(event.amount),
      ),
    );
    add(const _QuoteRequested());
  }

  void _onRefreshed(
    ExchangeRatesRefreshed event,
    Emitter<ExchangeState> emit,
  ) {
    add(const _QuoteRequested(forceRefresh: true));
  }

  void _onResumed(ExchangeAppResumed event, Emitter<ExchangeState> emit) {
    if (state.amount != null) add(const _QuoteRequested());
  }

  /// Conserva la disponibilidad (no depende del par) y cancela cualquier
  /// cotización en curso.
  void _onReset(ExchangeReset event, Emitter<ExchangeState> emit) {
    emit(ExchangeState(pair: _initialPair, availability: state.availability));
    add(const _QuoteRequested());
  }

  Future<void> _onQuoteRequested(
    _QuoteRequested event,
    Emitter<ExchangeState> emit,
  ) async {
    if (event.delay > Duration.zero) {
      await Future<void>.delayed(event.delay);
      if (emit.isDone) return;
    }

    final amount = state.amount;
    if (amount == null) {
      emit(state.copyWith(quote: const QuoteIdle()));
      return;
    }

    emit(
      state.copyWith(quote: QuoteLoading(previous: state.quote.latestQuote)),
    );
    final result = await _getQuote(
      state.pair,
      amount,
      forceRefresh: event.forceRefresh,
    );
    if (emit.isDone) return;
    emit(
      state.copyWith(
        quote: result.fold(
          onFailure: QuoteFailed.new,
          onSuccess: QuoteLoaded.new,
        ),
      ),
    );

    // Con la caché ya cargada, actualizar la disponibilidad cuesta poco.
    if (event.forceRefresh || !state.availability.isKnown) {
      final availability = await _repository.getAvailability();
      if (emit.isDone) return;
      emit(state.copyWith(availability: availability));
    }
  }
}
