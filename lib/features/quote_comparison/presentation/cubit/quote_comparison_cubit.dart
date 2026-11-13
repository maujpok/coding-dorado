import 'package:coding_dorado/features/exchange/domain/entities/exchange_pair.dart';
import 'package:coding_dorado/features/quote_comparison/domain/entities/quote_comparison.dart';
import 'package:coding_dorado/features/quote_comparison/domain/usecases/compare_quotes.dart';
import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class QuoteComparisonState extends Equatable {
  const QuoteComparisonState();

  QuoteComparison? get comparison => null;

  @override
  List<Object?> get props => const [];
}

/// Cargando; conserva la comparación anterior al refrescar.
final class ComparisonLoading extends QuoteComparisonState {
  const ComparisonLoading({this.previous});

  final QuoteComparison? previous;

  @override
  QuoteComparison? get comparison => previous;

  @override
  List<Object?> get props => [previous];
}

final class ComparisonLoaded extends QuoteComparisonState {
  const ComparisonLoaded(this.result);

  final QuoteComparison result;

  @override
  QuoteComparison get comparison => result;

  @override
  List<Object?> get props => [result];
}

/// Estado del sheet de comparación. No hay estado de error: los fallos son
/// por proveedor y viven dentro de la comparación.
class QuoteComparisonCubit extends Cubit<QuoteComparisonState> {
  QuoteComparisonCubit({
    required CompareQuotes compareQuotes,
    required this.pair,
    required this.amount,
  }) : _compareQuotes = compareQuotes,
       super(const ComparisonLoading());

  final CompareQuotes _compareQuotes;
  final ExchangePair pair;
  final Decimal amount;

  Future<void> load({bool forceRefresh = false}) async {
    final loading = ComparisonLoading(previous: state.comparison);
    if (loading != state) emit(loading);
    final comparison = await _compareQuotes(
      pair,
      amount,
      forceRefresh: forceRefresh,
    );
    if (!isClosed) emit(ComparisonLoaded(comparison));
  }

  /// Ignora las cachés.
  Future<void> refresh() => load(forceRefresh: true);
}
