// ========================================
// lib/features/sales/presentation/screens/payment_methods_list_screen.dart
// Écran Liste des Moyens de Paiement - Module Sales
// VERSION AMÉLIORÉE - DESIGN REFACTORING
//
// Changements stylistiques majeurs :
// - Intégration de la palette GESTORE pour les fonds, textes, et couleurs d'accent.
// - Modernisation des champs de recherche et de filtres pour une meilleure UX.
// - Remplacement du tableau par un design plus clair avec une meilleure hiérarchie visuelle.
// - Harmonisation des icônes, badges de statut, et boutons avec la charte graphique.
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../domain/entities/payment_method_entity.dart';
import '../providers/payment_methods_list_provider.dart';
import '../providers/payment_methods_list_state.dart';

/// Écran de liste des moyens de paiement
class PaymentMethodsListScreen extends ConsumerStatefulWidget {
  const PaymentMethodsListScreen({super.key});

  @override
  ConsumerState<PaymentMethodsListScreen> createState() =>
      _PaymentMethodsListScreenState();
}

class _PaymentMethodsListScreenState
    extends ConsumerState<PaymentMethodsListScreen> {
  final _searchController = TextEditingController();

  String? _selectedType;
  bool? _selectedStatus;

  @override
  void initState() {
    super.initState();
    // Charger les moyens de paiement au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paymentMethodsListProvider.notifier).loadPaymentMethods();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentMethodsListProvider);

    // Écouter les changements d'état pour les messages
    ref.listen<PaymentMethodsListState>(paymentMethodsListProvider,
            (previous, next) {
          if (next is PaymentMethodDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(next.message),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (next is PaymentMethodsListError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(next.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        });

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          // Header avec titre et bouton d'ajout
          _buildHeader(),
          // Barre de recherche et filtres
          _buildSearchAndFilters(),
          // Contenu principal
          Expanded(
            child: _buildContent(state),
          ),
        ],
      ),
    );
  }

  /// Header avec titre et bouton Nouveau
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        boxShadow: [AppColors.subtleShadow()],
      ),
      child: Row(
        children: [
          // Icône et titre
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.payment,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Moyens de paiement',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Gérer les modes de paiement acceptés',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Bouton Nouveau
          FilledButton.icon(
            onPressed: () => context.push('/sales/payment-methods/new'),
            icon: const Icon(Icons.add),
            label: const Text('Nouveau moyen'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Style de décoration réutilisable pour les champs de texte
  InputDecoration _inputDecoration({
    required String labelText,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      prefixIcon: Icon(icon, color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.surfaceLight,
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
    );
  }

  /// Barre de recherche et filtres
  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      color: AppColors.surfaceLight,
      child: Row(
        children: [
          // Recherche
          Expanded(
            flex: 2,
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: _inputDecoration(
                labelText: 'Rechercher un moyen de paiement...',
                icon: Icons.search,
              ).copyWith(
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                  onPressed: () {
                    _searchController.clear();
                    ref
                        .read(paymentMethodsListProvider.notifier)
                        .searchPaymentMethods('');
                  },
                )
                    : null,
              ),
              onChanged: (value) {
                ref
                    .read(paymentMethodsListProvider.notifier)
                    .searchPaymentMethods(value);
              },
            ),
          ),
          const SizedBox(width: 16),
          // Filtre Type
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: _selectedType,
              decoration: _inputDecoration(
                labelText: 'Type',
                icon: Icons.category,
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('Tous les types')),
                DropdownMenuItem(value: 'cash', child: Text('Espèces')),
                DropdownMenuItem(value: 'card', child: Text('Carte bancaire')),
                DropdownMenuItem(
                    value: 'mobile_money', child: Text('Mobile Money')),
                DropdownMenuItem(value: 'check', child: Text('Chèque')),
                DropdownMenuItem(value: 'credit', child: Text('Crédit')),
                DropdownMenuItem(value: 'voucher', child: Text('Bon d\'achat')),
                DropdownMenuItem(
                    value: 'loyalty_points', child: Text('Points fidélité')),
              ],
              onChanged: (value) {
                setState(() => _selectedType = value);
                ref
                    .read(paymentMethodsListProvider.notifier)
                    .filterByType(value);
              },
            ),
          ),
          const SizedBox(width: 16),
          // Filtre Statut
          Expanded(
            child: DropdownButtonFormField<bool?>(
              initialValue: _selectedStatus,
              decoration: _inputDecoration(
                labelText: 'Statut',
                icon: Icons.toggle_on,
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('Tous')),
                DropdownMenuItem(value: true, child: Text('Actifs')),
                DropdownMenuItem(value: false, child: Text('Inactifs')),
              ],
              onChanged: (value) {
                setState(() => _selectedStatus = value);
                ref
                    .read(paymentMethodsListProvider.notifier)
                    .filterByStatus(value);
              },
            ),
          ),
          const SizedBox(width: 16),
          // Bouton Réinitialiser filtres
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _searchController.clear();
                _selectedType = null;
                _selectedStatus = null;
              });
              ref.read(paymentMethodsListProvider.notifier).resetFilters();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Réinitialiser'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.border),
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

  /// Contenu principal selon l'état
  Widget _buildContent(PaymentMethodsListState state) {
    if (state is PaymentMethodsListLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (state is PaymentMethodsListError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              state.message,
              style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                ref
                    .read(paymentMethodsListProvider.notifier)
                    .loadPaymentMethods();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }
    if (state is PaymentMethodsListLoaded) {
      if (state.filteredPaymentMethods.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.payment, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                state.searchQuery.isNotEmpty ||
                    state.selectedType != null ||
                    state.selectedStatus != null
                    ? 'Aucun moyen de paiement ne correspond aux filtres'
                    : 'Aucun moyen de paiement configuré',
                style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              if (state.searchQuery.isEmpty &&
                  state.selectedType == null &&
                  state.selectedStatus == null)
                FilledButton.icon(
                  onPressed: () => context.push('/sales/payment-methods/new'),
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter un moyen de paiement'),
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                ),
            ],
          ),
        );
      }
      return _buildPaymentMethodsTable(state.filteredPaymentMethods);
    }
    return const SizedBox.shrink();
  }

  /// Tableau des moyens de paiement
  Widget _buildPaymentMethodsTable(List<PaymentMethodEntity> paymentMethods) {
    final headerStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: AppColors.textSecondary,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            // Header du tableau
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: const BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Expanded(flex: 3, child: Text('Nom', style: headerStyle)),
                  Expanded(flex: 2, child: Text('Type', style: headerStyle)),
                  Expanded(flex: 1, child: Text('Frais', style: headerStyle)),
                  Expanded(flex: 2, child: Text('Montant max', style: headerStyle)),
                  Expanded(flex: 1, child: Text('Statut', style: headerStyle, textAlign: TextAlign.center)),
                  const SizedBox(width: 100), // Pour les actions
                ],
              ),
            ),
            // Corps du tableau
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: paymentMethods.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                color: AppColors.border,
              ),
              itemBuilder: (context, index) {
                final paymentMethod = paymentMethods[index];
                return _buildPaymentMethodRow(paymentMethod);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Ligne du tableau pour un moyen de paiement
  Widget _buildPaymentMethodRow(PaymentMethodEntity paymentMethod) {
    return InkWell(
      onTap: () => context.push('/sales/payment-methods/${paymentMethod.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Nom avec icône
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getPaymentTypeColor(paymentMethod.paymentType)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getPaymentTypeIcon(paymentMethod.paymentType),
                      color: _getPaymentTypeColor(paymentMethod.paymentType),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          paymentMethod.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (paymentMethod.description != null &&
                            paymentMethod.description!.isNotEmpty)
                          Text(
                            paymentMethod.description!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Type
            Expanded(
              flex: 2,
              child: Text(
                paymentMethod.paymentTypeDisplay,
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ),
            // Frais
            Expanded(
              flex: 1,
              child: Text(
                paymentMethod.feePercentage > 0
                    ? '${paymentMethod.feePercentage.toStringAsFixed(1)}%'
                    : '-',
                style: TextStyle(
                  fontSize: 14,
                  color: paymentMethod.feePercentage > 0
                      ? AppColors.warning
                      : AppColors.textSecondary,
                ),
              ),
            ),
            // Montant max
            Expanded(
              flex: 2,
              child: Text(
                paymentMethod.maxAmount != null
                    ? '${paymentMethod.maxAmount!.toStringAsFixed(0)} F'
                    : 'Illimité',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            // Statut
            Expanded(
              flex: 1,
              child: Center(
                child: _buildStatusChip(paymentMethod.isActive),
              ),
            ),
            // Actions
            SizedBox(
              width: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Toggle Actif/Inactif
                  IconButton(
                    icon: Icon(
                      paymentMethod.isActive
                          ? Icons.toggle_on
                          : Icons.toggle_off,
                      color: paymentMethod.isActive
                          ? AppColors.success
                          : AppColors.textSecondary,
                      size: 28,
                    ),
                    tooltip: paymentMethod.isActive ? 'Désactiver' : 'Activer',
                    onPressed: () => _confirmToggleActivation(paymentMethod),
                  ),
                  // Supprimer
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.error),
                    tooltip: 'Supprimer',
                    onPressed: () => _confirmDelete(paymentMethod),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Chip de statut
  Widget _buildStatusChip(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.border.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'Actif' : 'Inactif',
        style: TextStyle(
          color: isActive ? AppColors.success : AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Confirmation de suppression
  Future<void> _confirmDelete(PaymentMethodEntity paymentMethod) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer le moyen de paiement "${paymentMethod.name}" ?\n\n'
              'Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      ref
          .read(paymentMethodsListProvider.notifier)
          .deletePaymentMethod(paymentMethod.id);
    }
  }

  /// Confirmation toggle activation
  Future<void> _confirmToggleActivation(PaymentMethodEntity paymentMethod) async {
    final action = paymentMethod.isActive ? 'désactiver' : 'activer';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            'Confirmer ${action == 'activer' ? 'l\'activation' : 'la désactivation'}'),
        content: Text(
          'Voulez-vous $action le moyen de paiement "${paymentMethod.name}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor:
              paymentMethod.isActive ? AppColors.textSecondary : AppColors.success,
            ),
            child: Text(action == 'activer' ? 'Activer' : 'Désactiver'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      ref
          .read(paymentMethodsListProvider.notifier)
          .toggleActivation(paymentMethod.id, paymentMethod.isActive);
    }
  }

  /// Icône selon le type de paiement
  IconData _getPaymentTypeIcon(String type) {
    switch (type) {
      case 'cash':
        return Icons.attach_money;
      case 'card':
        return Icons.credit_card;
      case 'mobile_money':
        return Icons.phone_android;
      case 'check':
        return Icons.receipt;
      case 'credit':
        return Icons.account_balance_wallet;
      case 'voucher':
        return Icons.card_giftcard;
      case 'loyalty_points':
        return Icons.stars;
      default:
        return Icons.payment;
    }
  }

  /// Couleur selon le type de paiement
  Color _getPaymentTypeColor(String type) {
    switch (type) {
      case 'cash':
        return AppColors.success;
      case 'card':
        return AppColors.primary;
      case 'mobile_money':
        return AppColors.info;
      case 'check':
        return AppColors.warning;
      case 'credit':
        return AppColors.secondary;
      case 'voucher':
        return AppColors.customers; // Using a distinct color from the palette
      case 'loyalty_points':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }
}