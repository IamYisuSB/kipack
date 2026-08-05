import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/auth/password_recovery_guard.dart';
import 'core/locale/locale_provider.dart';
import 'core/navigation/root_gate.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  for (final locale in AppLocalizations.supportedLocales) {
    await initializeDateFormatting(locale.languageCode);
  }

  try {
    await dotenv.load(fileName: '.env');
    final url = dotenv.maybeGet('SUPABASE_URL');
    final anonKey = dotenv.maybeGet('SUPABASE_ANON_KEY');
    if (url != null && anonKey != null) {
      await Supabase.initialize(url: url, publishableKey: anonKey);
      // If the app was closed mid password-reset (recovery session never
      // turned into a real password change), don't let that session count
      // as signed in — see PasswordRecoveryGuard for why this matters.
      if (await passwordRecoveryGuard.isPending()) {
        await Supabase.instance.client.auth.signOut();
        await passwordRecoveryGuard.clear();
      }
    }
  } catch (_) {
    // No .env yet — the app runs fully on local state until backend keys are added.
  }

  runApp(const ProviderScope(child: KipackApp()));
}

class KipackApp extends ConsumerWidget {
  const KipackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return MaterialApp(
      title: 'Kipack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
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
