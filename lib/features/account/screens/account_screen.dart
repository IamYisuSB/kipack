import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/auth/account_deletion_service.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/auth/login_attempts_service.dart';
import '../../../core/auth/password_policy.dart';
import '../../../core/auth/password_requirements_checklist.dart';
import '../../../core/auth/profile_service.dart';
import '../../../core/billing/billing_service.dart';
import '../../../core/feedback/feedback_service.dart';
import '../../../core/premium/premium_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../legal/privacy_policy_screen.dart';
import '../../trips/services/reminders_service.dart';
import '../../../core/locale/locale_provider.dart';
import '../../../l10n/app_localizations.dart';

/// The Account tab: a bug-report/suggestion button open to everyone
/// (guests included), plus account management (sign up/in/out, change
/// password/email/username) gated behind Premium. Creating an account
/// doesn't sync trips or packing lists yet — that's separate, later work
/// this account is the foundation for.
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSignedIn = ref.watch(authStateProvider).asData?.value != null;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.accountTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 110),
          children: [
            // Signing in/up is never Premium-gated — with real purchases,
            // buying Premium requires being signed in first, so gating the
            // sign-in form itself behind Premium would make it impossible
            // for anyone to ever get Premium at all. Account MANAGEMENT
            // once signed in (see _SignedInView) is likewise always
            // reachable regardless of Premium status, so losing/not having
            // it never traps someone with an account they can't close.
            const _AccountBody(),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              l10n.accountFeedbackPrompt,
              style: AppTextStyles.bodyStrong.copyWith(color: onSurface),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _openFeedbackSheet(context),
              icon: const Icon(Icons.feedback_outlined),
              label: Text(l10n.accountSendFeedbackButton),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.accountNotifTestPrompt,
              style: AppTextStyles.bodyStrong.copyWith(color: onSurface),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.accountNotifTestSubtitle,
              style: AppTextStyles.caption.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                await RemindersService.instance.requestPermission();
                await RemindersService.instance.showTestNotification();
              },
              icon: const Icon(Icons.notifications_active_outlined),
              label: Text(l10n.accountSendTestNotificationButton),
            ),
            if (isSignedIn) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _confirmSignOut(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
                icon: const Icon(Icons.logout_rounded),
                label: Text(l10n.commonSignOut),
              ),
            ],
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () => _openLanguagePicker(context, ref),
                child: Text(l10n.languageSectionTitle),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PrivacyPolicyScreen(),
                  ),
                ),
                child: Text(l10n.accountPrivacyPolicyButton),
              ),
            ),
            const SizedBox(height: 20),
            const Center(child: _AppVersionLabel()),
          ],
        ),
      ),
    );
  }

  static const _systemLocaleCode = 'system';

  Future<void> _openLanguagePicker(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final currentCode =
        ref.read(localeProvider)?.languageCode ?? _systemLocaleCode;
    final options = <String, String>{
      _systemLocaleCode: l10n.languageSystemDefault,
      'es': 'Español',
      'en': 'English',
      'fr': 'Français',
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

  Future<void> _confirmSignOut(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.commonSignOut),
        content: Text(l10n.accountSignOutConfirm),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.commonSignOut,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) authService.signOut();
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

class _AccountBody extends ConsumerWidget {
  const _AccountBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isPremium = ref.watch(premiumProvider);

    return authState.when(
      data: (user) => user != null
          ? _SignedInView(user: user, isPremium: isPremium)
          : const _AuthForm(),
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      ),
      error: (_, _) => const _AuthForm(),
    );
  }
}

class _AuthForm extends StatefulWidget {
  const _AuthForm();

  @override
  State<_AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<_AuthForm> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSignUp = false;
  bool _isSubmitting = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _error;
  String? _info;

