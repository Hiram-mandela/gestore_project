// ========================================
// lib/shared/widgets/app_layout.dart
// Layout principal avec sidebar responsive et AppBar
// ========================================
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/authentication/presentation/providers/auth_provider.dart';
import '../themes/app_theme.dart';
import '../constants/app_colors.dart';

/// Menu item du sidebar
class MenuItem {
  final String title;
  final IconData icon;
  final String route;
  final List<MenuItem>? subItems;

  const MenuItem({
    required this.title,
    required this.icon,
    required this.route,
    this.subItems,
  });
}

/// Layout principal de l'application
class AppLayout extends ConsumerStatefulWidget {
  final Widget child;
  final String currentRoute;

  const AppLayout({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  ConsumerState<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends ConsumerState<AppLayout> {
  // Items du menu
  static const List<MenuItem> menuItems = [
    MenuItem(
      title: 'Tableau de bord',
      icon: Icons.dashboard_rounded,
      route: '/home',
    ),
    MenuItem(
      title: 'Inventaire',
      icon: Icons.inventory_2_rounded,
      route: '/inventory',
    ),
    MenuItem(
      title: 'Point de vente',
      icon: Icons.point_of_sale_rounded,
      route: '/pos',
    ),
    MenuItem(
      title: 'Clients',
      icon: Icons.people_rounded,
      route: '/customers',
    ),
    MenuItem(
      title: 'Rapports',
      icon: Icons.analytics_rounded,
      route: '/reports',
    ),
    MenuItem(
      title: 'Paramètres',
      icon: Icons.settings_rounded,
      route: '/settings',
    ),
  ];

  bool _isDrawerOpen = false;

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive: afficher NavigationRail sur grand écran, Drawer sur petit
    final showPermanentDrawer = screenWidth >= 1200;
    final showRail = screenWidth >= 768 && screenWidth < 1200;

    return Scaffold(
      appBar: AppBar(
        leading: showPermanentDrawer || showRail
            ? null
            : IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            setState(() => _isDrawerOpen = !_isDrawerOpen);
            if (_isDrawerOpen) {
              Scaffold.of(context).openDrawer();
            }
          },
        ),
        title: Row(
          children: [
            // Logo compact
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: const Icon(
                Icons.store,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            const Text(
              'GESTORE',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        actions: [
          // Notifications
          IconButton(
            icon: Badge(
              label: const Text('3'),
              child: Icon(
                Icons.notifications_outlined,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
            tooltip: 'Notifications',
            onPressed: () {
              // TODO: Ouvrir panneau de notifications
            },
          ),

          const SizedBox(width: AppTheme.spacingSm),

          // Profil utilisateur
          if (currentUser != null)
            Padding(
              padding: const EdgeInsets.only(right: AppTheme.spacingMd),
              child: PopupMenuButton<void>(
                offset: const Offset(0, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: Text(
                        currentUser.fullName.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingSm),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          currentUser.fullName,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          currentUser.email,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(width: AppTheme.spacingSm),
                    const Icon(Icons.keyboard_arrow_down, size: 20),
                  ],
                ),
                itemBuilder: (context) => <PopupMenuEntry<void>>[
                  PopupMenuItem<void>(
                    child: const Row(
                      children: [
                        Icon(Icons.person_outline, size: 20),
                        SizedBox(width: AppTheme.spacingMd),
                        Text('Mon profil'),
                      ],
                    ),
                    onTap: () {
                      // TODO: Naviguer vers profil
                    },
                  ),
                  PopupMenuItem<void>(
                    child: const Row(
                      children: [
                        Icon(Icons.settings_outlined, size: 20),
                        SizedBox(width: AppTheme.spacingMd),
                        Text('Paramètres'),
                      ],
                    ),
                    onTap: () {
                      context.go('/settings');
                    },
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem<void>(
                    child: const Row(
                      children: [
                        Icon(Icons.logout, size: 20, color: AppColors.error),
                        SizedBox(width: AppTheme.spacingMd),
                        Text('Déconnexion', style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                    onTap: () async {
                      await ref.read(authProvider.notifier).logout();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    },
                  ),
                ],
              ),
            ),
        ],
      ),

      // Drawer pour mobile
      drawer: showPermanentDrawer || showRail
          ? null
          : _buildDrawer(context, isDark),

      // Body avec sidebar
      body: Row(
        children: [
          // Sidebar permanent (desktop)
          if (showPermanentDrawer)
            _buildDrawer(context, isDark, isPermanent: true),

          // NavigationRail (tablet)
          if (showRail)
            _buildNavigationRail(context, isDark),

          // Contenu principal
          Expanded(
            child: Container(
              color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }

  /// Construire le drawer/sidebar
  Widget _buildDrawer(BuildContext context, bool isDark, {bool isPermanent = false}) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: isPermanent
            ? Border(
          right: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.border,
            width: 1,
          ),
        )
            : null,
      ),
      child: Column(
        children: [
          // Espaceur si permanent (AppBar prend déjà la place)
          if (isPermanent) const SizedBox(height: AppTheme.spacingMd),

          // Liste des menu items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMd,
                vertical: AppTheme.spacingSm,
              ),
              children: menuItems.map((item) {
                final isSelected = widget.currentRoute == item.route;

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        context.go(item.route);
                        if (!isPermanent) {
                          Navigator.pop(context);
                        }
                      },
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingMd,
                          vertical: AppTheme.spacingMd,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              size: 24,
                              color: isSelected
                                  ? AppColors.primary
                                  : (isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary),
                            ),
                            const SizedBox(width: AppTheme.spacingMd),
                            Expanded(
                              child: Text(
                                item.title,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  color: isSelected
                                      ? AppColors.primary
                                      : (isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimary),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                // Version de l'app
                Text(
                  'Version 1.0.0',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construire le NavigationRail (pour tablette)
  Widget _buildNavigationRail(BuildContext context, bool isDark) {
    return NavigationRail(
      selectedIndex: menuItems.indexWhere((item) => item.route == widget.currentRoute),
      onDestinationSelected: (index) {
        context.go(menuItems[index].route);
      },
      labelType: NavigationRailLabelType.all,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      destinations: menuItems.map((item) {
        return NavigationRailDestination(
          icon: Icon(item.icon),
          label: Text(item.title),
        );
      }).toList(),
    );
  }
}