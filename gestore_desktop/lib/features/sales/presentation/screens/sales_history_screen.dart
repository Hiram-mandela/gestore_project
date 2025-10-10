// ========================================
// lib/features/sales/presentation/screens/sales_history_screen.dart
// Écran Historique des Ventes - Module Sales
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../shared/constants/app_colors.dart';
import '../providers/sales_history_provider.dart';
import '../providers/sales_history_state.dart';
import '../../domain/entities/sale_entity.dart';

/// Écran d'historique des ventes
class SalesHistoryScreen extends ConsumerStatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  ConsumerState<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends ConsumerState<SalesHistoryScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  final _currencyFormat = NumberFormat('#,##0', 'fr_FR');

  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();

    // Charger l'historique au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(salesHistoryProvider.notifier).loadSales();
    });

    // Pagination infinie
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      final state = ref.read(salesHistoryProvider);
      if (state is SalesHistoryLoaded && state.hasMore && !state.isLoadingMore) {
        ref.read(salesHistoryProvider.notifier).loadMore();
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(salesHistoryProvider);

    // ✅ CORRECTION: Retirer AppLayout, juste le contenu
    return Column(
      children: [
        // Header avec recherche et filtres
        _buildHeader(state),

        // Statistiques du jour
        if (state is SalesHistoryLoaded) _buildDailyStats(state),

        // Liste des ventes
        Expanded(
          child: _buildBody(state),
        ),
      ],
    );
  }

  /// Header avec recherche et filtres
  Widget _buildHeader(SalesHistoryState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Barre de recherche
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher par N° vente, client...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey[600]),
                    onPressed: () {
                      _searchController.clear();
                      ref.read(salesHistoryProvider.notifier).search('');
                      setState(() {});
                    },
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onChanged: (value) {
                  ref.read(salesHistoryProvider.notifier).search(value);
                  setState(() {});
                },
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Sélecteur de dates
          OutlinedButton.icon(
            onPressed: _selectDateRange,
            icon: const Icon(Icons.calendar_today, size: 18),
            label: Text(
              _selectedDateRange != null
                  ? '${DateFormat('dd/MM').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM').format(_selectedDateRange!.end)}'
                  : 'Période',
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Filtres
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list, color: Colors.grey[700]),
            tooltip: 'Filtrer',
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('Toutes les ventes'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'completed',
                child: Text('Terminées'),
              ),
              const PopupMenuItem(
                value: 'pending',
                child: Text('En attente'),
              ),
              const PopupMenuItem(
                value: 'cancelled',
                child: Text('Annulées'),
              ),
              const PopupMenuItem(
                value: 'refunded',
                child: Text('Remboursées'),
              ),
            ],
            onSelected: (value) {
              ref.read(salesHistoryProvider.notifier).filterByStatus(value);
            },
          ),

          const SizedBox(width: 12),

          // Export
          ElevatedButton.icon(
            onPressed: state is SalesHistoryLoaded && state.sales.isNotEmpty
                ? _exportSales
                : null,
            icon: const Icon(Icons.download, size: 18),
            label: const Text('Exporter'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.info,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  /// Statistiques du jour
  Widget _buildDailyStats(SalesHistoryLoaded state) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildDailyStatCard(
            icon: Icons.receipt_long,
            label: 'Ventes du jour',
            value: state.todaySalesCount.toString(),
          ),
          const SizedBox(width: 40),
          _buildDailyStatCard(
            icon: Icons.attach_money,
            label: 'Chiffre d\'affaires',
            value: '${_currencyFormat.format(state.todayRevenue)} FCFA',
          ),
          const SizedBox(width: 40),
          _buildDailyStatCard(
            icon: Icons.trending_up,
            label: 'Panier moyen',
            value: '${_currencyFormat.format(state.averageBasket)} FCFA',
          ),
        ],
      ),
    );
  }

  /// Carte de statistique journalière
  Widget _buildDailyStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Corps selon l'état
  Widget _buildBody(SalesHistoryState state) {
    if (state is SalesHistoryLoading) {
      return _buildLoadingState();
    } else if (state is SalesHistoryError) {
      return _buildErrorState(state);
    } else if (state is SalesHistoryLoaded) {
      if (state.sales.isEmpty) {
        return _buildEmptyState();
      }
      return _buildSalesList(state);
    }
    return const SizedBox.shrink();
  }

  /// État de chargement
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Chargement de l\'historique...',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  /// État d'erreur
  Widget _buildErrorState(SalesHistoryError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            'Erreur',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            state.message,
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(salesHistoryProvider.notifier).loadSales();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  /// État vide
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Aucune vente',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isNotEmpty
                ? 'Aucun résultat pour "${_searchController.text}"'
                : 'Aucune vente enregistrée pour le moment',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.go('/pos');
            },
            icon: const Icon(Icons.point_of_sale),
            label: const Text('Ouvrir le POS'),
          ),
        ],
      ),
    );
  }

  /// Liste des ventes
  Widget _buildSalesList(SalesHistoryLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(salesHistoryProvider.notifier).refresh();
      },
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(20),
        itemCount: state.sales.length + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index >= state.sales.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final sale = state.sales[index];
          return _buildSaleCard(sale);
        },
      ),
    );
  }

  /// Carte d'une vente
  Widget _buildSaleCard(SaleEntity sale) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: () {
          context.push('/sales/history/${sale.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: N° vente et statut
              Row(
                children: [
                  // N° vente
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          sale.saleNumber,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Type de vente
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getSaleTypeColor(sale.saleType)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      sale.saleTypeDisplay,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _getSaleTypeColor(sale.saleType),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Statut
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(sale.status)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      sale.statusDisplay,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(sale.status),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Infos client et caissier
              Row(
                children: [
                  // Client
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.person, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            sale.customer?.fullName ?? 'Client anonyme',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Caissier
                  if (sale.cashier != null)
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.badge, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              sale.cashier!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Date et heure
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    _dateFormat.format(sale.saleDate),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),

              const Divider(height: 24),

              // Résumé: Articles, Total, Paiement
              Row(
                children: [
                  // Nombre d'articles
                  _buildSaleInfoPill(
                    icon: Icons.shopping_bag,
                    label: '${sale.itemsCount} article${sale.itemsCount > 1 ? 's' : ''}',
                    color: AppColors.info,
                  ),

                  const Spacer(),

                  // Montant total
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${_currencyFormat.format(sale.totalAmount)} FCFA',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 16),

                  // Statut paiement
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: sale.isPaid
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.warning.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      sale.isPaid ? Icons.check_circle : Icons.pending,
                      color: sale.isPaid ? AppColors.success : AppColors.warning,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Pill d'info vente
  Widget _buildSaleInfoPill({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Couleur selon le type de vente
  Color _getSaleTypeColor(String type) {
    switch (type) {
      case 'return':
        return AppColors.error;
      case 'exchange':
        return AppColors.warning;
      case 'quote':
        return AppColors.info;
      default:
        return AppColors.primary;
    }
  }

  /// Couleur selon le statut
  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'cancelled':
        return AppColors.error;
      case 'refunded':
      case 'partially_refunded':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  /// Sélectionner une période
  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
      ref.read(salesHistoryProvider.notifier).filterByDateRange(
        picked.start,
        picked.end,
      );
    }
  }

  /// Exporter les ventes
  void _exportSales() {
    // TODO: Implémenter l'export CSV/Excel
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Export en cours de développement'),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}