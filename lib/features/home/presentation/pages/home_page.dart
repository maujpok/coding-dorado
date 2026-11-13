import 'package:coding_dorado/core/design_system/design_system.dart';
import 'package:coding_dorado/features/exchange/domain/entities/rate_provider.dart';
import 'package:coding_dorado/features/exchange/presentation/bloc/exchange_bloc.dart';
import 'package:coding_dorado/features/exchange/presentation/views/exchange_view.dart';
import 'package:coding_dorado/features/home/presentation/cubit/home_cubit.dart';
import 'package:coding_dorado/features/home/presentation/widgets/provider_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

typedef ExchangeBlocFactory = ExchangeBloc Function(RateProvider provider);

/// Home con una pestaña por proveedor. Los `ExchangeBloc` viven acá (no en
/// cada pestaña) para que cada una conserve su estado al cambiar.
///
/// Hay dos blocs del mismo tipo, así que no se buscan por tipo en el árbol:
/// cada pestaña recibe el suyo con `BlocProvider.value`.
class HomePage extends StatefulWidget {
  const HomePage({required this.createExchangeBloc, super.key});

  final ExchangeBlocFactory createExchangeBloc;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeCubit _homeCubit = HomeCubit();
  late final Map<RateProvider, ExchangeBloc> _blocs = {
    for (final provider in RateProvider.values)
      provider: widget.createExchangeBloc(provider)
        ..add(const ExchangeStarted()),
  };

  @override
  void dispose() {
    for (final bloc in _blocs.values) {
      bloc.close().ignore();
    }
    _homeCubit.close().ignore();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _homeCubit,
      child: BlocBuilder<HomeCubit, RateProvider>(
        builder: (context, active) {
          return Scaffold(
            body: DsBackground(
              child: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) => Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          AppLayout.horizontalMargin(constraints.maxWidth),
                          AppSpacing.md,
                          AppLayout.horizontalMargin(constraints.maxWidth),
                          0,
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: AppSizes.contentMaxWidth,
                          ),
                          child: ProviderTabs(
                            selected: active,
                            onChanged: _homeCubit.select,
                          ),
                        ),
                      ),
                      Expanded(
                        child: IndexedStack(
                          index: RateProvider.values.indexOf(active),
                          children: [
                            for (final provider in RateProvider.values)
                              BlocProvider.value(
                                value: _blocs[provider]!,
                                child: ExchangeView(provider: provider),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
