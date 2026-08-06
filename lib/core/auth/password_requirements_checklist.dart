import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'password_policy.dart';

/// Live-updating list of password requirements — shown under the password
/// field wherever a new password is being chosen (signup, reset password),
/// so the user sees exactly what's still missing instead of only finding
/// out after submitting.
class PasswordRequirementsChecklist extends StatelessWidget {
  const PasswordRequirementsChecklist({super.key, required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final secondary = Theme.of(context).textTheme.bodySmall?.color;
    final items = <(bool, String)>[
      (PasswordPolicy.hasMinLength(password), l10n.authPasswordReqLength),
      (PasswordPolicy.hasLower(password), l10n.authPasswordReqLower),
      (PasswordPolicy.hasUpper(password), l10n.authPasswordReqUpper),
      (PasswordPolicy.hasDigit(password), l10n.authPasswordReqDigit),
      (PasswordPolicy.hasSymbol(password), l10n.authPasswordReqSymbol),
    ];
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Wrap(
        spacing: 12,
        runSpacing: 6,
        children: [
          for (final (met, label) in items)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  met ? Icons.check_circle_rounded : Icons.circle_outlined,
                  size: 15,
                  color: met ? AppColors.success : secondary,
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: met ? AppColors.success : secondary,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
