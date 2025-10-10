// ========================================
// lib/features/sales/presentation/screens/sale_detail_screen.dart
// Écran Détail d'une Vente - Module Sales
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../shared/constants/app_colors.dart';
import '../providers/sale_detail_provider.dart';
import '../providers/sale_detail_state.dart';
import '../../domain/entities/sale_detail_entity.dart';

/// Écran de détail d'une vente
class SaleDetailScreen extends ConsumerStatefulWidget {
  final String saleId;

  const SaleDetailScreen({
    super.key,
    required this.saleId,
  });

  @override
  ConsumerState<SaleDetailScreen> createState() => _SaleDetailScreenState();
}

class _SaleDetailScreenState extends ConsumerState<SaleDetailScreen> {
  final _dateFormat = DateFormat('dd/MM/yyyy à HH:mm');
  final _currencyFormat = NumberFormat('#,##0', 'fr_FR');

  @override
  void initState() {
    super.initState();

    // Charger le détail de la vente
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(saleDetailProvider(widget.saleId).notifier).loadSale();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(saleDetailProvider(widget.saleId));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(state),
      body: _buildBody(state),
    );
  }

  /// AppBar
  PreferredSizeWidget _buildAppBar(SaleDetailState state) {
    return AppBar(
      title: const Text('Détail de la vente'),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      actions: [
        // Imprimer le reçu
        if (state is SaleDetailLoaded)
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _printReceipt(state.sale),
            tooltip: 'Imprimer',
          ),

        // Menu actions
        if (state is SaleDetailLoaded)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            itemBuilder: (context) => [
              if (state.sale.canBeCancelled)
                const PopupMenuItem(
                  value: 'void',
                  child: Row(
                    children: [
                      Icon(Icons.cancel, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Annuler la vente'),
                    ],
                  ),
                ),
              if (state.sale.isCompleted)
                const PopupMenuItem(
                  value: 'return',
                  child: Row(
                    children: [
                      Icon(Icons.undo, size: 18),
                      SizedBox(width: 8),
                      Text('Retourner'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download, size: 18),
                    SizedBox(width: 8),
                    Text('Exporter'),
                  ],
                ),
              ),
            ],
            onSelected: (value) => _handleAction(state.sale, value),
          ),
      ],
    );
  }

  /// Corps selon l'état
  Widget _buildBody(SaleDetailState state) {
    if (state is SaleDetailLoading) {
      return _buildLoadingState();
    } else if (state is SaleDetailError) {
      return _buildErrorState(state);
    } else if (state is SaleDetailLoaded) {
      return _buildDetailView(state.sale);
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
            'Chargement du détail...',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  /// État d'erreur
  Widget _buildErrorState(SaleDetailError state) {
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
              ref.read(saleDetailProvider(widget.saleId).notifier).loadSale();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  /// Vue détaillée de la vente
  Widget _buildDetailView(SaleDetailEntity sale) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header avec N° et statut
          _buildHeader(sale),

          const SizedBox(height: 20),

          // Informations générales
          _buildGeneralInfo(sale),

          const SizedBox(height: 20),

          // Liste des articles
          _buildItemsList(sale),

          const SizedBox(height: 20),

          // Remises appliquées
          if (sale.items.any((item) => item.discountAmount > 0)) ...[
            _buildDiscounts(sale),
            const SizedBox(height: 20),
          ],

          // Paiements
          _buildPayments(sale),

          const SizedBox(height: 20),

          // Résumé des montants
          _buildSummary(sale),
        ],
      ),
    );
  }

  /// Header avec N° et statut
  Widget _buildHeader(SaleDetailEntity sale) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getStatusColor(sale.status),
            _getStatusColor(sale.status).withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _getStatusColor(sale.status).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // N° de vente
          Text(
            sale.saleNumber,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 8),

          // Statut
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              sale.statusDisplay,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Date
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.access_time, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(
                _dateFormat.format(sale.saleDate),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Informations générales
  Widget _buildGeneralInfo(SaleDetailEntity sale) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informations générales',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Client
            _buildInfoRow(
              icon: Icons.person,
              label: 'Client',
              value: sale.customer?.fullName ?? 'Client anonyme',
            ),

            if (sale.customer != null) ...[
              const SizedBox(height: 8),
              if (sale.customer!.phone != null)
                _buildInfoRow(
                  icon: Icons.phone,
                  label: 'Téléphone',
                  value: sale.customer!.phone!,
                ),
              if (sale.customer!.email != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  icon: Icons.email,
                  label: 'Email',
                  value: sale.customer!.email!,
                ),
              ],
            ],

            const SizedBox(height: 8),

            // Caissier
            _buildInfoRow(
              icon: Icons.badge,
              label: 'Caissier',
              value: sale.cashier,
            ),

            const SizedBox(height: 8),

            // Type de vente
            _buildInfoRow(
              icon: Icons.category,
              label: 'Type',
              value: sale.saleTypeDisplay,
            ),
          ],
        ),
      ),
    );
  }

  /// Ligne d'information
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Liste des articles
  Widget _buildItemsList(SaleDetailEntity sale) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Articles (${sale.items.length})',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // En-tête du tableau
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Expanded(
                    flex: 3,
                    child: Text(
                      'Article',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Qté',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'P.U.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  if (sale.items.any((item) => item.discountAmount > 0))
                    const Expanded(
                      child: Text(
                        'Remise',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  const Expanded(
                    child: Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Liste des articles
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sale.items.length,
              separatorBuilder: (context, index) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final item = sale.items[index];
                return Row(
                  children: [
                    // Article
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.articleName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            item.articleCode,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Quantité
                    Expanded(
                      child: Text(
                        item.quantity.toStringAsFixed(item.quantity % 1 == 0 ? 0 : 2),
                        style: const TextStyle(fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    // Prix unitaire
                    Expanded(
                      child: Text(
                        _currencyFormat.format(item.unitPrice),
                        style: const TextStyle(fontSize: 14),
                        textAlign: TextAlign.right,
                      ),
                    ),

                    // Remise
                    if (sale.items.any((item) => item.discountAmount > 0))
                      Expanded(
                        child: Text(
                          item.discountAmount > 0
                              ? '-${_currencyFormat.format(item.discountAmount)}'
                              : '-',
                          style: TextStyle(
                            fontSize: 14,
                            color: item.discountAmount > 0
                                ? AppColors.warning
                                : Colors.grey[600],
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),

                    // Total
                    Expanded(
                      child: Text(
                        _currencyFormat.format(item.lineTotal),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Remises appliquées
  Widget _buildDiscounts(SaleDetailEntity sale) {
    // Collecter les remises des items
    final itemsWithDiscounts = sale.items.where((item) => item.discountAmount > 0).toList();

    if (itemsWithDiscounts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_offer, color: AppColors.warning, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Remises appliquées',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: itemsWithDiscounts.length,
              separatorBuilder: (context, index) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final item = itemsWithDiscounts[index];
                return Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.articleName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Remise ${item.discountPercentage}%',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '-${_currencyFormat.format(item.discountAmount)} FCFA',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Paiements
  Widget _buildPayments(SaleDetailEntity sale) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.payment, color: AppColors.success, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Paiements',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sale.payments.length,
              separatorBuilder: (context, index) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final payment = sale.payments[index];
                return Row(
                  children: [
                    // Icône du moyen de paiement
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getPaymentIcon(payment.paymentMethod?.name ?? 'Paiement'),
                        color: AppColors.success,
                        size: 20,
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Détails du paiement
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            payment.paymentMethod?.name ?? 'Paiement',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          // ⭐ CORRECTION ICI: transactionId au lieu de reference
                          if (payment.transactionId != null && payment.transactionId!.isNotEmpty)
                            Text(
                              'Réf: ${payment.transactionId}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Montant
                    Text(
                      '${_currencyFormat.format(payment.amount)} FCFA',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Résumé des montants
  Widget _buildSummary(SaleDetailEntity sale) {
    // Calculer le sous-total à partir du total
    final subtotal = sale.totalAmount + sale.discountAmount - sale.taxAmount;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Sous-total
            _buildSummaryRow(
              label: 'Sous-total',
              value: '${_currencyFormat.format(subtotal)} FCFA',
              isSubtotal: true,
            ),

            const SizedBox(height: 8),

            // Remise totale
            if (sale.discountAmount > 0) ...[
              _buildSummaryRow(
                label: 'Remise totale',
                value: '-${_currencyFormat.format(sale.discountAmount)} FCFA',
                isDiscount: true,
              ),
              const SizedBox(height: 8),
            ],

            // Taxe
            if (sale.taxAmount > 0) ...[
              _buildSummaryRow(
                label: 'Taxe',
                value: '${_currencyFormat.format(sale.taxAmount)} FCFA',
              ),
              const SizedBox(height: 8),
            ],

            const Divider(height: 24),

            // Total
            _buildSummaryRow(
              label: 'Total',
              value: '${_currencyFormat.format(sale.totalAmount)} FCFA',
              isTotal: true,
            ),

            const SizedBox(height: 12),

            // Montant payé
            _buildSummaryRow(
              label: 'Payé',
              value: '${_currencyFormat.format(sale.paidAmount)} FCFA',
              isPaid: true,
            ),

            // Balance/Monnaie
            if (sale.balance != 0) ...[
              const SizedBox(height: 8),
              _buildSummaryRow(
                label: sale.balance > 0 ? 'Monnaie' : 'Reste à payer',
                value: '${_currencyFormat.format(sale.balance.abs())} FCFA',
                isBalance: sale.balance > 0,
                isRemaining: sale.balance < 0,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Ligne du résumé
  Widget _buildSummaryRow({
    required String label,
    required String value,
    bool isSubtotal = false,
    bool isDiscount = false,
    bool isTotal = false,
    bool isPaid = false,
    bool isBalance = false,
    bool isRemaining = false,
  }) {
    Color? valueColor;
    if (isDiscount) valueColor = AppColors.warning;
    if (isTotal) valueColor = Colors.black;
    if (isPaid) valueColor = AppColors.success;
    if (isBalance) valueColor = AppColors.info;
    if (isRemaining) valueColor = AppColors.error;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isTotal ? Colors.black : Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 20 : 14,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  /// Icône selon le moyen de paiement
  IconData _getPaymentIcon(String paymentMethod) {
    final lower = paymentMethod.toLowerCase();
    if (lower.contains('espèces') || lower.contains('cash')) {
      return Icons.payments;
    } else if (lower.contains('carte') || lower.contains('card')) {
      return Icons.credit_card;
    } else if (lower.contains('mobile') || lower.contains('money')) {
      return Icons.phone_android;
    } else if (lower.contains('chèque') || lower.contains('check')) {
      return Icons.receipt;
    } else if (lower.contains('crédit') || lower.contains('credit')) {
      return Icons.account_balance_wallet;
    } else if (lower.contains('bon') || lower.contains('voucher')) {
      return Icons.card_giftcard;
    }
    return Icons.payment;
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

  /// Gestion des actions
  void _handleAction(SaleDetailEntity sale, String action) {
    switch (action) {
      case 'void':
        _confirmVoidSale(sale);
        break;
      case 'return':
        _handleReturn(sale);
        break;
      case 'export':
        _exportSale(sale);
        break;
    }
  }

  /// Confirmer l'annulation de la vente
  void _confirmVoidSale(SaleDetailEntity sale) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la vente'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Êtes-vous sûr de vouloir annuler la vente ${sale.saleNumber} ?'),
            const SizedBox(height: 16),
            Text(
              'Cette action est irréversible.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Non'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(saleDetailProvider(widget.saleId).notifier)
                  .voidSale('Annulation manuelle');
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );
  }

  /// Gérer le retour
  void _handleReturn(SaleDetailEntity sale) {
    // TODO: Implémenter le retour de vente
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Retour de vente en cours de développement'),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Imprimer le reçu
  void _printReceipt(SaleDetailEntity sale) {
    // TODO: Implémenter l'impression
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Impression en cours de développement'),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Exporter la vente
  void _exportSale(SaleDetailEntity sale) {
    // TODO: Implémenter l'export
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Export en cours de développement'),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}