  Timer? _usernameCheckDebounce;
  String? _usernameCheckedValue;
  bool _usernameChecking = false;
  bool? _usernameAvailable;
  String? _usernameUnavailableReason;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_onUsernameChanged);
    // Only used to redraw the live password-requirements checklist as the
    // user types — the actual value is always read straight off the
    // controller, never stored separately.
    _passwordController.addListener(_onPasswordChanged);
  }

  @override
  void dispose() {
    _usernameCheckDebounce?.cancel();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onPasswordChanged() => setState(() {});

  void _onUsernameChanged() {
    _usernameCheckDebounce?.cancel();
    final value = _usernameController.text.trim();
    setState(() {
      _usernameAvailable = null;
      _usernameUnavailableReason = null;
      _usernameCheckedValue = null;
    });
    if (value.length < 3) return;
    _usernameCheckDebounce = Timer(
      const Duration(milliseconds: 450),
      () => _checkUsername(value),
    );
  }

  Future<void> _checkUsername(String value) async {
    setState(() => _usernameChecking = true);
    try {
      final rows = await Supabase.instance.client.rpc(
        'check_username_available',
        params: {'p_username': value},
      );
      // The user may have kept typing while this was in flight — ignore a
      // stale response for a value that's no longer in the field.
      if (!mounted || _usernameController.text.trim() != value) return;
      final row = (rows as List).first as Map<String, dynamic>;
      setState(() {
        _usernameChecking = false;
        _usernameCheckedValue = value;
        _usernameAvailable = row['available'] as bool;
        _usernameUnavailableReason = row['reason'] as String?;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _usernameChecking = false);
    }
  }

  String _usernameReasonText(AppLocalizations l10n) {
    switch (_usernameUnavailableReason) {
      case 'blocked':
        return l10n.authUsernameBlocked;
      case 'too_short':
        return l10n.authUsernameTooShort;
      default:
        return l10n.authUsernameTaken;
    }
  }

  Widget? _usernameSuffixIcon() {
    final value = _usernameController.text.trim();
    if (value.length < 3) return null;
    if (_usernameChecking) {
      return const Padding(
        padding: EdgeInsets.all(14),
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    if (_usernameCheckedValue != value) return null;
    if (_usernameAvailable == true) {
      return const Icon(Icons.check_circle_rounded, color: AppColors.success);
    }
    if (_usernameAvailable == false) {
      return const Icon(Icons.cancel_rounded, color: AppColors.error);
    }
    return null;
  }

  /// Supabase's rate-limit errors ("over_email_send_rate_limit" etc.) come
  /// back as a raw English message not meant for end users — swap those for
  /// a friendly localized one; every other AuthException still shows
  /// Supabase's own message, same as before.
  ///
  /// Checks both [AuthException.code] and the raw message text: depending
  /// on which API version the Auth server reports for a given response,
  /// the gotrue client may not always populate `code`, so the message text
  /// ("email rate limit exceeded" etc.) is the one signal that's reliably
  /// always present.
  String _messageFor(AuthException error) {
    final l10n = AppLocalizations.of(context);
    final code = error.code?.toLowerCase() ?? '';
    final message = error.message.toLowerCase();
    if (code.contains('rate_limit') || message.contains('rate limit')) {
      return l10n.authErrorRateLimited;
    }
    return error.message;
  }

  Future<void> _submit() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty || _isSubmitting) return;
    final l10n = AppLocalizations.of(context);
    if (_isSignUp && username.isEmpty) {
      setState(() => _error = l10n.authErrorChooseUsername);
      return;
    }
    if (_isSignUp && password != _confirmPasswordController.text) {
      setState(() => _error = l10n.authErrorPasswordMismatch);
      return;
    }
    if (_isSignUp && !PasswordPolicy.isValid(password)) {
      setState(() => _error = l10n.authErrorWeakPassword);
      return;
    }
    if (_isSignUp && _usernameAvailable != true) {
      setState(
        () => _error = _usernameAvailable == false
            ? _usernameReasonText(l10n)
            : l10n.authErrorChooseUsername,
      );
      return;
    }

    if (!_isSignUp) {
      final lockStatus = await loginAttemptsService.check(email);
      if (!lockStatus.allowed) {
        if (!mounted) return;
        setState(
          () => _error = l10n.authErrorLockedOut(
            _minutesUntil(lockStatus.lockedUntil),
          ),
        );
        return;
      }
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
      _info = null;
    });
    try {
      if (_isSignUp) {
        final response = await authService.signUp(
          email: email,
          password: password,
          username: username,
        );
        if (!mounted) return;
        if (response.session == null) {
          setState(() => _info = l10n.authInfoAccountCreated);
        }
      } else {
        await authService.signIn(email: email, password: password);
        await loginAttemptsService.clear(email);
      }
    } on AuthException catch (error) {
      if (!mounted) return;
      if (!_isSignUp && _isWrongCredentials(error)) {
        final status = await loginAttemptsService.recordFailure(email);
        if (!mounted) return;
        setState(() {
          _error = status.allowed
              ? l10n.authErrorWrongPasswordAttempts(status.remainingAttempts)
              : l10n.authErrorLockedOut(_minutesUntil(status.lockedUntil));
        });
      } else {
        setState(() => _error = _messageFor(error));
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = l10n.authErrorGeneric);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  /// Only "wrong password" failures count toward the lockout — a network
  /// hiccup or an already-rate-limited request shouldn't burn an attempt.
  bool _isWrongCredentials(AuthException error) =>
      error.message.toLowerCase().contains('invalid login credentials');

  int _minutesUntil(DateTime? time) {
    if (time == null) return 0;
    final diff = time.difference(DateTime.now());
    return diff.isNegative ? 0 : (diff.inSeconds / 60).ceil();
  }

  Future<void> _forgotPassword() async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(
      text: _emailController.text.trim(),
    );
    final email = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.authForgotPasswordTitle),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(hintText: l10n.authEmailHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: Text(l10n.authSendCodeButton),
          ),
        ],
      ),
    );
    if (email == null || email.isEmpty || !mounted) return;
    try {
      await authService.sendPasswordResetEmail(email);
      if (!mounted) return;
      await _promptResetCode(email);
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() => _error = _messageFor(error));
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = l10n.authErrorSendEmailFailed);
    }
  }

  /// Prompts for the 8-digit code just emailed to [email] and exchanges it
  /// for a recovery session — on success `AppShell`'s existing
  /// `AuthChangeEvent.passwordRecovery` listener takes over and pushes
  /// `ResetPasswordScreen`, so there's nothing else to do here.
  Future<void> _promptResetCode(String email) async {
    final l10n = AppLocalizations.of(context);
    final codeController = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.authEnterCodeTitle),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.authResetCodeSentBody(email)),
            const SizedBox(height: 12),
            TextField(
              controller: codeController,
              autofocus: true,
              keyboardType: TextInputType.number,
              maxLength: 8,
              decoration: InputDecoration(hintText: l10n.authCodeHint),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(codeController.text.trim()),
            child: Text(l10n.commonContinue),
          ),
        ],
      ),
    );
    if (code == null || code.isEmpty || !mounted) return;
    try {
      await authService.verifyPasswordResetCode(email: email, code: code);
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() => _error = _messageFor(error));
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = l10n.authErrorGeneric);
    }
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).textTheme.bodySmall?.color;
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _isSignUp ? l10n.authTitleSignUp : l10n.authTitleSignIn,
          style: AppTextStyles.title.copyWith(color: onSurface),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.authSubtitle,
          style: AppTextStyles.body.copyWith(color: secondary),
        ),
        const SizedBox(height: 24),
        if (_isSignUp) ...[
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(
              hintText: l10n.authUsernameHint,
              suffixIcon: _usernameSuffixIcon(),
            ),
          ),
          if (_usernameAvailable == false &&
              _usernameCheckedValue == _usernameController.text.trim()) ...[
            const SizedBox(height: 4),
            Text(
              _usernameReasonText(l10n),
              style: AppTextStyles.caption.copyWith(color: AppColors.error),
            ),
          ],
          const SizedBox(height: 12),
        ],
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          decoration: InputDecoration(hintText: l10n.authEmailFieldHint),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: l10n.authPasswordHint,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        if (_isSignUp)
          PasswordRequirementsChecklist(password: _passwordController.text),
        if (!_isSignUp) ...[
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _isSubmitting ? null : _forgotPassword,
              child: Text(l10n.authForgotPasswordLink),
            ),
          ),
        ],
        if (_isSignUp) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              hintText: l10n.authConfirmPasswordHint,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () => setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword,
                ),
              ),
            ),
          ),
        ],
        if (_error != null) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.12),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              _error!,
              style: AppTextStyles.body.copyWith(color: AppColors.error),
            ),
          ),
        ],
        if (_info != null) ...[
          const SizedBox(height: 12),
          Text(
            _info!,
            style: AppTextStyles.body.copyWith(color: AppColors.success),
          ),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.backgroundLight,
                    ),
                  )
                : Text(_isSignUp ? l10n.authTitleSignUp : l10n.authTitleSignIn),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => setState(() {
            _isSignUp = !_isSignUp;
            _error = null;
            _info = null;
            _confirmPasswordController.clear();
          }),
          child: Text(
            _isSignUp ? l10n.authToggleToSignIn : l10n.authToggleToSignUp,
          ),
        ),
      ],
    );
  }
}

