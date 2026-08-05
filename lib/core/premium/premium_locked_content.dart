import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'premium_purchase_buttons.dart';

/// Reusable "this is a Premium feature" block — an icon, a headline, a
/// short description, and the same real monthly/annual purchase buttons
/// used everywhere else. Callers decide the surrounding layout (a full
/// Scaffold for a whole locked tab, or embedded inline alongside other
/// content).
class PremiumLockedContent extends StatelessWidget {
  const PremiumLockedContent({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.workspace_premium_rounded,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).textTheme.bodySmall?.color;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              color: AppColors.accentSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 44, color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: AppTextStyles.title.copyWith(color: onSurface),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: AppTextStyles.body.copyWith(color: secondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          const PremiumPurchaseButtons(),
        ],
      ),
    );
  }
}
