import 'package:coding_dorado/core/design_system/design_system.dart';
import 'package:coding_dorado/features/exchange/domain/entities/currency.dart';
import 'package:coding_dorado/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Campo del monto: el código de la moneda como prefijo (etiqueta amarilla)
/// y teclado decimal con hasta 2 decimales.
class AmountField extends StatefulWidget {
  const AmountField({
    required this.currency,
    required this.text,
    required this.onChanged,
    this.hasError = false,
    super.key,
  });

  final Currency currency;

  /// Texto del estado. Solo se aplica al campo si cambió desde afuera.
  final String text;
  final ValueChanged<String> onChanged;
  final bool hasError;

  @override
  State<AmountField> createState() => _AmountFieldState();
}

class _AmountFieldState extends State<AmountField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.text,
  );
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(AmountField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.text,
        selection: TextSelection.collapsed(offset: widget.text.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final focused = _focusNode.hasFocus;
    final borderColor = widget.hasError
        ? colors.error
        : focused
        ? colors.outline
        : colors.fieldBorder;

    return GestureDetector(
      onTap: _focusNode.requestFocus,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        height: AppSizes.fieldHeight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.control),
          border: Border.all(
            color: borderColor,
            width: focused || widget.hasError
                ? AppSizes.borderStrong
                : AppSizes.borderThin,
          ),
        ),
        child: Row(
          children: [
            DsBadge(
              label: widget.currency.code,
              textStyle: AppTypography.bodyStrong,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Semantics(
                label: l10n.amountSemantics(widget.currency.code),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  onChanged: widget.onChanged,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.done,
                  inputFormatters: [AmountInputFormatter()],
                  style: AppTypography.body.copyWith(color: colors.textPrimary),
                  cursorColor: colors.textPrimary,
                  decoration: InputDecoration.collapsed(
                    hintText: l10n.amountHint,
                    hintStyle: AppTypography.body.copyWith(
                      color: colors.textDisabled,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Solo dígitos y un separador decimal (punto o coma), con hasta
/// [maxDecimals] decimales y [maxIntegerDigits] enteros.
class AmountInputFormatter extends TextInputFormatter {
  AmountInputFormatter({this.maxDecimals = 2, this.maxIntegerDigits = 12})
    : _pattern = RegExp(
        '^\\d{0,$maxIntegerDigits}([.,]\\d{0,$maxDecimals})?\$',
      );

  final int maxDecimals;
  final int maxIntegerDigits;
  final RegExp _pattern;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => _pattern.hasMatch(newValue.text) ? newValue : oldValue;
}