class _SignedInView extends StatefulWidget {
  const _SignedInView({required this.user, required this.isPremium});

  final User user;
  final bool isPremium;

  @override
  State<_SignedInView> createState() => _SignedInViewState();
}

class _SignedInViewState extends State<_SignedInView> {
  String? _displayName;
  String? _avatarUrl;
  DateTime? _premiumExpiresAt;
  bool _loadingProfile = true;
  bool _uploadingAvatar = false;
  bool _restoringPurchases = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final results = await Future.wait([
      profileService.fetchDisplayName(widget.user.id),
      profileService.fetchAvatarUrl(widget.user.id),
    ]);
    final premiumRow = widget.isPremium
        ? await Supabase.instance.client
              .from('profiles')
              .select('premium_expires_at')
              .eq('id', widget.user.id)
              .maybeSingle()
        : null;
    if (!mounted) return;
    setState(() {
      _premiumExpiresAt = DateTime.tryParse(
        premiumRow?['premium_expires_at'] as String? ?? '',
      );
      _displayName = results[0];
      _avatarUrl = results[1];
      _loadingProfile = false;
    });
  }

  Future<void> _openAvatarSheet() async {
    final action = await showModalBottomSheet<_AvatarAction>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _AvatarActionSheet(hasAvatar: _avatarUrl != null),
    );
    if (action == null || !mounted) return;
    switch (action) {
      case _AvatarAction.camera:
        await _pickAndUploadAvatar(ImageSource.camera);
      case _AvatarAction.gallery:
        await _pickAndUploadAvatar(ImageSource.gallery);
      case _AvatarAction.remove:
        await _removeAvatar();
    }
  }

  Future<void> _pickAndUploadAvatar(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source);
    if (picked == null || !mounted) return;
    setState(() => _uploadingAvatar = true);
    try {
      final bytes = await picked.readAsBytes();
      final url = await profileService.uploadAvatar(widget.user.id, bytes);
      if (!mounted) return;
      setState(() => _avatarUrl = url);
    } catch (error) {
      debugPrint('No se pudo subir el avatar: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).accountErrorUploadPhoto),
        ),
      );
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  Future<void> _removeAvatar() async {
    setState(() => _uploadingAvatar = true);
    try {
      await profileService.removeAvatar(widget.user.id);
      if (!mounted) return;
      setState(() => _avatarUrl = null);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).accountErrorRemovePhoto),
        ),
      );
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  Future<void> _changeUsername() async {
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => _UsernameEditDialog(currentName: _displayName ?? ''),
    );
    if (newName == null || newName.isEmpty || !mounted) return;
    try {
      await profileService.updateDisplayName(widget.user.id, newName);
      if (!mounted) return;
      setState(() => _displayName = newName);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).authUsernameTaken)),
      );
    }
  }

  Future<void> _changeEmail() async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final newEmail = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.accountChangeEmailTitle),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(hintText: l10n.accountNewEmailHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: Text(l10n.commonChange),
          ),
        ],
      ),
    );
    if (newEmail == null || newEmail.isEmpty || !mounted) return;
    try {
      await authService.changeEmail(newEmail);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.accountChangeEmailSentNotice)),
      );
    } on AuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _changePassword() async {
    final l10n = AppLocalizations.of(context);
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    String? dialogError;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.accountChangePasswordTitle),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: l10n.accountCurrentPasswordHint,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: newController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: l10n.accountNewPasswordHint,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: confirmController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: l10n.accountConfirmNewPasswordHint,
                ),
              ),
              if (dialogError != null) ...[
                const SizedBox(height: 8),
                Text(
                  dialogError!,
                  style: const TextStyle(color: AppColors.error),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.commonCancel),
            ),
            TextButton(
              onPressed: () {
                if (newController.text != confirmController.text) {
                  setDialogState(
                    () => dialogError = l10n.accountErrorNewPasswordMismatch,
                  );
                  return;
                }
                if (newController.text.isEmpty ||
                    currentController.text.isEmpty) {
                  setDialogState(
                    () => dialogError = l10n.accountErrorFillAllFields,
                  );
                  return;
                }
                Navigator.of(context).pop(true);
              },
              child: Text(l10n.commonChange),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await authService.changePassword(
        currentPassword: currentController.text,
        newPassword: newController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.accountPasswordUpdated)));
    } on AuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  /// Re-fires the purchase stream with past purchases (see
  /// `PurchaseStreamListener` in billing_provider.dart) — same
  /// verify-then-grant path as a fresh purchase, just triggered manually.
  /// Required by Play policy for subscriptions: lets someone recover
  /// Premium on a new device or after a reinstall without paying again.
  Future<void> _restorePurchases() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _restoringPurchases = true);
    try {
      await billingService.restorePurchases();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.premiumRestoreSuccess)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.premiumRestoreError)));
    } finally {
      if (mounted) setState(() => _restoringPurchases = false);
    }
  }

  Future<void> _deleteAccount() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.accountDeleteTitle),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Text(
          l10n.accountDeleteBody +
              (widget.isPremium ? l10n.accountDeletePremiumWarning : '') +
              l10n.accountDeleteCodeNotice,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.commonContinue,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await accountDeletionService.requestDeletionCode();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.accountDeletionCodeSent)));
      await _confirmDeletionWithCode();
    } on AccountDeletionException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.accountErrorSendCode)));
    }
  }

  Future<void> _confirmDeletionWithCode() async {
    final l10n = AppLocalizations.of(context);
    final codeController = TextEditingController();
    String? dialogError;

    final code = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.accountConfirmDeletionTitle),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.accountConfirmDeletionBody),
              const SizedBox(height: 12),
              TextField(
                controller: codeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: '000000',
                  counterText: '',
                ),
              ),
              if (dialogError != null) ...[
                const SizedBox(height: 4),
                Text(
                  dialogError!,
                  style: const TextStyle(color: AppColors.error),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.commonCancel),
            ),
            TextButton(
              onPressed: () {
                final value = codeController.text.trim();
                if (value.length != 6) {
                  setDialogState(
                    () => dialogError = l10n.accountErrorEnterSixDigits,
                  );
                  return;
                }
                Navigator.of(context).pop(value);
              },
              child: Text(
                l10n.accountDeletePermanentlyButton,
                style: const TextStyle(color: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );
    if (code == null || !mounted) return;

    try {
      await accountDeletionService.confirmDeletion(code);
      // No SnackBar here on purpose: confirmDeletion() signs out on
      // success, which rebuilds this whole subtree away immediately.
    } on AccountDeletionException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).accountErrorDeleteAccount),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).textTheme.bodySmall?.color;
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _uploadingAvatar ? null : _openAvatarSheet,
          child: Stack(
            children: [
              _ProfileAvatar(
                avatarUrl: _avatarUrl,
                displayName: _displayName,
                email: widget.user.email,
                size: 72,
              ),
              if (_uploadingAvatar)
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                )
              else
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            Theme.of(context).cardTheme.color ??
                            Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 13,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _loadingProfile
              ? l10n.accountSignedInPlaceholder
              : (_displayName?.isNotEmpty == true
                    ? _displayName!
                    : l10n.accountSignedInPlaceholder),
          style: AppTextStyles.title.copyWith(color: onSurface),
        ),
        const SizedBox(height: 4),
        Text(
          widget.user.email ?? '',
          style: AppTextStyles.body.copyWith(color: secondary),
        ),
        if (widget.isPremium && _premiumExpiresAt != null) ...[
          const SizedBox(height: 4),
          Text(
            l10n.premiumSubscriptionActiveUntil(
              DateFormat(
                'd MMM yyyy',
                Localizations.localeOf(context).toString(),
              ).format(_premiumExpiresAt!),
            ),
            style: AppTextStyles.caption.copyWith(color: secondary),
          ),
        ],
        const SizedBox(height: 24),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.badge_outlined),
          title: Text(l10n.accountChangeUsernameTitle),
          onTap: _changeUsername,
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.alternate_email_rounded),
          title: Text(l10n.accountChangeEmailTitle),
          onTap: _changeEmail,
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.lock_outline_rounded),
          title: Text(l10n.accountChangePasswordTitle),
          onTap: _changePassword,
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: _restoringPurchases
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.restore_rounded),
          title: Text(l10n.premiumRestorePurchases),
          onTap: _restoringPurchases ? null : _restorePurchases,
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 8),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(
            Icons.delete_forever_rounded,
            color: AppColors.error,
          ),
          title: Text(
            l10n.accountDeleteTitle,
            style: const TextStyle(color: AppColors.error),
          ),
          subtitle: Text(l10n.accountDeleteSubtitle),
          onTap: _deleteAccount,
        ),
      ],
    );
  }
}

