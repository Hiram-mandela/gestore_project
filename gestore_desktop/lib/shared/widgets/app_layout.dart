// ========================================
// lib/shared/widgets/app_layout.dart
// Layout principal avec sidebar navigation
// VERSION COMPLÈTE - Inventory (Articles, Categories, Brands, Units, Locations, Stocks) + Sales + Settings
// Date: 17 Octobre 2025 - Mise à jour Phase 3 & 4
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/authentication/presentation/providers/auth_provider.dart';
import '../../features/authentication/presentation/providers/auth_state.dart';
import '../constants/app_colors.dart';

/// Layout principal de l'application avec sidebar
class AppLayout extends ConsumerWidget {
  final Widget child;
  final String currentRoute;

  const AppLayout({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          _Sidebar(currentRoute: currentRoute),

          // Contenu principal
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Sidebar de navigation
class _Sidebar extends ConsumerWidget {
  final String currentRoute;

  const _Sidebar({required this.currentRoute});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState is AuthAuthenticated ? authState.user : null;

    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header avec logo
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.store,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'GESTORE',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Menu items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                // ==================== DASHBOARD ====================
                _MenuItem(
                  icon: Icons.dashboard,
                  label: 'Tableau de bord',
                  route: '/dashboard',
                  currentRoute: currentRoute,
                ),

                const SizedBox(height: 8),
                const _SectionHeader(title: 'INVENTAIRE'),

                // Articles
                _MenuItem(
                  icon: Icons.inventory_2,
                  label: 'Articles',
                  route: '/inventory/articles',
                  currentRoute: currentRoute,
                ),

                // Catégories
                _MenuItem(
                  icon: Icons.category,
                  label: 'Catégories',
                  route: '/inventory/categories',
                  currentRoute: currentRoute,
                ),

                // Marques
                _MenuItem(
                  icon: Icons.branding_watermark,
                  label: 'Marques',
                  route: '/inventory/brands',
                  currentRoute: currentRoute,
                ),

                // Unités de mesure
                _MenuItem(
                  icon: Icons.straighten,
                  label: 'Unités',
                  route: '/inventory/units',
                  currentRoute: currentRoute,
                ),

                // ⭐ NOUVEAU - Emplacements (Phase 3)
                _MenuItem(
                  icon: Icons.location_on,
                  label: 'Emplacements',
                  route: '/inventory/locations',
                  currentRoute: currentRoute,
                ),

                // ⭐ NOUVEAU - Stocks (Phase 4)
                _MenuItem(
                  icon: Icons.warehouse,
                  label: 'Gestion des stocks',
                  route: '/inventory/stocks',
                  currentRoute: currentRoute,
                ),

                const SizedBox(height: 8),
                const _SectionHeader(title: 'VENTES'),

                // Point de vente (POS)
                _MenuItem(
                  icon: Icons.point_of_sale,
                  label: 'Point de vente',
                  route: '/sales/pos',
                  currentRoute: currentRoute,
                ),

                // Clients
                _MenuItem(
                  icon: Icons.people,
                  label: 'Clients',
                  route: '/sales/customers',
                  currentRoute: currentRoute,
                ),

                // Historique des ventes
                _MenuItem(
                  icon: Icons.history,
                  label: 'Historique',
                  route: '/sales/history',
                  currentRoute: currentRoute,
                ),

                // Moyens de paiement
                _MenuItem(
                  icon: Icons.payment,
                  label: 'Moyens de paiement',
                  route: '/sales/payment-methods',
                  currentRoute: currentRoute,
                ),

                // Remises et Promotions
                _MenuItem(
                  icon: Icons.local_offer,
                  label: 'Remises et Promotions',
                  route: '/sales/discounts',
                  currentRoute: currentRoute,
                ),

                const SizedBox(height: 8),
                const _SectionHeader(title: 'SYSTÈME'),

                // Paramètres
                _MenuItem(
                  icon: Icons.settings,
                  label: 'Paramètres',
                  route: '/settings',
                  currentRoute: currentRoute,
                ),
              ],
            ),
          ),

          // User info et déconnexion
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // User info
                if (user != null)
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: Text(
                          user.username.isNotEmpty
                              ? user.username[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.username,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              user.email,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 12),

                // Bouton de déconnexion
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _handleLogout(context, ref),
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('Déconnexion'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Gère la déconnexion
  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await ref.read(authProvider.notifier).logout();
      if (context.mounted) {
        context.go('/login');
      }
    }
  }
}

/// En-tête de section dans le menu
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Item de menu
class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final String currentRoute;
  final bool enabled;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.currentRoute,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = _isRouteSelected();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListTile(
        enabled: enabled,
        selected: isSelected,
        selectedTileColor: AppColors.primary.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        leading: Icon(
          icon,
          size: 22,
          color: enabled
              ? (isSelected ? AppColors.primary : Colors.grey[700])
              : Colors.grey[400],
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: enabled
                ? (isSelected ? AppColors.primary : Colors.grey[800])
                : Colors.grey[400],
          ),
        ),
        onTap: enabled
            ? () {
          if (route != currentRoute) {
            context.go(route);
          }
        }
            : null,
      ),
    );
  }

  /// Vérifie si la route est sélectionnée
  bool _isRouteSelected() {
    // Exact match
    if (currentRoute == route) return true;

    // Parent route match (ex: /inventory/stocks correspond à /inventory/stocks/*)
    if (currentRoute.startsWith('$route/')) return true;

    return false;
  }
}