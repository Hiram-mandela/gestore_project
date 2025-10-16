// ========================================
// lib/features/sales/presentation/screens/discounts_list_screen.dart
// Écran Liste des Remises/Promotions - Module Sales
// VERSION CORRIGÉE - DESIGN REFACTORING V2
//
// Changements stylistiques majeurs :
// - Intégration complète de la palette GESTORE depuis `app_colors.dart`.
// - Correction du problème de lisibilité des textes dans les champs de filtre.
// - Correction du fond des cartes de remise, qui sont maintenant blanches (`surfaceLight`).
// - Harmonisation des couleurs de texte, bordures et icônes avec la nouvelle charte.
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

// IMPORTANT : Assurez-vous que le chemin d'importation est correct pour votre projet.
import '../../../../shared/constants/app_colors.dart';
import '../../domain/entities/discount_entity.dart';
import '../providers/discounts_list_provider.dart';
import '../providers/discounts_list_state.dart';

/// Écran de liste des remises/promotions
class DiscountsListScreen extends ConsumerStatefulWidget {
  const DiscountsListScreen({super.key});

  @override
  ConsumerState<DiscountsListScreen> createState() =>
      _DiscountsListScreenState();
}

class _DiscountsListScreenState extends ConsumerState<DiscountsListScreen> {
  final _searchController = TextEditingController();
  final _dateFormat = DateFormat('dd/MM/yyyy');

  String? _selectedType;
  String? _selectedScope;
  bool? _selectedStatus;
  bool _showActiveOnly = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(discountsListProvider.notifier).loadDiscounts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(discountsListProvider);

