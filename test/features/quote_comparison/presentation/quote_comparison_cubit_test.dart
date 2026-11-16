import 'package:bloc_test/bloc_test.dart';
import 'package:coding_dorado/features/exchange/domain/catalog/currency_catalog.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_pair.dart';
import 'package:coding_dorado/features/exchange/domain/entities/rate_provider.dart';
import 'package:coding_dorado/features/quote_comparison/domain/usecases/compare_quotes.dart';
import 'package:coding_dorado/features/quote_comparison/presentation/cubit/quote_comparison_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_apis/fake_criptoya_api.dart';
import '../../../helpers/pump_app.dart';
import '../../../helpers/test_currencies.dart';

void main() {
  late CompareQuotes compareQuotes;

  CompareQuotes compareWith(CriptoYaScenario criptoya) =>
      fakeApiDependencies(criptoya: criptoya)<CompareQuotes>();

  QuoteComparisonCubit build() => QuoteComparisonCubit(
    compareQuotes: compareQuotes,
    pair: ExchangePair(from: CurrencyCatalog.usdt, to: CurrencyCatalog.ves),
    amount: dec('5'),
  );

  setUp(() => compareQuotes = compareWith(CriptoYaScenario.success));

  test('arranca cargando', () {
    expect(build().state, const ComparisonLoading());
  });

  blocTest<QuoteComparisonCubit, QuoteComparisonState>(
    'load: Loading → Loaded con CriptoYa como mejor opción',
    build: build,
    act: (cubit) => cubit.load(),
    expect: () => [
      isA<ComparisonLoaded>().having(
        (s) => s.comparison.best,
        'best',
        RateProvider.criptoya,
      ),
    ],
  );

  blocTest<QuoteComparisonCubit, QuoteComparisonState>(
    'refresh conserva la comparación anterior mientras carga',
    build: build,
    act: (cubit) async {
      await cubit.load();
      await cubit.refresh();
    },
    expect: () => [
      isA<ComparisonLoaded>(),
      isA<ComparisonLoading>().having((s) => s.previous, 'previous', isNotNull),
      isA<ComparisonLoaded>(),
    ],
  );

  blocTest<QuoteComparisonCubit, QuoteComparisonState>(
    'resultado parcial: CriptoYa limitado, El Dorado responde',
    setUp: () => compareQuotes = compareWith(CriptoYaScenario.rateLimited),
    build: build,
    act: (cubit) => cubit.load(),
    verify: (cubit) {
      final comparison = cubit.state.comparison!;
      expect(comparison.best, RateProvider.eldorado);
      expect(comparison.results[RateProvider.criptoya]?.isOk, isFalse);
    },
  );
}
