import 'package:coding_dorado/core/design_system/design_system.dart';
import 'package:coding_dorado/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';

/// Se muestra en lugar de la app cuando se ejecutó sin el `.env`: sin esta
/// pantalla, la app quedaría en el splash y el error solo se vería en la
/// consola.
class ConfigErrorApp extends StatelessWidget {
  const ConfigErrorApp({required this.missingKeys, super.key});

  final List<String> missingKeys;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: _ConfigErrorPage(missingKeys: missingKeys),
    );
  }
}

class _ConfigErrorPage extends StatelessWidget {
  const _ConfigErrorPage({required this.missingKeys});

  final List<String> missingKeys;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final body = AppTypography.body.copyWith(color: colors.textSecondary);
    return Scaffold(
      body: DsBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: AppLayout.horizontalMargin(constraints.maxWidth),
                vertical: AppSpacing.xxl,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 2 * AppSpacing.xxl,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppSizes.contentMaxWidth,
                    ),
                    child: DsCard(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.settings_outlined,
                            size: AppSizes.iconLarge,
                            color: colors.error,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Semantics(
                            header: true,
                            child: Text(
                              l10n.configErrorTitle,
                              style: AppTypography.title.copyWith(
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            l10n.configErrorMissing(missingKeys.join(', ')),
                            style: body,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(l10n.configErrorHint, style: body),
                          const SizedBox(height: AppSpacing.sm),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: colors.surfaceMuted,
                              borderRadius: BorderRadius.circular(
                                AppRadius.control,
                              ),
                            ),
                            child: SelectableText(
                              l10n.configErrorCommand,
                              style: AppTypography.caption.copyWith(
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
