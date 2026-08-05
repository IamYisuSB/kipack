import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/auth/password_recovery_guard.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Pushed on top of everything as soon as [AuthChangeEvent.passwordRecovery]
/// fires (see AppShell) — the user just tapped the link in a "reset your
/// password" email, and Supabase has already exchanged it for a valid
/// session, so this only needs to collect and set the new password.
///
/// That session is only a *recovery* session — proof of clicking an email
/// link, not proof of knowing any password — so leaving this screen any
/// other way than actually setting one must not leave the user looking
/// signed in (see [PasswordRecoveryGuard]).
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;
  bool _isSubmitting = false;
  bool _completed = false;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final password = _passwordController.text;
    if (password.isEmpty || _isSubmitting) return;
    if (password != _confirmController.text) {
      setState(() => _error = 'Las contraseñas no coinciden');
      return;
    }
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      await authService.setNewPassword(password);
      await passwordRecoveryGuard.clear();
      _completed = true;
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Contraseña actualizada')));
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Algo ha fallado. Inténtalo de nuevo.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  /// Backing out (or the OS killing the app) without setting a new password
  /// must not leave the recovery session active — otherwise anyone with
  /// access to the victim's inbox could open the reset link, back out, and
  /// land on a fully "signed in" account without ever knowing a password.
  Future<void> _abandonRecovery() async {
    await Supabase.instance.client.auth.signOut();
    await passwordRecoveryGuard.clear();
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).textTheme.bodySmall?.color;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (!_completed) await _abandonRecovery();
        if (context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Nueva contraseña')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Elige una nueva contraseña',
                  style: AppTextStyles.title.copyWith(color: onSurface),
                ),
                const SizedBox(height: 8),
                Text(
                  'Se aplicará a tu cuenta inmediatamente.',
                  style: AppTextStyles.body.copyWith(color: secondary),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscure,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Nueva contraseña',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _confirmController,
                  obscureText: _obscure,
                  decoration: const InputDecoration(
                    hintText: 'Repite la nueva contraseña',
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: AppTextStyles.body.copyWith(color: AppColors.error),
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
                        : const Text('Guardar contraseña'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
