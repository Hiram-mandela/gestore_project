// ========================================
// lib/features/dashboard/presentation/widgets/quick_actions.dart
// Widget des actions rapides
// ========================================
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/themes/app_theme.dart';
import '../../../../shared/constants/app_colors.dart';

/// Action rapide
class QuickAction {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;

  const QuickAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });
}

/// Widget des actions rapides
class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  static const List<QuickAction> actions = [
    QuickAction(
      title: 'Nouvelle vente',
      subtitle: 'Ouvrir la caisse',
      icon: Icons.shopping_cart_rounded,
      color: AppColors.sales,
      route: '/pos',
    ),
    QuickAction(
      title: 'Ajouter un article',
      subtitle: 'Créer un produit',
      icon: Icons.add_box_rounded,
      color: AppColors.inventory,
      route: '/inventory/new',
    ),
    QuickAction(
      title: 'Nouveau client',
      subtitle: 'Enregistrer un client',
      icon: Icons.person_add_rounded,
      color: AppColors.customers,
      route: '/customers/new',
    ),
    QuickAction(
      title: 'Voir les rapports',
      subtitle: 'Analytics et stats',
      icon: Icons.assessment_rounded,
      color: AppColors.reports,
      route: '/reports',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppTheme.spacingMd,
        mainAxisSpacing: AppTheme.spacingMd,
        childAspectRatio: 1.8,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];

        return Card(
          elevation: AppTheme.elevationSm,
          shadowColor: AppColors.cardShadow(isDark: isDark).color,
          child: InkWell(
            onTap: () {
              context.go(action.route);
            },
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: Row(
                children: [
                  // Icône
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingMd),
                    decoration: BoxDecoration(
                      color: action.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: Icon(
                      action.icon,
                      color: action.color,
                      size: 32,
                    ),
                  ),

                  const SizedBox(width: AppTheme.spacingMd),

                  // Texte
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          action.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingXs),
                        Text(
                          action.subtitle,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}