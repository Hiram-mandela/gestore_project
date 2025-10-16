// ========================================
// lib/features/sales/presentation/screens/sales_history_screen.dart
// Écran Historique des Ventes - Module Sales
// VERSION AMÉLIORÉE - DESIGN REFACTORING
//
// Changements stylistiques majeurs :
// - Intégration de la palette GESTORE pour une interface unifiée (fonds, textes, accents).
// - Modernisation de l'en-tête, des filtres et de la barre de recherche.
// - Remplacement de la bannière de statistiques par des cartes individuelles plus claires.
// - Amélioration du design des cartes de vente pour une meilleure hiérarchie visuelle.
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../domain/entities/sale_entity.dart';
import '../providers/sales_history_provider.dart';
import '../providers/sales_history_state.dart';

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

    // Le Scaffold est maintenant géré par le layout parent, on retourne le contenu directement.
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
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
      ),
    );
  }

  /// Header avec recherche et filtres
  Widget _buildHeader(SalesHistoryState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        boxShadow: [AppColors.subtleShadow()],
      ),
      child: Row(
        children: [
          // Barre de recherche
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Rechercher par N° vente, client...',
                hintStyle: const TextStyle(color: AppColors.textTertiary),
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(salesHistoryProvider.notifier).search('');
                  },
                )
                    : null,
                filled: true,
                fillColor: AppColors.backgroundLight,
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              onChanged: (value) {
                ref.read(salesHistoryProvider.notifier).search(value);
              },
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
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.border),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Filtres
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: AppColors.textSecondary),
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
          FilledButton.icon(
            onPressed: state is SalesHistoryLoaded && state.sales.isNotEmpty
                ? _exportSales
                : null,
            icon: const Icon(Icons.download, size: 18),
            label: const Text('Exporter'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Statistiques du jour
  Widget _buildDailyStats(SalesHistoryLoaded state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      color: AppColors.surfaceLight,
      child: Row(
        children: [
          _buildDailyStatCard(
            icon: Icons.receipt_long,
            label: 'Ventes du jour',
            value: state.todaySalesCount.toString(),
            color: AppColors.primary,
          ),
          const SizedBox(width: 20),
          _buildDailyStatCard(
            icon: Icons.attach_money,
            label: 'Chiffre d\'affaires',
            value: '${_currencyFormat.format(state.todayRevenue)} FCFA',
            color: AppColors.success,
          ),
          const SizedBox(width: 20),
          _buildDailyStatCard(
            icon: Icons.trending_up,
            label: 'Panier moyen',
            value: '${_currencyFormat.format(state.averageBasket)} FCFA',
            color: AppColors.info,
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
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
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
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text(
            'Chargement de l\'historique...',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
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
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            'Une erreur est survenue',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            state.message,
            style: const TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
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
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'Aucune vente trouvée',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isNotEmpty
                ? 'Aucun résultat pour "${_searchController.text}"'
                : 'Aucune vente enregistrée pour le moment',
            style: const TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (_searchController.text.isEmpty)
            FilledButton.icon(
              onPressed: () {
                context.go('/pos');
              },
              icon: const Icon(Icons.point_of_sale),
              label: const Text('Ouvrir le POS'),
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
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
        padding: const EdgeInsets.all(24),
        itemCount: state.sales.length + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          if (index >= state.sales.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(color: AppColors.primary),
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
      color: AppColors.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
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
                  Icon(
                    Icons.receipt_long,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    sale.saleNumber,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  // Type de vente
                  _buildStatusChip(
                    label: sale.saleTypeDisplay,
                    color: _getSaleTypeColor(sale.saleType),
                  ),
                  const SizedBox(width: 8),
                  // Statut
                  _buildStatusChip(
                    label: sale.statusDisplay,
                    color: _getStatusColor(sale.status),
                  ),
                ],
              ),
              const Divider(height: 24, color: AppColors.border),
              // Infos client et caissier
              Row(
                children: [
                  // Client
                  _buildInfoRow(
                    icon: Icons.person,
                    text: sale.customer?.fullName ?? 'Client anonyme',
                  ),
                  const SizedBox(width: 24),
                  // Caissier
                  if (sale.cashier != null)
                    _buildInfoRow(icon: Icons.badge, text: sale.cashier!),
                  const Spacer(),
                  // Date et heure
                  _buildInfoRow(
                    icon: Icons.access_time,
                    text: _dateFormat.format(sale.saleDate),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Résumé: Articles, Total, Paiement
              Row(
                children: [
                  _buildSaleInfoPill(
                    icon: Icons.shopping_bag,
                    label:
                    '${sale.itemsCount} article${sale.itemsCount > 1 ? 's' : ''}',
                    color: AppColors.info,
                  ),
                  const Spacer(),
                  // Montant total
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${_currencyFormat.format(sale.totalAmount)} FCFA',
                        style: const TextStyle(
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

  /// Widget pour afficher une information avec une icône
  Widget _buildInfoRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// Chip de statut / type de vente
  Widget _buildStatusChip({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  /// Pill d'info vente
  Widget _buildSaleInfoPill(
      {required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
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
        return Colors.orange.shade700;
      default:
        return AppColors.textSecondary;
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
            colorScheme: const ColorScheme.light(
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
      const SnackBar(
        content: Text('Export en cours de développement'),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}