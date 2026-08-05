import 'dart:ui';

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class NavItem {
  const NavItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

/// A floating, pill-shaped bottom bar with a frosted "glass" surface —
/// blurred background, translucent tint, thin light-catching border —
/// approximating iOS's Liquid Glass tab bars (Apple Music, Telegram, etc.)
/// instead of a Material bar docked flush to the screen edge.
class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final List<NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glassTint = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    // Ignores the keyboard's view insets — without this, SafeArea reacts to
    // the keyboard opening (e.g. typing in the login form) by pushing the
    // whole bar up to sit above it, when it should stay pinned to the
    // actual bottom of the screen regardless of the keyboard.
    return MediaQuery.removeViewInsets(
      context: context,
      removeBottom: true,
      child: SafeArea(
        minimum: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        // Centers the pill and lets it hug its own content width instead
        // of stretching edge to edge — a compact floating capsule rather
        // than a full-width bar.
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(
                height: 68,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: glassTint.withValues(alpha: isDark ? 0.55 : 0.7),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.6),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.35 : 0.12,
                      ),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < items.length; i++) ...[
                      if (i > 0) const SizedBox(width: 10),
                      _NavItemButton(
                        item: items[i],
                        selected: i == selectedIndex,
                        onTap: () => onDestinationSelected(i),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemButton extends StatelessWidget {
  const _NavItemButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactiveColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          item.icon,
          size: 24,
          color: selected ? AppColors.primary : inactiveColor,
        ),
      ),
    );
  }
}
