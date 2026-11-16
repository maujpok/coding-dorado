import 'dart:async';

import 'package:coding_dorado/core/design_system/design_system.dart';
import 'package:coding_dorado/core/error/failure.dart';
import 'package:coding_dorado/core/formatting/amount_formatter.dart';
import 'package:coding_dorado/features/checkout/domain/entities/exchange_transaction.dart';
import 'package:coding_dorado/features/checkout/domain/usecases/submit_exchange.dart';
import 'package:coding_dorado/features/checkout/presentation/cubit/checkout_cubit.dart';
import 'package:coding_dorado/features/checkout/presentation/pages/checkout_page_frame.dart';
import 'package:coding_dorado/features/checkout/presentation/pages/checkout_success_page.dart';
import 'package:coding_dorado/features/checkout/presentation/widgets/processing_animation.dart';
import 'package:coding_dorado/features/checkout/presentation/widgets/processing_steps.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_quote.dart';
import 'package:coding_dorado/l10n/gen/app_localizations.dart';
import 'package:coding_dorado/l10n/l10n_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pantalla completa mientras se ejecuta el cambio: animación y pasos sobre
/// amarillo. Mientras procesa no se puede salir.
///
/// Al terminar reemplaza su ruta por la de éxito (así "atrás" desde el
/// comprobante vuelve a la calculadora) y completa la ruta con la
/// transacción: quien la abrió sabe que el cambio se hizo. Si se sale desde
/// el error, la ruta devuelve `null`.
class CheckoutProcessingPage extends StatelessWidget {
  const CheckoutProcessingPage({super.key});

  static Route<ExchangeTransaction> route({
    required ExchangeQuote quote,
    required SubmitExchange submitExchange,
    Duration minDuration = CheckoutCubit.defaultMinDuration,
  }) {
    return PageRouteBuilder<ExchangeTransaction>(
      settings: const RouteSettings(name: 'checkout/processing'),
      transitionDuration: AppMotion.slow,
      reverseTransitionDuration: AppMotion.normal,
      pageBuilder: (context, _, _) => BlocProvider(
        create: (_) {
          final cubit = CheckoutCubit(
            submitExchange: submitExchange,
            quote: quote,
            minDuration: minDuration,
          );
          unawaited(cubit.submit());
          return cubit;
        },
        child: const CheckoutProcessingPage(),
      ),
      transitionsBuilder: (context, animation, _, child) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: AppMotion.curve),
        child: child,
      ),
    );
  }

  /// Pausa para ver el último paso completo antes de pasar al comprobante.
  static const Duration successHold = AppMotion.slow;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return BlocConsumer<CheckoutCubit, CheckoutState>(
      listenWhen: (previous, current) => current is CheckoutSucceeded,
      listener: (context, state) async {
        final transaction = (state as CheckoutSucceeded).transaction;
        final navigator = Navigator.of(context);
        await Future<void>.delayed(successHold);
        if (!context.mounted) return;
        unawaited(
          navigator.pushReplacement(
            CheckoutSuccessPage.route(transaction),
            result: transaction,
          ),
        );
      },
      builder: (context, state) {
        final failed = state is CheckoutFailed;
        return PopScope(
          canPop: failed,
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.dark,
            child: Scaffold(
              body: AnimatedContainer(
                duration: AppMotion.slow,
                curve: AppMotion.curve,
                color: failed ? colors.background : colors.primary,
                child: CheckoutPageFrame(
                  child: AnimatedSwitcher(
                    duration: AppMotion.normal,
                    child: switch (state) {
                      CheckoutFailed(:final failure) => _FailedBody(
                        key: ValueKey('failed-${state.attempt}'),
                        failure: failure,
                      ),
                      _ => _ProcessingBody(
                        key: ValueKey('processing-${state.attempt}'),
                        completed: state is CheckoutSucceeded,
                      ),
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProcessingBody extends StatefulWidget {
  const _ProcessingBody({required this.completed, super.key});

  final bool completed;

  @override
  State<_ProcessingBody> createState() => _ProcessingBodyState();
}

class _ProcessingBodyState extends State<_ProcessingBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: context.read<CheckoutCubit>().minDuration,
  )..forward();

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final quote = context.read<CheckoutCubit>().quote;
    final amount = AmountFormatter.format(quote.amount);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const ProcessingAnimation(),
        const SizedBox(height: AppSpacing.xxl),
        Semantics(
          header: true,
          liveRegion: true,
          child: Text(
            l10n.processingTitle,
            textAlign: TextAlign.center,
            style: AppTypography.display.copyWith(color: colors.onPrimary),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Semantics(
          label: l10n.exchangeSubject(
            amount,
            quote.pair.from.code,
            quote.pair.to.code,
          ),
          excludeSemantics: true,
          child: DsConversionText(
            from: '$amount ${quote.pair.from.code}',
            to: quote.pair.to.code,
            style: AppTypography.bodyStrong.copyWith(
              color: colors.onPrimarySecondary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxxl),
        ProcessingSteps(
          labels: [
            l10n.processingStepValidate,
            l10n.processingStepExchange,
            l10n.processingStepConfirm,
          ],
          progress: _progress,
          completed: widget.completed,
        ),
      ],
    );
  }
}

class _FailedBody extends StatelessWidget {
  const _FailedBody({required this.failure, super.key});

  final Failure failure;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<CheckoutCubit>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: colors.errorContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 36,
              color: colors.error,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Semantics(
          header: true,
          liveRegion: true,
          child: Text(
            l10n.processingFailedTitle,
            textAlign: TextAlign.center,
            style: AppTypography.title.copyWith(color: colors.textPrimary),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.failureMessage(
            failure,
            provider: cubit.quote.provider,
            from: cubit.quote.pair.from,
          ),
          textAlign: TextAlign.center,
          style: AppTypography.body.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xxl),
        DsPrimaryButton(label: l10n.retryAction, onPressed: cubit.submit),
        const SizedBox(height: AppSpacing.xs),
        DsTextButton(
          label: l10n.backAction,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ],
    );
  }
}