    ref.listen<DiscountsListState>(discountsListProvider, (previous, next) {
      if (next is DiscountDeleted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: AppColors.success, // [cite: 9]
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (next is DiscountsListError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: AppColors.error, // [cite: 11]
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundLight, // [cite: 13]
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchAndFilters(),
          Expanded(
            child: _buildContent(state),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight, // [cite: 15]
        boxShadow: [AppColors.subtleShadow()], // [cite: 36]
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1), // [cite: 10]
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_offer,
              color: AppColors.warning, // [cite: 10]
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Remises et Promotions',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary, // [cite: 17]
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Gérer les réductions et offres spéciales',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary, // 
                ),
              ),
            ],
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: () => context.push('/sales/discounts/new'),
            icon: const Icon(Icons.add),
            label: const Text('Nouvelle remise'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.warning, // [cite: 10]
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

  InputDecoration _inputDecoration({
    required String labelText,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: labelText,
      // CORRECTION : Utilisation de couleurs de texte GESTORE pour une meilleure lisibilité.
      labelStyle: const TextStyle(color: AppColors.textSecondary), // 
      hintStyle: const TextStyle(color: AppColors.textTertiary), // [cite: 19]
      prefixIcon: Icon(icon, color: AppColors.textSecondary), // 
      fillColor: AppColors.surfaceLight, // [cite: 15]
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border), // [cite: 23]
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border), // [cite: 23]
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.warning, width: 2), // [cite: 10]
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: AppColors.surfaceLight, // [cite: 15]
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: AppColors.textPrimary), // [cite: 17]
                  decoration: _inputDecoration(
                    labelText: 'Rechercher par nom ou code...',
                    icon: Icons.search,
                  ).copyWith(
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      color: AppColors.textSecondary, // 
                      onPressed: () {
                        _searchController.clear();
                        ref
                            .read(discountsListProvider.notifier)
                            .searchDiscounts('');
                      },
                    )
                        : null,
                  ),
                  onChanged: (value) {
                    ref
                        .read(discountsListProvider.notifier)
                        .searchDiscounts(value);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedType,
                  decoration: _inputDecoration(
                    labelText: 'Type de remise',
                    icon: Icons.category,
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Tous les types')),
                    DropdownMenuItem(
                        value: 'percentage', child: Text('Pourcentage')),
                    DropdownMenuItem(
                        value: 'fixed_amount', child: Text('Montant fixe')),
                    DropdownMenuItem(
                        value: 'buy_x_get_y',
                        child: Text('Achetez X Obtenez Y')),
                    DropdownMenuItem(
                        value: 'loyalty_points',
                        child: Text('Points fidélité')),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedType = value);
                    ref.read(discountsListProvider.notifier).filterByType(value);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedScope,
                  decoration: _inputDecoration(
                    labelText: 'Portée',
                    icon: Icons.filter_list,
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: null, child: Text('Toutes les portées')),
                    DropdownMenuItem(value: 'sale', child: Text('Vente totale')),
                    DropdownMenuItem(
                        value: 'category', child: Text('Catégorie')),
                    DropdownMenuItem(value: 'article', child: Text('Article')),
                    DropdownMenuItem(value: 'customer', child: Text('Client')),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedScope = value);
                    ref
                        .read(discountsListProvider.notifier)
                        .filterByScope(value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
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
                        .read(discountsListProvider.notifier)
                        .filterByStatus(value);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 58, // Match text field height
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.surfaceLight, // [cite: 15]
                    border: Border.all(color: AppColors.border), // [cite: 23]
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event_available,
                          size: 20, color: AppColors.textSecondary), // 
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Uniquement en cours',
                          style: TextStyle(
                              fontSize: 14, color: AppColors.textPrimary), // [cite: 17]
                        ),
                      ),
                      Switch(
                        value: _showActiveOnly,
                        onChanged: (value) {
                          setState(() => _showActiveOnly = value);
                          ref
                              .read(discountsListProvider.notifier)
                              .toggleActiveOnly(value);
                        },
                        activeThumbColor: AppColors.success, // [cite: 9]
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _selectedType = null;
                    _selectedScope = null;
                    _selectedStatus = null;
                    _showActiveOnly = false;
                  });
                  ref.read(discountsListProvider.notifier).resetFilters();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Réinitialiser'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary, // 
                  side: const BorderSide(color: AppColors.border), // [cite: 23]
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(DiscountsListState state) {
    if (state is DiscountsListLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.warning)); // [cite: 10]
    }
    if (state is DiscountsListError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error), // [cite: 11]
            const SizedBox(height: 16),
            Text(
              state.message,
              style: const TextStyle(fontSize: 16, color: AppColors.textPrimary), // [cite: 17]
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                ref.read(discountsListProvider.notifier).loadDiscounts();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }
    if (state is DiscountsListLoaded) {
      if (state.discounts.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_offer, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                state.searchQuery.isNotEmpty || state.selectedType != null
                    ? 'Aucune remise ne correspond aux filtres'
                    : 'Aucune remise configurée',
                style: const TextStyle(fontSize: 16, color: AppColors.textSecondary), // 
              ),
              const SizedBox(height: 24),
              if (state.searchQuery.isEmpty && state.selectedType == null)
                FilledButton.icon(
                  onPressed: () => context.push('/sales/discounts/new'),
                  icon: const Icon(Icons.add),
                  label: const Text('Créer une remise'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.warning, // [cite: 10]
                  ),
                ),
            ],
          ),
        );
      }
      return Column(
        children: [
          _buildStatistics(state),
          Expanded(
            child: _buildDiscountsList(state.discounts),
          ),
          if (state.hasNextPage) _buildPagination(),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildStatistics(DiscountsListLoaded state) {
    final activeDiscounts = state.discounts.where((d) => d.isActive).length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: AppColors.surfaceLight, // [cite: 15]
      child: Row(
        children: [
          _buildStatCard('Total', state.totalCount.toString(),
              Icons.local_offer, AppColors.primary), // [cite: 2]
          const SizedBox(width: 16),
          _buildStatCard('Actives', activeDiscounts.toString(),
              Icons.check_circle, AppColors.success), // [cite: 9]
          const SizedBox(width: 16),
          _buildStatCard('Inactives',
              (state.discounts.length - activeDiscounts).toString(), Icons.cancel, AppColors.textSecondary), // 
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary, // 
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscountsList(List<DiscountEntity> discounts) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.25,
      ),
      itemCount: discounts.length,
      itemBuilder: (context, index) {
        return _buildDiscountCard(discounts[index]);
      },
    );
  }

  Widget _buildDiscountCard(DiscountEntity discount) {
    final now = DateTime.now();
    final isExpired =
        discount.endDate != null && discount.endDate!.isBefore(now);
    final isUpcoming =
        discount.startDate != null && discount.startDate!.isAfter(now);
    final isActiveAndValid = discount.isActive && !isExpired && !isUpcoming;

    return Card(
      // CORRECTION : Le fond est maintenant blanc et les ombres/bordures conformes à GESTORE.
      elevation: 0,
      color: AppColors.surfaceLight, // [cite: 15]
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isActiveAndValid
              ? AppColors.success.withValues(alpha: 0.5) // [cite: 9]
              : AppColors.border, // [cite: 23]
          width: isActiveAndValid ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => context.push('/sales/discounts/${discount.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _getDiscountTypeColor(discount.discountType)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getDiscountTypeIcon(discount.discountType),
                      color: _getDiscountTypeColor(discount.discountType),
                      size: 24,
                    ),
                  ),
                  const Spacer(),
                  _buildStatusBadge(
                      discount, isActiveAndValid, isExpired, isUpcoming),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                discount.name,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary), // [cite: 17]
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _buildChip(discount.discountTypeDisplay,
                      _getDiscountTypeColor(discount.discountType)),
                  _buildChip(discount.scopeDisplay, AppColors.info), // [cite: 12]
                ],
              ),
              const Spacer(),
              _buildRestrictionsInfo(discount),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary), // 
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      discount.endDate != null
                          ? 'Jusqu\'au ${_dateFormat.format(discount.endDate!)}'
                          : 'Sans limite de date',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary, // 
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _confirmToggleActivation(discount),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: discount.isActive
                            ? AppColors.success // [cite: 9]
                            : AppColors.textSecondary, // 
                        side: BorderSide(
                          color: discount.isActive
                              ? AppColors.success // [cite: 9]
                              : AppColors.border, // [cite: 23]
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            discount.isActive
                                ? Icons.toggle_on
                                : Icons.toggle_off,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            discount.isActive ? 'Actif' : 'Inactif',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.error), // [cite: 11]
                    iconSize: 20,
                    onPressed: () => _confirmDelete(discount),
                    tooltip: 'Supprimer',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRestrictionsInfo(DiscountEntity discount) {
    final hasRestrictions = (discount.maxUses != null) ||
        (discount.targetCustomers?.isNotEmpty ?? false) ||
        (discount.targetArticles?.isNotEmpty ?? false) ||
        (discount.targetCategories?.isNotEmpty ?? false);
    if (!hasRestrictions) {
      return const SizedBox(height: 8);
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: [
          if (discount.maxUses != null)
            _buildRestrictionChip(Icons.repeat,
                '${discount.currentUses ?? 0}/${discount.maxUses} utilisés'),
          if (discount.targetCustomers?.isNotEmpty ?? false)
            _buildRestrictionChip(Icons.person, 'Clients ciblés'),
          if (discount.targetArticles?.isNotEmpty ?? false)
            _buildRestrictionChip(Icons.inventory_2, 'Articles ciblés'),
          if (discount.targetCategories?.isNotEmpty ?? false)
            _buildRestrictionChip(Icons.category, 'Catégories ciblées'),
        ],
      ),
    );
  }

  Widget _buildRestrictionChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.border.withValues(alpha: 0.6), // [cite: 23]
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary), // 
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary, // 
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(DiscountEntity discount, bool isActive,
      bool isExpired, bool isUpcoming) {
    String label;
    Color color;
    if (isExpired) {
      label = 'Expirée';
      color = AppColors.error; // [cite: 11]
    } else if (isUpcoming) {
      label = 'À venir';
      color = AppColors.info; // [cite: 12]
    } else if (isActive) {
      label = 'En cours';
      color = AppColors.success; // [cite: 9]
    } else {
      label = 'Inactive';
      color = AppColors.textSecondary; // 
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surfaceLight, // [cite: 15]
      child: Center(
        child: FilledButton.icon(
          onPressed: () {
            ref.read(discountsListProvider.notifier).loadNextPage();
          },
          icon: const Icon(Icons.expand_more),
          label: const Text('Charger plus'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.warning, // [cite: 10]
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );
  }

  IconData _getDiscountTypeIcon(String type) {
    switch (type) {
      case 'percentage':
        return Icons.percent;
      case 'fixed_amount':
        return Icons.attach_money;
      case 'buy_x_get_y':
        return Icons.redeem;
      case 'loyalty_points':
        return Icons.stars;
      default:
        return Icons.local_offer;
    }
  }

  Color _getDiscountTypeColor(String type) {
    switch (type) {
      case 'percentage':
        return AppColors.warning; // [cite: 10]
      case 'fixed_amount':
        return AppColors.success; // [cite: 9]
      case 'buy_x_get_y':
        return AppColors.secondary; // [cite: 5]
      case 'loyalty_points':
        return AppColors.customers; // [cite: 29]
      default:
        return AppColors.primary; // [cite: 2]
    }
  }

  Future<void> _confirmDelete(DiscountEntity discount) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer la remise "${discount.name}" ?\n\n'
              'Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error), // [cite: 11]
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      ref.read(discountsListProvider.notifier).deleteDiscount(discount.id);
    }
  }

  Future<void> _confirmToggleActivation(DiscountEntity discount) async {
    final action = discount.isActive ? 'désactiver' : 'activer';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            'Confirmer ${action == 'activer' ? 'l\'activation' : 'la désactivation'}'),
        content: Text('Voulez-vous $action la remise "${discount.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor:
              discount.isActive ? AppColors.textSecondary : AppColors.success, // [cite: 18, 9]
            ),
            child: Text(action == 'activer' ? 'Activer' : 'Désactiver'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      ref
          .read(discountsListProvider.notifier)
          .toggleActivation(discount.id, discount.isActive);
    }
  }
}