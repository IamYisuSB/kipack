import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/local_store.dart';

const _themeModeKey = 'app_theme_mode';

/// Light/dark/system appearance chosen in Settings. Defaults to following
/// the device; persisted so an explicit choice survives restarts.
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _load();
  }

  Future<void> _load() async {
    final name = await LocalStore.instance.readString(_themeModeKey);
    if (name != null) {
      state = ThemeMode.values.firstWhere(
        (m) => m.name == name,
        orElse: () => ThemeMode.system,
      );
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await LocalStore.instance.writeString(_themeModeKey, mode.name);
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
      return ThemeModeNotifier();
    });
