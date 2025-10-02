// ========================================
// lib/features/dashboard/presentation/screens/dashboard_screen.dart
// Écran principal du dashboard avec statistiques et activités
// ========================================
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../shared/themes/app_theme.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/widgets/stat_card.dart';
import '../../../../shared/widgets/section_header.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/quick_actions.dart';
import '../widgets/recent_activities.dart';

/// Écran principal du dashboard
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final lowStockAsync = ref.watch(lowStockItemsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Format de devise
    final currencyFormat = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: 'FCFA',
      decimalDigits: 2,
    );

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardStatsProvider);
          ref.invalidate(recentActivitiesProvider);
          ref.invalidate(lowStockItemsProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec salutation
              _DashboardHeader(),

              const SizedBox(height: AppTheme.spacingXl),

              // Statistiques principales
              statsAsync.when(
                data: (stats) => _StatsSection(
                  stats: stats,
                  currencyFormat: currencyFormat,
                ),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppTheme.spacingXl),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, stack) => Center(
                  child: Text(
                    'Erreur de chargement des statistiques',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
              ),

              const SizedBox(height: AppTheme.spacingXl),

              // Actions rapides
              const SectionHeader(
                title: 'Actions rapides',
                subtitle: 'Accédez rapidement aux fonctionnalités principales',
                icon: Icons.flash_on_rounded,
              ),
              const QuickActions(),

              const SizedBox(height: AppTheme.spacingXl),

              // Contenu en 2 colonnes sur grand écran
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth >= 900) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Colonne gauche - Activités récentes
                        const Expanded(
                          flex: 2,
                          child: RecentActivities(),
                        ),

                        const SizedBox(width: AppTheme.spacingLg),

                        // Colonne droite - Alertes stock
                        Expanded(
                          flex: 1,
                          child: _LowStockCard(
                            lowStockAsync: lowStockAsync,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    );
                  } else {
                    // Sur petit écran, afficher en colonne
                    return Column(
                      children: [
                        const RecentActivities(),
                        const SizedBox(height: AppTheme.spacingLg),
                        _LowStockCard(
                          lowStockAsync: lowStockAsync,
                          isDark: isDark,
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// En-tête du dashboard avec salutation
class _DashboardHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final hour = now.hour;

    String greeting;
    if (hour < 12) {
      greeting = 'Bonjour';
    } else if (hour < 18) {
      greeting = 'Bon après-midi';
    } else {
      greeting = 'Bonsoir';
    }

    final dateFormat = DateFormat('EEEE d MMMM yyyy', 'fr_FR');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppTheme.spacingXs),
        Text(
          dateFormat.format(now),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Section des statistiques principales
class _StatsSection extends StatelessWidget {
  final DashboardStats stats;
  final NumberFormat currencyFormat;

  const _StatsSection({
    required this.stats,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive grid
        int crossAxisCount;
        if (constraints.maxWidth >= 1200) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth >= 900) {
          crossAxisCount = 2;
        } else {
          crossAxisCount = 1;
        }

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: AppTheme.spacingMd,
          mainAxisSpacing: AppTheme.spacingMd,
          childAspectRatio: 1.5,
          children: [
            // Ventes du jour
            StatCard(
              title: 'Ventes aujourd\'hui',
              value: currencyFormat.format(stats.todaySales),
              icon: Icons.trending_up_rounded,
              color: AppColors.sales,
              trend: '${stats.salesTrend}%',
              isPositiveTrend: stats.salesTrend > 0,
              subtitle: 'vs hier',
            ),

            // Commandes du jour
            StatCard(
              title: 'Commandes',
              value: '${stats.todayOrders}',
              icon: Icons.shopping_bag_rounded,
              color: AppColors.customers,
              trend: '${stats.ordersTrend}%',
              isPositiveTrend: stats.ordersTrend > 0,
              subtitle: 'Transactions',
            ),

            // Articles en stock bas
            StatCard(
              title: 'Stock bas',
              value: '${stats.lowStockItems}',
              icon: Icons.warning_rounded,
              color: AppColors.warning,
              subtitle: 'Articles à réapprovisionner',
            ),

            // Total clients
            StatCard(
              title: 'Clients',
              value: '${stats.totalCustomers}',
              icon: Icons.people_rounded,
              color: AppColors.inventory,
              subtitle: 'Clients enregistrés',
            ),
          ],
        );
      },
    );
  }
}

/// Card des articles en stock bas
class _LowStockCard extends StatelessWidget {
  final AsyncValue<List<Map<String, dynamic>>> lowStockAsync;
  final bool isDark;

  const _LowStockCard({
    required this.lowStockAsync,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
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
                Icon(
                  Icons.warning_rounded,
                  color: AppColors.warning,
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Text(
                  'Alertes stock',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingMd),

            // Liste des articles
            lowStockAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingXl),
                      child: Column(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 48,
                            color: AppColors.success,
                          ),
                          const SizedBox(height: AppTheme.spacingMd),
                          Text(
                            'Aucune alerte',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(AppTheme.spacingSm),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                        ),
                        child: Icon(
                          Icons.inventory_2_rounded,
                          color: AppColors.warning,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        item['name'],
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        item['category'],
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${item['current']} / ${item['minimum']}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.warning,
                            ),
                          ),
                          Text(
                            'unités',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    );
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