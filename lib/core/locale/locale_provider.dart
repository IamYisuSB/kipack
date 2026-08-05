import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/local_store.dart';

const _localeKey = 'app_locale';

/// The user's manually chosen language, or null to follow the device's
/// system locale (the default). Persisted so an explicit choice survives
/// app restarts.
class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier() : super(null) {
    _load();
  }

  Future<void> _load() async {
    final code = await LocalStore.instance.readString(_localeKey);
    if (code != null) state = Locale(code);
  }

  Future<void> setLocale(Locale? locale) async {
    state = locale;
    if (locale == null) {
      await LocalStore.instance.remove(_localeKey);
    } else {
      await LocalStore.instance.writeString(_localeKey, locale.languageCode);
    }
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  return LocaleNotifier();
});
