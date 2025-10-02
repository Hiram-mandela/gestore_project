// ========================================
// lib/shared/widgets/stat_card.dart
// Widget de carte de statistique moderne
// ========================================
import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import '../constants/app_colors.dart';

/// Carte de statistique avec icône, titre, valeur et tendance
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final String? subtitle;
  final String? trend;
  final bool? isPositiveTrend;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.subtitle,
    this.trend,
    this.isPositiveTrend,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = color ?? AppColors.primary;

    return Card(
      elevation: AppTheme.elevationSm,
      shadowColor: AppColors.cardShadow(isDark: isDark).color,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec icône
              Row(
                children: [
                  // Icône avec background coloré
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingMd),
                    decoration: BoxDecoration(
                      color: cardColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: Icon(
                      icon,
                      color: cardColor,
                      size: 28,
                    ),
                  ),
                  const Spacer(),

                  // Tendance (optionnel)
                  if (trend != null && isPositiveTrend != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingSm,
                        vertical: AppTheme.spacingXs,
                      ),
                      decoration: BoxDecoration(
                        color: isPositiveTrend!
                            ? AppColors.success.withValues(alpha: 0.1)
                            : AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPositiveTrend!
                                ? Icons.trending_up
                                : Icons.trending_down,
                            size: 14,
                            color: isPositiveTrend!
                                ? AppColors.success
                                : AppColors.error,
                          ),
                          const SizedBox(width: AppTheme.spacingXs),
                          Text(
                            trend!,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: isPositiveTrend!
                                  ? AppColors.success
                                  : AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: AppTheme.spacingMd),

              // Titre
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: AppTheme.spacingXs),

              // Valeur principale
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              // Sous-titre (optionnel)
              if (subtitle != null) ...[
                const SizedBox(height: AppTheme.spacingXs),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}