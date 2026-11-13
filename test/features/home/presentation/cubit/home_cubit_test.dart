import 'package:bloc_test/bloc_test.dart';
import 'package:coding_dorado/features/exchange/domain/entities/rate_provider.dart';
import 'package:coding_dorado/features/home/presentation/cubit/home_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('arranca en la primera pestaña (El Dorado)', () {
    expect(HomeCubit().state, RateProvider.eldorado);
  });

  blocTest<HomeCubit, RateProvider>(
    'select cambia de pestaña',
    build: HomeCubit.new,
    act: (cubit) => cubit.select(RateProvider.criptoya),
    expect: () => [RateProvider.criptoya],
  );

  blocTest<HomeCubit, RateProvider>(
    'seleccionar la pestaña activa no emite',
    build: HomeCubit.new,
    act: (cubit) => cubit.select(RateProvider.eldorado),
    expect: () => <RateProvider>[],
  );
}
