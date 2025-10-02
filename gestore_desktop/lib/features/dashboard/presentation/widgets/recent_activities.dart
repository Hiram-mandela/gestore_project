// ========================================
// lib/features/dashboard/presentation/widgets/recent_activities.dart
// Widget des activités récentes
// ========================================
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../shared/themes/app_theme.dart';
import '../../../../shared/constants/app_colors.dart';
import '../providers/dashboard_provider.dart';

/// Widget des activités récentes
class RecentActivities extends ConsumerWidget {
  const RecentActivities({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(recentActivitiesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: AppTheme.elevationSm,
      shadowColor: AppColors.cardShadow(isDark: isDark).color,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Row(
              children: [
                Text(
                  'Activités récentes',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // TODO: Voir toutes les activités
                  },
                  child: const Text('Voir tout'),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingMd),

            // Liste des activités
            activitiesAsync.when(
              data: (activities) {
                if (activities.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingXl),
                      child: Text(
                        'Aucune activité récente',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: activities.length > 5 ? 5 : activities.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final activity = activities[index];
                    return _ActivityTile(activity: activity);
                  },
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppTheme.spacingXl),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingXl),
                  child: Text(
                    'Erreur de chargement',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tuile d'activité
class _ActivityTile extends StatelessWidget {
  final RecentActivity activity;

  const _ActivityTile({required this.activity});

  IconData _getIcon(String type) {
    switch (type) {
      case 'sale':
        return Icons.shopping_cart_rounded;
      case 'stock':
        return Icons.inventory_2_rounded;
      case 'customer':
        return Icons.person_add_rounded;
      case 'alert':
        return Icons.warning_rounded;
      default:
        return Icons.circle_rounded;
    }
  }

  Color _getColor(String type) {
    switch (type) {
      case 'sale':
        return AppColors.sales;
      case 'stock':
        return AppColors.inventory;
      case 'customer':
        return AppColors.customers;
      case 'alert':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours}h';
    } else {
      return DateFormat('dd/MM à HH:mm').format(timestamp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _getColor(activity.type);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      leading: Container(
        padding: const EdgeInsets.all(AppTheme.spacingSm),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        child: Icon(
          _getIcon(activity.type),
          color: color,
          size: 20,
        ),
      ),
      title: Text(
        activity.title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        activity.subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondary,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (activity.amount != null)
            Text(
              activity.amount!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.success,
              ),
            ),
          Text(
            _formatTime(activity.timestamp),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}