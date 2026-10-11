import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../../core/ads/ads_service.dart';
import '../../../core/billing/remove_ads_service.dart';
import '../../../core/billing/remove_ads_sheet.dart';
import '../../../core/feedback/feedback_service.dart';
import '../../../core/locale/locale_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_mode_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../legal/privacy_policy_screen.dart';
import '../../trips/services/reminders_service.dart';

/// The Settings tab: language and theme, bug report/suggestion (by email),
/// a test notification, ad privacy, privacy policy and app version.
/// Everything in the app is local to this device — there's no account.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.accountTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 110),
          children: [
            const _RemoveAdsGroup(),
            _SettingsGroup(
              title: l10n.settingsPreferencesHeader,
              tiles: [
                _SettingsTile(
                  icon: Icons.translate_rounded,
                  title: l10n.languageSectionTitle,
                  value: _languageLabel(l10n, locale),
                  onTap: () => _openLanguagePicker(context, ref),
                ),
                _SettingsTile(
                  icon: switch (themeMode) {
                    ThemeMode.light => Icons.light_mode_rounded,
                    ThemeMode.dark => Icons.dark_mode_rounded,
                    ThemeMode.system => Icons.brightness_auto_rounded,
                  },
                  title: l10n.themeSectionTitle,
                  value: _themeLabel(l10n, themeMode),
                  onTap: () => _openThemePicker(context, ref),
                ),
              ],
            ),
            _SettingsGroup(
              title: l10n.settingsHelpHeader,
              tiles: [
                _SettingsTile(
                  icon: Icons.feedback_outlined,
                  title: l10n.accountSendFeedbackButton,
                  value: l10n.accountFeedbackPrompt,
                  onTap: () => _openFeedbackSheet(context),
                ),
                _SettingsTile(
                  icon: Icons.notifications_active_outlined,
                  title: l10n.accountSendTestNotificationButton,
                  value: l10n.accountNotifTestSubtitle,
                  onTap: () async {
                    await RemindersService.instance.requestPermission();
                    await RemindersService.instance.showTestNotification();
                  },
                ),
              ],
            ),
            FutureBuilder<bool>(
              future: adsService.isPrivacyOptionsRequired(),
              builder: (context, snapshot) => _SettingsGroup(
                title: l10n.settingsPrivacyHeader,
                tiles: [
                  // Only where the law requires a way to revisit ad
                  // consent (EU/UK).
                  if (snapshot.data == true)
                    _SettingsTile(
                      icon: Icons.ads_click_rounded,
                      title: l10n.settingsAdPrivacyButton,
                      onTap: adsService.showPrivacyOptions,
                    ),
                  _SettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    title: l10n.accountPrivacyPolicyButton,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PrivacyPolicyScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Center(child: _AppVersionLabel()),
          ],
        ),
      ),
    );
  }

  static const _systemLocaleCode = 'system';
  static const _languageNames = {
    'es': 'Español',
    'en': 'English',
    'fr': 'Français',
  };

  String _languageLabel(AppLocalizations l10n, Locale? locale) =>
      _languageNames[locale?.languageCode] ?? l10n.languageSystemDefault;

  String _themeLabel(AppLocalizations l10n, ThemeMode mode) => switch (mode) {
    ThemeMode.light => l10n.themeLight,
    ThemeMode.dark => l10n.themeDark,
    ThemeMode.system => l10n.themeSystem,
  };

  Future<void> _openLanguagePicker(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final currentCode =
        ref.read(localeProvider)?.languageCode ?? _systemLocaleCode;
    final options = <String, String>{
      _systemLocaleCode: l10n.languageSystemDefault,
      ..._languageNames,
    };
    final selectedCode = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.languageDialogTitle),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        children: [
          for (final entry in options.entries)
            RadioListTile<String>(
              value: entry.key,
              // ignore: deprecated_member_use
              groupValue: currentCode,
              title: Text(entry.value),
              // ignore: deprecated_member_use
              onChanged: (value) => Navigator.of(context).pop(value),
            ),
        ],
      ),
    );
    if (selectedCode == null) return;
    await ref
        .read(localeProvider.notifier)
        .setLocale(
          selectedCode == _systemLocaleCode ? null : Locale(selectedCode),
        );
  }

  Future<void> _openThemePicker(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final current = ref.read(themeModeProvider);
    final selected = await showDialog<ThemeMode>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.themeDialogTitle),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        children: [
          for (final mode in [
            ThemeMode.system,
            ThemeMode.light,
            ThemeMode.dark,
          ])
            RadioListTile<ThemeMode>(
              value: mode,
              // ignore: deprecated_member_use
              groupValue: current,
              title: Text(_themeLabel(l10n, mode)),
              // ignore: deprecated_member_use
              onChanged: (value) => Navigator.of(context).pop(value),
            ),
        ],
      ),
    );
    if (selected == null) return;
    await ref.read(themeModeProvider.notifier).setThemeMode(selected);
  }

  Future<void> _openFeedbackSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _FeedbackSheet(),
    );
  }
}

