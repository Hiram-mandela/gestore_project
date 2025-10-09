// ========================================
// lib/features/sales/presentation/screens/pos_screen.dart
// Écran POS Moderne - Interface Point de Vente
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/constants/app_colors.dart';
import '../providers/pos_provider.dart';
import '../providers/pos_state.dart';
import '../providers/payment_methods_provider.dart';
import '../widgets/pos_cart_widget.dart';
import '../widgets/pos_product_search_widget.dart';
import '../widgets/pos_payment_dialog.dart';

/// Écran principal du POS
class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // Ouvrir la session POS au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(posProvider.notifier).openSession();
      ref.read(paymentMethodsProvider.notifier).loadPaymentMethods();
    });

    // Focus sur la recherche au démarrage
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _searchFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final posState = ref.watch(posProvider);

    // Gérer les changements d'état
    ref.listen<PosState>(posProvider, (previous, next) {
      if (next is PosCheckoutSuccess) {
        _showCheckoutSuccessDialog(next);
      } else if (next is PosError) {
        _showErrorSnackBar(next.message);
      }
    });

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: posState is PosReady ? _buildReadyView(posState) : _buildLoadingView(),
    );
  }

  /// Vue principale (session active)
  Widget _buildReadyView(PosReady state) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: _handleKeyPress,
      child: Row(
        children: [
          // Partie gauche - Recherche et produits (70%)
          Expanded(
            flex: 7,
            child: _buildLeftPanel(state),
          ),

          // Séparateur
          Container(
            width: 1,
            color: Colors.grey[300],
          ),

          // Partie droite - Panier et actions (30%)
          Expanded(
            flex: 3,
            child: _buildRightPanel(state),
          ),
        ],
      ),
    );
  }

  /// Panel gauche - Recherche et produits
  Widget _buildLeftPanel(PosReady state) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Header avec recherche
          _buildSearchHeader(),

          // Zone de recherche de produits
          Expanded(
            child: PosProductSearchWidget(
              searchController: _searchController,
              onArticleSelected: (article) {
                ref.read(posProvider.notifier).addArticle(article);
                _searchController.clear();
                _searchFocusNode.requestFocus();
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Header avec barre de recherche
  Widget _buildSearchHeader() {
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
          // Logo/Titre
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.point_of_sale, color: AppColors.primary, size: 24),
                const SizedBox(width: 8),
                Text(
                  'POINT DE VENTE',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 20),

          // Barre de recherche
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: 'Rechercher un produit (Nom, Code, Scanner...)',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey[600]),
                    onPressed: () {
                      _searchController.clear();
                      _searchFocusNode.requestFocus();
                      setState(() {});
                    },
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onChanged: (value) => setState(() {}),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Bouton scanner
          _buildActionButton(
            icon: Icons.qr_code_scanner,
            label: 'Scanner',
            color: AppColors.info,
            onPressed: () {
              // TODO: Implémenter scanner
              _showInfoSnackBar('Scanner non disponible');
            },
          ),
        ],
      ),
    );
  }

  /// Panel droit - Panier et actions
  Widget _buildRightPanel(PosReady state) {
    return Container(
      color: Colors.grey[50],
      child: Column(
        children: [
          // Header du panier
          _buildCartHeader(state),

          // Panier (liste des articles)
          Expanded(
            child: PosCartWidget(
              cartItems: state.cartItems,
              onUpdateQuantity: (articleId, quantity) {
                ref.read(posProvider.notifier).updateQuantity(articleId, quantity);
              },
              onRemoveItem: (articleId) {
                ref.read(posProvider.notifier).removeArticle(articleId);
              },
              onApplyDiscount: (articleId, discount) {
                ref.read(posProvider.notifier).applyItemDiscount(articleId, discount);
              },
            ),
          ),

          // Résumé et totaux
          _buildCartSummary(state),

          // Boutons d'actions
          _buildActionButtons(state),
        ],
      ),
    );
  }

  /// Header du panier avec client
  Widget _buildCartHeader(PosReady state) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Client
          Row(
            children: [
              Icon(Icons.person_outline, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  state.customer?.fullName ?? 'Client anonyme',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (state.customer != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () {
                    ref.read(posProvider.notifier).removeCustomer();
                  },
                  tooltip: 'Retirer client',
                )
              else
                TextButton.icon(
                  onPressed: () {
                    // TODO: Ouvrir sélecteur de client
                    _showInfoSnackBar('Sélection client non implémentée');
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Ajouter'),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Statistiques panier
          Row(
            children: [
              _buildCartStat(
                icon: Icons.shopping_cart_outlined,
                label: 'Articles',
                value: '${state.itemsCount}',
                color: AppColors.primary,
              ),
              const SizedBox(width: 16),
              _buildCartStat(
                icon: Icons.inventory_2_outlined,
                label: 'Quantité',
                value: state.totalQuantity.toStringAsFixed(0),
                color: AppColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Statistique du panier
  Widget _buildCartStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Résumé des totaux
  Widget _buildCartSummary(PosReady state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSummaryRow('Sous-total', state.subtotal),
          if (state.discountAmount > 0) ...[
            const SizedBox(height: 8),
            _buildSummaryRow(
              'Remises',
              -state.discountAmount,
              color: AppColors.success,
            ),
          ],
          if (state.taxAmount > 0) ...[
            const SizedBox(height: 8),
            _buildSummaryRow('Taxes', state.taxAmount),
          ],
          const Divider(height: 24),
          _buildSummaryRow(
            'TOTAL',
            state.totalAmount,
            isTotal: true,
          ),
          if (state.paidAmount > 0) ...[
            const SizedBox(height: 8),
            _buildSummaryRow(
              'Payé',
              state.paidAmount,
              color: AppColors.info,
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              'Reste',
              state.balance,
              color: state.balance > 0 ? AppColors.error : AppColors.success,
            ),
          ],
        ],
      ),
    );
  }

  /// Ligne de résumé
  Widget _buildSummaryRow(
      String label,
      double amount, {
        bool isTotal = false,
        Color? color,
      }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: color ?? (isTotal ? AppColors.primary : Colors.grey[700]),
          ),
        ),
        Text(
          '${amount.toStringAsFixed(0)} FCFA',
          style: TextStyle(
            fontSize: isTotal ? 20 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: color ?? (isTotal ? AppColors.primary : Colors.black87),
          ),
        ),
      ],
    );
  }

  /// Boutons d'actions
  Widget _buildActionButtons(PosReady state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Bouton Paiement (Principal)
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: state.isCartEmpty
                  ? null
                  : () => _showPaymentDialog(state),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                disabledBackgroundColor: Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.payment, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    state.paidAmount > 0 ? 'FINALISER' : 'PAIEMENT',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Boutons secondaires
          Row(
            children: [
              // Vider panier
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: state.isCartEmpty
                      ? null
                      : () {
                    ref.read(posProvider.notifier).clearCart();
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Vider'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(color: AppColors.error.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Suspendre (TODO)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.pause_circle_outline),
                  label: const Text('Suspendre'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Vue de chargement
  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Ouverture de la caisse...',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  /// Bouton d'action générique
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
    );
  }

  /// Gestion des touches clavier
  void _handleKeyPress(RawKeyEvent event) {
    if (event is! RawKeyDownEvent) return;

    // F2 = Focus recherche
    if (event.logicalKey == LogicalKeyboardKey.f2) {
      _searchFocusNode.requestFocus();
    }
    // F8 = Paiement
    else if (event.logicalKey == LogicalKeyboardKey.f8) {
      final state = ref.read(posProvider);
      if (state is PosReady && !state.isCartEmpty) {
        _showPaymentDialog(state);
      }
    }
    // F9 = Vider panier
    else if (event.logicalKey == LogicalKeyboardKey.f9) {
      final state = ref.read(posProvider);
      if (state is PosReady && !state.isCartEmpty) {
        ref.read(posProvider.notifier).clearCart();
      }
    }
  }

  /// Affiche le dialogue de paiement
  Future<void> _showPaymentDialog(PosReady state) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PosPaymentDialog(
        totalAmount: state.totalAmount,
        balance: state.balance,
        existingPayments: state.payments,
      ),
    );

    if (result == true) {
      // Paiement complété, finaliser la vente
      ref.read(posProvider.notifier).checkout();
    }
  }

  /// Affiche le dialogue de succès
  void _showCheckoutSuccessDialog(PosCheckoutSuccess state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.check_circle,
          color: AppColors.success,
          size: 64,
        ),
        title: const Text('Vente finalisée !'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'N° ${state.saleNumber}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Total: ${state.totalAmount.toStringAsFixed(0)} FCFA',
              style: const TextStyle(fontSize: 18),
            ),
            if (state.changeAmount > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Monnaie: ${state.changeAmount.toStringAsFixed(0)} FCFA',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Impression reçu
            },
            child: const Text('IMPRIMER'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(posProvider.notifier).resetAfterCheckout();
              _searchFocusNode.requestFocus();
            },
            child: const Text('NOUVELLE VENTE'),
          ),
        ],
      ),
    );
  }

  /// Affiche une erreur
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Affiche une info
  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}