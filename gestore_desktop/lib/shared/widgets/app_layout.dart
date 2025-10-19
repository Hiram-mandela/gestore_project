// ========================================
// lib/shared/widgets/app_layout.dart
// Layout principal avec sidebar navigation
// VERSION CORRIGÉE - Remplacement de MaterialStateProperty par WidgetStateProperty
// Date: 18 Octobre 2025
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
      backgroundColor: Colors.white, // Fond principal du contenu
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
        color: const Color(0xFFF9FAFB), // Couleur de fond moderne
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04), // Ombre plus douce
            blurRadius: 10,
            offset: const Offset(1, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header avec logo
          Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10), // Plus arrondi
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
          Divider(height: 1, color: Colors.grey[200], indent: 16, endIndent: 16),
          // Menu items
          Expanded(
            child: ListView(
              // Espacement augmenté
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              children: [
                // ==================== DASHBOARD ====================
                _MenuItem(
                  icon: Icons.dashboard_outlined, // Icône "outlined"
                  label: 'Tableau de bord',
                  route: '/dashboard',
                  currentRoute: currentRoute,
                ),
                const SizedBox(height: 12),
                const _SectionHeader(title: 'INVENTAIRE'),
                // Articles
                _MenuItem(
                  icon: Icons.inventory_2_outlined,
                  label: 'Articles',
                  route: '/inventory/articles',
                  currentRoute: currentRoute,
                ),
                // Catégories
                _MenuItem(
                  icon: Icons.category_outlined,
                  label: 'Catégories',
                  route: '/inventory/categories',
                  currentRoute: currentRoute,
                ),
                // Marques
                _MenuItem(
                  icon: Icons.branding_watermark_outlined,
                  label: 'Marques',
                  route: '/inventory/brands',
                  currentRoute: currentRoute,
                ),
                // Unités de mesure
                _MenuItem(
                  icon: Icons.straighten_outlined,
                  label: 'Unités',
                  route: '/inventory/units',
                  currentRoute: currentRoute,
                ),
                // Emplacements
                _MenuItem(
                  icon: Icons.location_on_outlined,
                  label: 'Emplacements',
                  route: '/inventory/locations',
                  currentRoute: currentRoute,
                ),
                // Stocks
                _MenuItem(
                  icon: Icons.warehouse_outlined,
                  label: 'Gestion des stocks',
                  route: '/inventory/stocks',
                  currentRoute: currentRoute,
                ),
                // Alertes
                _MenuItem(
                  icon: Icons.notifications_active_outlined,
                  label: 'Alertes de Stock',
                  route: '/inventory/alerts/dashboard', // Point d'entrée
                  currentRoute: currentRoute,
                ),
                const SizedBox(height: 12),
                const _SectionHeader(title: 'VENTES'),
                // Point de vente (POS)
                _MenuItem(
                  icon: Icons.point_of_sale_outlined,
                  label: 'Point de vente',
                  route: '/sales/pos',
                  currentRoute: currentRoute,
                ),
                // Clients
                _MenuItem(
                  icon: Icons.people_outline,
                  label: 'Clients',
                  route: '/sales/customers',
                  currentRoute: currentRoute,
                ),
                // Historique des ventes
                _MenuItem(
                  icon: Icons.history_outlined,
                  label: 'Historique',
                  route: '/sales/history',
                  currentRoute: currentRoute,
                ),
                // Moyens de paiement
                _MenuItem(
                  icon: Icons.payment_outlined,
                  label: 'Moyens de paiement',
                  route: '/sales/payment-methods',
                  currentRoute: currentRoute,
                ),
                // Remises et Promotions
                _MenuItem(
                  icon: Icons.local_offer_outlined,
                  label: 'Remises et Promotions',
                  route: '/sales/discounts',
                  currentRoute: currentRoute,
                ),
                const SizedBox(height: 12),
                const _SectionHeader(title: 'SYSTÈME'),
                // Paramètres
                _MenuItem(
                  icon: Icons.settings_outlined,
                  label: 'Paramètres',
                  route: '/settings',
                  currentRoute: currentRoute,
                ),
              ],
            ),
          ),
          // User info et déconnexion
          Divider(height: 1, color: Colors.grey[200], indent: 16, endIndent: 16),
          Container(
            padding: const EdgeInsets.all(20), // Augmentation du padding
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
                const SizedBox(height: 16),
                // Bouton de déconnexion (Style mis à jour)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _handleLogout(context, ref),
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('Déconnexion'),
                    // =========================================================
                    // CORRECTION: Remplacement de 'styleFrom' par 'style'
                    // et de 'MaterialStateProperty' par 'WidgetStateProperty'
                    // =========================================================
                    style: ButtonStyle(
                      // Propriétés statiques
                      foregroundColor: WidgetStateProperty.all(Colors.red.shade700),
                      side: WidgetStateProperty.all(
                          BorderSide(color: Colors.red.shade200)),
                      padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(vertical: 12)),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),

                      // Propriété dynamique (pour le survol)
                      overlayColor: WidgetStateProperty.resolveWith<Color?>(
                            (Set<WidgetState> states) {
                          if (states.contains(WidgetState.hovered)) {
                            // Utilisation de .withValues()
                            return Colors.red.withValues(alpha: 0.05);
                          }
                          return null; // Couleur par défaut pour les autres états
                        },
                      ),
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
      // Padding vertical augmenté
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.grey[500], // Couleur adoucie
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

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = _isRouteSelected();

    return Padding(
      // Padding horizontal augmenté
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        selected: isSelected,
        // Couleurs de sélection et de survol
        selectedTileColor: AppColors.primary.withValues(alpha: 0.1),
        // Le paramètre 'hoverColor' attend un Color? statique,
        // ce qui est correct ici.
        hoverColor: AppColors.primary.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7), // Arrondi ajusté
        ),
        leading: Icon(
          icon,
          size: 20, // Taille d'icône réduite
          color: isSelected ? AppColors.primary : Colors.grey[600],
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 14.5, // Taille de police ajustée
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500, // Poids ajusté
            color: isSelected ? AppColors.primary : Colors.grey[900],
          ),
        ),
        onTap: () {
          if (route != currentRoute) {
            context.go(route);
          }
        },
      ),
    );
  }

  /// Vérifie si la route est sélectionnée (Logique mise à jour)
  bool _isRouteSelected() {
    // Correspondance exacte
    if (currentRoute == route) return true;

    // Correspondance de route parent
    // (ex: /inventory/articles correspond à /inventory/articles/*)
    if (route != '/' && currentRoute.startsWith('$route/')) return true;

    // CAS SPÉCIAL: Gérer les routes d'alertes non-imbriquées
    // Si le menu pointe vers le dashboard des alertes,
    // on active aussi pour 'list' et ':alertId'.
    if (route == '/inventory/alerts/dashboard') {
      if (currentRoute.startsWith('/inventory/alerts/')) {
        return true;
      }
    }

    return false;
  }
}