// ========================================
// lib/features/dashboard/presentation/providers/dashboard_provider.dart
// Provider pour les données du dashboard
// ========================================
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Modèle de données pour les statistiques du dashboard
class DashboardStats {
  final double todaySales;
  final int todayOrders;
  final int lowStockItems;
  final int totalCustomers;
  final double salesTrend;
  final double ordersTrend;

  const DashboardStats({
    required this.todaySales,
    required this.todayOrders,
    required this.lowStockItems,
    required this.totalCustomers,
    required this.salesTrend,
    required this.ordersTrend,
  });

  factory DashboardStats.empty() {
    return const DashboardStats(
      todaySales: 0.0,
      todayOrders: 0,
      lowStockItems: 0,
      totalCustomers: 0,
      salesTrend: 0.0,
      ordersTrend: 0.0,
    );
  }
}

/// Activité récente
class RecentActivity {
  final String type;
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final String? amount;

  const RecentActivity({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    this.amount,
  });
}

/// Provider pour les statistiques du dashboard
final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  // TODO: Remplacer par un vrai appel API
  await Future.delayed(const Duration(seconds: 1));

  // Données mockées pour l'instant
  return const DashboardStats(
    todaySales: 12450.50,
    todayOrders: 42,
    lowStockItems: 8,
    totalCustomers: 156,
    salesTrend: 12.5,
    ordersTrend: 8.3,
  );
});

/// Provider pour les activités récentes
final recentActivitiesProvider = FutureProvider<List<RecentActivity>>((ref) async {
  // TODO: Remplacer par un vrai appel API
  await Future.delayed(const Duration(milliseconds: 800));

  final now = DateTime.now();

  // Données mockées
  return [
    RecentActivity(
      type: 'sale',
      title: 'Nouvelle vente',
      subtitle: 'Jean Dupont - 3 articles',
      timestamp: now.subtract(const Duration(minutes: 5)),
      amount: '125,50 FCFA',
    ),
    RecentActivity(
      type: 'stock',
      title: 'Stock réapprovisionné',
      subtitle: 'Article #1234 - Coca Cola 1.5L',
      timestamp: now.subtract(const Duration(minutes: 15)),
    ),
    RecentActivity(
      type: 'customer',
      title: 'Nouveau client',
      subtitle: 'Marie Martin',
      timestamp: now.subtract(const Duration(minutes: 30)),
    ),
    RecentActivity(
      type: 'alert',
      title: 'Alerte stock bas',
      subtitle: 'Pain de mie - 2 unités restantes',
      timestamp: now.subtract(const Duration(hours: 1)),
    ),
    RecentActivity(
      type: 'sale',
      title: 'Nouvelle vente',
      subtitle: 'Pierre Dubois - 5 articles',
      timestamp: now.subtract(const Duration(hours: 2)),
      amount: '89,00 FCFA',
    ),
  ];
});

/// Provider pour les articles en stock bas
final lowStockItemsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  // TODO: Remplacer par un vrai appel API
  await Future.delayed(const Duration(milliseconds: 600));

  // Données mockées
  return [
    {
      'name': 'Pain de mie',
      'current': 2,
      'minimum': 10,
      'category': 'Boulangerie',
    },
    {
      'name': 'Lait 1L',
      'current': 5,
      'minimum': 20,
      'category': 'Produits laitiers',
    },
    {
      'name': 'Huile 1L',
      'current': 3,
      'minimum': 15,
      'category': 'Épicerie',
    },
  ];
});