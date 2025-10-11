// ========================================
// lib/features/sales/presentation/screens/payment_methods_list_screen.dart
// Écran Liste des Moyens de Paiement - Module Sales
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/constants/app_colors.dart';
import '../providers/payment_methods_list_provider.dart';
import '../providers/payment_methods_list_state.dart';
import '../../domain/entities/payment_method_entity.dart';

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
              ),
            );
          } else if (next is PaymentMethodsListError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(next.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        });

    return Scaffold(
      backgroundColor: Colors.grey[50],
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
          // Icône et titre
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
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
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Gérer les modes de paiement acceptés',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const Spacer(),

          // Bouton Nouveau
          FilledButton.icon(
            onPressed: () => context.push('/sales/payment-methods/new'),
            icon: const Icon(Icons.add),
            label: const Text('Nouveau moyen de paiement'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Barre de recherche et filtres
  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Row(
        children: [
          // Recherche
          Expanded(
            flex: 2,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un moyen de paiement...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    ref
                        .read(paymentMethodsListProvider.notifier)
                        .searchPaymentMethods('');
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                filled: true,
                fillColor: Colors.grey[50],
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
              decoration: InputDecoration(
                labelText: 'Type',
                prefixIcon: const Icon(Icons.category),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('Tous les types')),
                const DropdownMenuItem(value: 'cash', child: Text('Espèces')),
                const DropdownMenuItem(value: 'card', child: Text('Carte bancaire')),
                const DropdownMenuItem(value: 'mobile_money', child: Text('Mobile Money')),
                const DropdownMenuItem(value: 'check', child: Text('Chèque')),
                const DropdownMenuItem(value: 'credit', child: Text('Crédit')),
                const DropdownMenuItem(value: 'voucher', child: Text('Bon d\'achat')),
                const DropdownMenuItem(
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
              decoration: InputDecoration(
                labelText: 'Statut',
                prefixIcon: const Icon(Icons.toggle_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
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
          ),
        ],
      ),
    );
  }

  /// Contenu principal selon l'état
  Widget _buildContent(PaymentMethodsListState state) {
    if (state is PaymentMethodsListLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state is PaymentMethodsListError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              state.message,
              style: const TextStyle(fontSize: 16),
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
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              if (state.searchQuery.isEmpty &&
                  state.selectedType == null &&
                  state.selectedStatus == null)
                FilledButton.icon(
                  onPressed: () => context.push('/sales/payment-methods/new'),
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter un moyen de paiement'),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            // Header du tableau
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Nom',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Type',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Frais',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Montant max',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Statut',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 100), // Pour les actions
                ],
              ),
            ),

            // Corps du tableau
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: paymentMethods.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: Colors.grey[200],
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
              flex: 2,
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
                          ),
                        ),
                        if (paymentMethod.description != null &&
                            paymentMethod.description!.isNotEmpty)
                          Text(
                            paymentMethod.description!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
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
                style: const TextStyle(fontSize: 14),
              ),
            ),

            // Frais
            Expanded(
              child: Text(
                paymentMethod.feePercentage > 0
                    ? '${paymentMethod.feePercentage.toStringAsFixed(1)}%'
                    : '-',
                style: TextStyle(
                  fontSize: 14,
                  color: paymentMethod.feePercentage > 0
                      ? AppColors.warning
                      : Colors.grey[600],
                ),
              ),
            ),

            // Montant max
            Expanded(
              child: Text(
                paymentMethod.maxAmount != null
                    ? '${paymentMethod.maxAmount!.toStringAsFixed(0)} F'
                    : 'Illimité',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ),

            // Statut
            Expanded(
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
                          : Colors.grey,
                    ),
                    tooltip: paymentMethod.isActive ? 'Désactiver' : 'Activer',
                    onPressed: () => _confirmToggleActivation(paymentMethod),
                  ),

                  // Supprimer
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: AppColors.error),
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
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'Actif' : 'Inactif',
        style: TextStyle(
          color: isActive ? AppColors.success : Colors.grey[700],
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
        title: Text('Confirmer ${action == 'activer' ? 'l\'activation' : 'la désactivation'}'),
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
        return Colors.orange;
      case 'voucher':
        return Colors.purple;
      case 'loyalty_points':
        return Colors.amber;
      default:
        return AppColors.primary;
    }
  }
}