/// Same live availability check as the signup form's username field —
/// found missing here (change-username, for an already-signed-in user)
/// after only being added to signup originally.
class _UsernameEditDialog extends StatefulWidget {
  const _UsernameEditDialog({required this.currentName});

  final String currentName;

  @override
  State<_UsernameEditDialog> createState() => _UsernameEditDialogState();
}

class _UsernameEditDialogState extends State<_UsernameEditDialog> {
  late final _controller = TextEditingController(text: widget.currentName);
  Timer? _debounce;
  String? _checkedValue;
  bool _checking = false;
  bool? _available;
  String? _reason;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged() {
    _debounce?.cancel();
    final value = _controller.text.trim();
    setState(() {
      _available = null;
      _reason = null;
      _checkedValue = null;
    });
    // Unchanged from their current name — nothing to check, it's already
    // theirs (and would otherwise show as "taken" against themself).
    if (value == widget.currentName.trim() || value.length < 3) return;
    _debounce = Timer(const Duration(milliseconds: 450), () => _check(value));
  }

  Future<void> _check(String value) async {
    setState(() => _checking = true);
    try {
      final rows = await Supabase.instance.client.rpc(
        'check_username_available',
        params: {'p_username': value},
      );
      if (!mounted || _controller.text.trim() != value) return;
      final row = (rows as List).first as Map<String, dynamic>;
      setState(() {
        _checking = false;
        _checkedValue = value;
        _available = row['available'] as bool;
        _reason = row['reason'] as String?;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _checking = false);
    }
  }

  String _reasonText(AppLocalizations l10n) {
    switch (_reason) {
      case 'blocked':
        return l10n.authUsernameBlocked;
      case 'too_short':
        return l10n.authUsernameTooShort;
      default:
        return l10n.authUsernameTaken;
    }
  }

  Widget? _suffixIcon() {
    final value = _controller.text.trim();
    if (value == widget.currentName.trim() || value.length < 3) return null;
    if (_checking) {
      return const Padding(
        padding: EdgeInsets.all(14),
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    if (_checkedValue != value) return null;
    if (_available == true) {
      return const Icon(Icons.check_circle_rounded, color: AppColors.success);
    }
    if (_available == false) {
      return const Icon(Icons.cancel_rounded, color: AppColors.error);
    }
    return null;
  }

  bool get _canSave {
    final value = _controller.text.trim();
    if (value.isEmpty) return false;
    if (value == widget.currentName.trim()) return true;
    return _available == true && _checkedValue == value;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final value = _controller.text.trim();
    return AlertDialog(
      title: Text(l10n.accountChangeUsernameTitle),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: l10n.authUsernameHint,
              suffixIcon: _suffixIcon(),
            ),
          ),
          if (_available == false && _checkedValue == value) ...[
            const SizedBox(height: 4),
            Text(
              _reasonText(l10n),
              style: AppTextStyles.caption.copyWith(color: AppColors.error),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        TextButton(
          onPressed: _canSave
              ? () => Navigator.of(context).pop(value)
              : null,
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }
}

/// Shows the user's photo when they have one; otherwise falls back to a
/// circle with their first initial (from their display name, or their email
/// when they haven't set one) — never a generic person icon once we know
/// who they are.
class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.avatarUrl,
    required this.displayName,
    required this.email,
    required this.size,
  });

  final String? avatarUrl;
  final String? displayName;
  final String? email;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl;
    if (url != null) {
      return ClipOval(
        child: Image.network(
          url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildInitial(),
        ),
      );
    }
    return _buildInitial();
  }

  Widget _buildInitial() {
    final source =
        (displayName?.isNotEmpty == true ? displayName : email) ?? '';
    final initial = source.isNotEmpty ? source[0].toUpperCase() : '?';
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.accentSoft,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: AppTextStyles.headline.copyWith(
            color: AppColors.primary,
            fontSize: size * 0.42,
          ),
        ),
      ),
    );
  }
}

