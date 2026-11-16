import 'package:coding_dorado/features/exchange/domain/catalog/currency_catalog.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_pair.dart';
import 'package:coding_dorado/features/exchange/presentation/bloc/exchange_bloc.dart';
import 'package:coding_dorado/features/exchange/presentation/widgets/currency_picker_sheet.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Abre el selector de TENGO con las monedas que la fuente cotiza y aplica
/// la elegida al `ExchangeBloc` del árbol. Lo usan la calculadora y la
/// confirmación.
Future<void> selectFromCurrency(BuildContext context) async {
  final bloc = context.read<ExchangeBloc>();
  final state = bloc.state;
  final currency = await showCurrencyPicker(
    context: context,
    type: state.pair.from.type,
    selected: state.pair.from,
    isAvailable: (candidate) =>
        state.availability.isAvailable(state.pair.withFrom(candidate)),
  );
  if (currency != null) bloc.add(ExchangeFromCurrencySelected(currency));
}

/// Como [selectFromCurrency], para QUIERO.
Future<void> selectToCurrency(BuildContext context) async {
  final bloc = context.read<ExchangeBloc>();
  final state = bloc.state;
  final currency = await showCurrencyPicker(
    context: context,
    type: state.pair.to.type,
    selected: state.pair.to,
    isAvailable: (candidate) =>
        state.availability.isAvailable(state.pair.withTo(candidate)),
  );
  if (currency != null) bloc.add(ExchangeToCurrencySelected(currency));
}

/// "Elegir otra moneda" cuando el par no está disponible. Si la fuente no
/// cotiza la crypto con ninguna fiat (USDC en El Dorado), el problema es la
/// crypto; si no, la fiat.
Future<void> selectUnavailableSide(BuildContext context) {
  final state = context.read<ExchangeBloc>().state;
  final pair = state.pair;
  final cryptoQuoted = CurrencyCatalog.fiats.any(
    (fiat) =>
        state.availability.isAvailable(
          ExchangePair(from: pair.crypto, to: fiat),
        ) ||
        state.availability.isAvailable(
          ExchangePair(from: fiat, to: pair.crypto),
        ),
  );
  final pickCryptoSide = !cryptoQuoted;
  final fromIsTarget = pickCryptoSide == pair.from.isCrypto;
  return fromIsTarget ? selectFromCurrency(context) : selectToCurrency(context);
}