/// "Quitar anuncios" (or a thank-you once bought) plus "Restaurar compra".
class _RemoveAdsGroup extends StatelessWidget {
  const _RemoveAdsGroup();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ValueListenableBuilder<bool>(
      valueListenable: removeAdsService.adsRemoved,
      builder: (context, adsRemoved, _) =>
          ValueListenableBuilder<ProductDetails?>(
            valueListenable: removeAdsService.product,
            builder: (context, product, _) => _SettingsGroup(
              title: l10n.settingsAdsHeader,
              tiles: [
                if (adsRemoved)
                  _SettingsTile(
                    icon: Icons.favorite_rounded,
                    title: l10n.removeAdsSettingsOwned,
                    onTap: () {},
                  )
                else
                  _SettingsTile(
                    icon: Icons.block_rounded,
                    title: l10n.removeAdsSettingsTitle,
                    value: l10n.removeAdsSettingsSubtitle(
                      product?.price ?? '4,99 €',
                    ),
                    onTap: () => showRemoveAdsSheet(context),
                  ),
                _SettingsTile(
                  icon: Icons.restore_rounded,
                  title: l10n.removeAdsRestore,
                  onTap: removeAdsService.restore,
                ),
              ],
            ),
          ),
    );
  }
}

/// A titled card holding a few [_SettingsTile] rows, separated by dividers.
class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.tiles});

  final String title;
  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).textTheme.bodySmall?.color;
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 6, bottom: 8),
            child: Text(
              title.toUpperCase(),
              style: AppTextStyles.caption.copyWith(
                color: secondary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Material(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(22),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < tiles.length; i++) ...[
                  if (i > 0) const Divider(height: 1, indent: 68),
                  tiles[i],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One tappable settings row: icon badge, title, optional current value or
/// hint underneath, and a chevron so it clearly reads as a button.
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.value,
  });

  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).textTheme.bodySmall?.color;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Fixed light badge + fixed dark icon: reads the same in both
            // themes (both halves of the color pairing are constants).
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.accentSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyStrong.copyWith(color: onSurface),
                  ),
                  if (value != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      value!,
                      style: AppTextStyles.caption.copyWith(color: secondary),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: secondary),
          ],
        ),
      ),
    );
  }
}

class _FeedbackSheet extends StatefulWidget {
  const _FeedbackSheet();

  @override
  State<_FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends State<_FeedbackSheet> {
  final _messageController = TextEditingController();
  FeedbackType _type = FeedbackType.bug;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;
    final opened = await feedbackService.openEmail(
      type: _type,
      message: message,
    );
    if (!mounted) return;
    if (opened) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).feedbackErrorSubmit),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).textTheme.bodySmall?.color;
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.feedbackSheetTitle,
              style: AppTextStyles.title.copyWith(color: onSurface),
            ),
            const SizedBox(height: 16),
            SegmentedButton<FeedbackType>(
              segments: [
                ButtonSegment(
                  value: FeedbackType.bug,
                  label: Text(l10n.feedbackTypeBug),
                  icon: const Icon(Icons.bug_report_outlined),
                ),
                ButtonSegment(
                  value: FeedbackType.suggestion,
                  label: Text(l10n.feedbackTypeSuggestion),
                  icon: const Icon(Icons.lightbulb_outline_rounded),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (selection) =>
                  setState(() => _type = selection.first),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _messageController,
              maxLines: 5,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(hintText: l10n.feedbackMessageHint),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.feedbackSignedInContactNote,
              style: AppTextStyles.caption.copyWith(color: secondary),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _messageController.text.trim().isEmpty
                    ? null
                    : _submit,
                child: Text(l10n.commonSend),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppVersionLabel extends StatelessWidget {
  const _AppVersionLabel();

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).textTheme.bodySmall?.color;
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final info = snapshot.data;
        if (info == null) return const SizedBox.shrink();
        return Text(
          'Kipack v${info.version}',
          style: AppTextStyles.caption.copyWith(color: secondary),
        );
      },
    );
  }
}