enum _AvatarAction { camera, gallery, remove }

class _AvatarActionSheet extends StatelessWidget {
  const _AvatarActionSheet({required this.hasAvatar});

  final bool hasAvatar;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_camera_outlined, color: onSurface),
              title: Text(l10n.accountTakePhoto),
              onTap: () => Navigator.of(context).pop(_AvatarAction.camera),
            ),
            ListTile(
              leading: Icon(Icons.photo_library_outlined, color: onSurface),
              title: Text(l10n.accountChooseFromGallery),
              onTap: () => Navigator.of(context).pop(_AvatarAction.gallery),
            ),
            if (hasAvatar)
              ListTile(
                leading: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error,
                ),
                title: Text(
                  l10n.accountRemovePhoto,
                  style: const TextStyle(color: AppColors.error),
                ),
                onTap: () => Navigator.of(context).pop(_AvatarAction.remove),
              ),
          ],
        ),
      ),
    );
  }
}

class _FeedbackSheet extends ConsumerStatefulWidget {
  const _FeedbackSheet();

  @override
  ConsumerState<_FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends ConsumerState<_FeedbackSheet> {
  final _messageController = TextEditingController();
  final _emailController = TextEditingController();
  FeedbackType _type = FeedbackType.bug;
  bool _isSubmitting = false;
  bool _policyAcceptedChecked = false;
  Duration? _cooldownRemaining;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _checkCooldown();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _emailController.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _openPrivacyPolicy() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()));
  }

  Future<void> _checkCooldown() async {
    final remaining = await feedbackService.remainingCooldown();
    if (!mounted) return;
    setState(() => _cooldownRemaining = remaining);
    if (remaining != null) _startCooldownTicker();
  }

  void _startCooldownTicker() {
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = _cooldownRemaining;
      if (remaining == null || remaining.inSeconds <= 1) {
        timer.cancel();
        if (mounted) setState(() => _cooldownRemaining = null);
      } else {
        if (mounted)
          setState(
            () => _cooldownRemaining = remaining - const Duration(seconds: 1),
          );
      }
    });
  }

  bool _canSubmit(bool isGuest) {
    if (_isSubmitting || _cooldownRemaining != null) return false;
    if (_messageController.text.trim().isEmpty) return false;
    if (isGuest) {
      final email = _emailController.text.trim();
      if (email.isEmpty || !email.contains('@')) return false;
      if (!_policyAcceptedChecked) return false;
    }
    return true;
  }

  Future<void> _submit(bool isGuest) async {
    if (!_canSubmit(isGuest)) return;
    final message = _messageController.text.trim();
    setState(() => _isSubmitting = true);
    try {
      await feedbackService.submit(
        type: _type,
        message: message,
        contactEmail: isGuest ? _emailController.text.trim() : null,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).feedbackSubmittedThanks),
        ),
      );
    } on FeedbackCooldownException catch (error) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _cooldownRemaining = error.remaining;
      });
      _startCooldownTicker();
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
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
    final isGuest = ref.watch(authStateProvider).asData?.value == null;
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
            if (isGuest) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(hintText: l10n.authEmailHint),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.feedbackEmailNote,
                style: AppTextStyles.caption.copyWith(color: secondary),
              ),
              const SizedBox(height: 8),
              _ConsentCheckboxRow(
                value: _policyAcceptedChecked,
                onChanged: (value) =>
                    setState(() => _policyAcceptedChecked = value),
                child: Text.rich(
                  TextSpan(
                    style: AppTextStyles.caption.copyWith(color: secondary),
                    children: [
                      TextSpan(text: l10n.feedbackConsentPrefix),
                      TextSpan(
                        text: l10n.feedbackConsentLink,
                        style: const TextStyle(
                          color: AppColors.accent,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = _openPrivacyPolicy,
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 12),
              Text(
                l10n.feedbackSignedInContactNote,
                style: AppTextStyles.caption.copyWith(color: secondary),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canSubmit(isGuest) ? () => _submit(isGuest) : null,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.backgroundLight,
                        ),
                      )
                    : Text(
                        _cooldownRemaining != null
                            ? l10n.feedbackWaitSeconds(
                                _cooldownRemaining!.inSeconds,
                              )
                            : l10n.commonSend,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A checkbox whose label is also tappable (toggles the box), while still
/// letting a link embedded inside the label (via [TapGestureRecognizer])
/// claim its own taps to navigate instead of toggling the box.
class _ConsentCheckboxRow extends StatelessWidget {
  const _ConsentCheckboxRow({
    required this.value,
    required this.onChanged,
    required this.child,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: value,
            onChanged: (checked) => onChanged(checked ?? false),
            visualDensity: VisualDensity.compact,
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(!value),
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: child,
              ),
            ),
          ),
        ],
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
