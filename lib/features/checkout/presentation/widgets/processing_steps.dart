import 'package:coding_dorado/core/design_system/design_system.dart';
import 'package:coding_dorado/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';

enum ProcessingStepStatus { pending, active, done }

/// Lista de pasos que avanza con [progress] (0 → 1). El último paso solo
/// se completa con [completed]: depende de la respuesta, no del tiempo.
class ProcessingSteps extends StatelessWidget {
  const ProcessingSteps({
    required this.labels,
    required this.progress,
    required this.completed,
    super.key,
  });

  final List<String> labels;
  final Animation<double> progress;
  final bool completed;

  /// Estado del paso [index] de [count] para un avance [t].
  static ProcessingStepStatus statusOf(
    int index, {
    required int count,
    required double t,
    required bool completed,
  }) {
    final isLast = index == count - 1;
    if (completed || (!isLast && t >= (index + 1) / count)) {
      return ProcessingStepStatus.done;
    }
    return t >= index / count
        ? ProcessingStepStatus.active
        : ProcessingStepStatus.pending;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (index, label) in labels.indexed)
            _StepRow(
              label: label,
              status: statusOf(
                index,
                count: labels.length,
                t: progress.value,
                completed: completed,
              ),
            ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.label, required this.status});

  final String label;
  final ProcessingStepStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final pending = status == ProcessingStepStatus.pending;
    final color = pending ? colors.onPrimarySecondary : colors.onPrimary;

    final leading = switch (status) {
      ProcessingStepStatus.done => Icon(
        Icons.check_circle_rounded,
        key: const ValueKey(ProcessingStepStatus.done),
        size: AppSizes.iconLarge,
        color: colors.onPrimary,
      ),
      ProcessingStepStatus.active => Padding(
        key: const ValueKey(ProcessingStepStatus.active),
        padding: const EdgeInsets.all(AppSpacing.xxs + 1),
        child: CircularProgressIndicator(
          strokeWidth: AppSizes.ringWidth,
          color: colors.onPrimary,
          backgroundColor: colors.onPrimary.withValues(alpha: 0.3),
        ),
      ),
      ProcessingStepStatus.pending => Icon(
        Icons.radio_button_unchecked_rounded,
        key: const ValueKey(ProcessingStepStatus.pending),
        size: AppSizes.iconLarge,
        color: colors.onPrimarySecondary,
      ),
    };

    return Semantics(
      label: switch (status) {
        ProcessingStepStatus.done => l10n.processingStepDone(label),
        ProcessingStepStatus.active => l10n.processingStepActive(label),
        ProcessingStepStatus.pending => l10n.processingStepPending(label),
      },
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs + 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(
              dimension: AppSizes.iconLarge,
              child: AnimatedSwitcher(
                duration: AppMotion.normal,
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: leading,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Flexible(
              child: AnimatedDefaultTextStyle(
                duration: AppMotion.fast,
                style: (pending ? AppTypography.body : AppTypography.bodyStrong)
                    .copyWith(color: color),
                child: Text(label),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
