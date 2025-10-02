// ========================================
// lib/shared/widgets/section_header.dart
// En-tête de section avec titre et action optionnelle
// ========================================
import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import '../constants/app_colors.dart';

/// En-tête de section avec titre et bouton d'action optionnel
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.actionText,
    this.onActionPressed,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppTheme.spacingMd,
      ),
      child: Row(
        children: [
          // Icône (optionnel)
          if (icon != null) ...[
            Icon(
              icon,
              size: 24,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimary,
            ),
            const SizedBox(width: AppTheme.spacingMd),
          ],

          // Titre et sous-titre
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppTheme.spacingXs),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Action ou trailing widget
          if (trailing != null)
            trailing!
          else if (actionText != null && onActionPressed != null)
            TextButton.icon(
              onPressed: onActionPressed,
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: Text(actionText!),
            ),
        ],
      ),
    );
  }
}