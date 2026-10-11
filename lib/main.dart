import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/locale/locale_provider.dart';
import 'core/navigation/root_gate.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_provider.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  for (final locale in AppLocalizations.supportedLocales) {
    await initializeDateFormatting(locale.languageCode);
  }

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // No .env — AI generation falls back to the rule-based generator.
  }

  runApp(const ProviderScope(child: KipackApp()));
}

class KipackApp extends ConsumerWidget {
  const KipackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: 'Kipack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        if (deviceLocale != null &&
            supportedLocales.any(
              (l) => l.languageCode == deviceLocale.languageCode,
            )) {
          return deviceLocale;
        }
        return const Locale('es');
      },
      home: const RootGate(),
    );
  }
}
