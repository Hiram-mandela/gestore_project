// ========================================
// lib/features/sales/presentation/screens/customers_screen.dart
// Écran Liste des Clients - Module Sales
// VERSION AMÉLIORÉE - DESIGN REFACTORING
//
// Changements stylistiques majeurs :
// - Application de la palette GESTORE (fonds, textes, accents).
// - Modernisation de la barre de recherche avec un style clair et un focus visible.
// - Amélioration du design des cartes clients pour une meilleure lisibilité et hiérarchie.
// - Harmonisation des couleurs sur les statistiques, badges et icônes.
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../domain/entities/customer_entity.dart';
import '../providers/customers_provider.dart';
import '../providers/customers_state.dart';

/// Écran de liste des clients
class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(customersProvider.notifier).loadCustomers();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      final state = ref.read(customersProvider);
      if (state is CustomersLoaded && state.hasMore && !state.isLoadingMore) {
        ref.read(customersProvider.notifier).loadMore();
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
    final state = ref.watch(customersProvider);

    // Le Scaffold est maintenant géré par le layout parent (AppLayout),
    // donc nous retournons directement le contenu de la page.
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          // Header avec recherche et actions
          _buildHeader(state),
          // Statistiques
          if (state is CustomersLoaded) _buildStats(state),
          // Liste des clients
          Expanded(
            child: _buildBody(state),
          ),
        ],
      ),
    );
  }

  /// Header avec recherche et bouton nouveau client
  Widget _buildHeader(CustomersState state) {
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
                hintText: 'Rechercher un client (nom, téléphone, email)...',
                hintStyle: const TextStyle(color: AppColors.textTertiary),
                prefixIcon:
                const Icon(Icons.search, color: AppColors.textSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear,
                      color: AppColors.textSecondary),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(customersProvider.notifier).search('');
                    setState(() {});
                  },
                )
                    : null,
                filled: true,
                fillColor: AppColors.backgroundLight,
                contentPadding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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
                  borderSide:
                  const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              onChanged: (value) {
                ref.read(customersProvider.notifier).search(value);
                setState(() {});
              },
            ),
          ),
          const SizedBox(width: 16),
          // Filtres
          _buildFilterButton(state),
          const SizedBox(width: 16),
          // Bouton Nouveau client
          FilledButton.icon(
            onPressed: () {
              context.push('/sales/customers/new');
            },
            icon: const Icon(Icons.person_add, size: 20),
            label: const Text('Nouveau client'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Bouton de filtres
  Widget _buildFilterButton(CustomersState state) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.filter_list, color: AppColors.textSecondary),
      tooltip: 'Filtrer',
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'all',
          child: Text('Tous les clients'),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'individual',
          child: Text('Particuliers'),
        ),
        const PopupMenuItem(
          value: 'company',
          child: Text('Entreprises'),
        ),
        const PopupMenuItem(
          value: 'professional',
          child: Text('Professionnels'),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'active',
          child: Text('Actifs uniquement'),
        ),
        const PopupMenuItem(
          value: 'inactive',
          child: Text('Inactifs uniquement'),
        ),
      ],
      onSelected: (value) {
        ref.read(customersProvider.notifier).filter(value);
      },
    );
  }

  /// Statistiques rapides
  Widget _buildStats(CustomersLoaded state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      color: AppColors.surfaceLight,
      child: Row(
        children: [
          _buildStatCard(
            icon: Icons.people,
            label: 'Total clients',
            value: state.totalCount.toString(),
            color: AppColors.primary,
          ),
          const SizedBox(width: 20),
          _buildStatCard(
            icon: Icons.person,
            label: 'Particuliers',
            value: state.individuals.toString(),
            color: AppColors.info,
          ),
          const SizedBox(width: 20),
          _buildStatCard(
            icon: Icons.business,
            label: 'Entreprises',
            value: state.companies.toString(),
            color: AppColors.success,
          ),
          const SizedBox(width: 20),
          _buildStatCard(
            icon: Icons.card_giftcard,
            label: 'Fidélité active',
            value: state.loyaltyMembers.toString(),
            color: AppColors.warning,
          ),
        ],
      ),
    );
  }

  /// Carte de statistique
  Widget _buildStatCard({
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Corps de la page selon l'état
  Widget _buildBody(CustomersState state) {
    if (state is CustomersLoading) {
      return _buildLoadingState();
    } else if (state is CustomersError) {
      return _buildErrorState(state);
    } else if (state is CustomersLoaded) {
      if (state.customers.isEmpty) {
        return _buildEmptyState();
      }
      return _buildCustomersList(state);
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
            'Chargement des clients...',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  /// État d'erreur
  Widget _buildErrorState(CustomersError state) {
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
              ref.read(customersProvider.notifier).loadCustomers();
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
          Icon(Icons.people_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'Aucun client trouvé',
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
                : 'Créez votre premier client pour commencer',
            style: const TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (_searchController.text.isEmpty)
            FilledButton.icon(
              onPressed: () {
                context.push('/sales/customers/new');
              },
              icon: const Icon(Icons.person_add),
              label: const Text('Créer un client'),
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            ),
        ],
      ),
    );
  }

  /// Liste des clients
  Widget _buildCustomersList(CustomersLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(customersProvider.notifier).refresh();
      },
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(24),
        itemCount: state.customers.length + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          if (index >= state.customers.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }
          final customer = state.customers[index];
          return _buildCustomerCard(customer);
        },
      ),
    );
  }

  /// Carte d'un client
  Widget _buildCustomerCard(CustomerEntity customer) {
    return Card(
      elevation: 0,
      color: AppColors.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: () {
          context.push('/sales/customers/${customer.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              _buildAvatar(customer),
              const SizedBox(width: 16),
              // Informations
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom et type
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            customer.fullName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        _buildCustomerTypeBadge(customer.customerType),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Code client
                    Text(
                      customer.customerCode,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Contact
                    Row(
                      children: [
                        if (customer.phone != null) ...[
                          const Icon(Icons.phone,
                              size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            customer.phone!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                        if (customer.email != null) ...[
                          const Icon(Icons.email,
                              size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              customer.email!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Statistiques
                    Row(
                      children: [
                        _buildStatPill(
                          icon: Icons.shopping_bag,
                          label: '${customer.purchaseCount} achats',
                          color: AppColors.info,
                        ),
                        const SizedBox(width: 8),
                        _buildStatPill(
                          icon: Icons.attach_money,
                          label:
                          '${customer.totalPurchases.toStringAsFixed(0)} FCFA',
                          color: AppColors.success,
                        ),
                        if (customer.loyaltyPoints > 0) ...[
                          const SizedBox(width: 8),
                          _buildStatPill(
                            icon: Icons.stars,
                            label: '${customer.loyaltyPoints} pts',
                            color: AppColors.warning,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Actions
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Statut actif/inactif
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: customer.isActive
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.border.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      customer.isActive ? 'Actif' : 'Inactif',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: customer.isActive
                            ? AppColors.success
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Menu actions
                  PopupMenuButton<String>(
                    icon:
                    const Icon(Icons.more_vert, color: AppColors.textSecondary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility, size: 18),
                            SizedBox(width: 8),
                            Text('Voir détails'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Modifier'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'history',
                        child: Row(
                          children: [
                            Icon(Icons.history, size: 18),
                            SizedBox(width: 8),
                            Text('Historique'),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: customer.isActive ? 'deactivate' : 'activate',
                        child: Row(
                          children: [
                            Icon(
                              customer.isActive
                                  ? Icons.block
                                  : Icons.check_circle,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              customer.isActive ? 'Désactiver' : 'Activer',
                            ),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) => _handleAction(customer, value),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Avatar du client
  Widget _buildAvatar(CustomerEntity customer) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: customer.customerType == 'company'
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          customer.fullName.substring(0, 1).toUpperCase(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: customer.customerType == 'company'
                ? AppColors.success
                : AppColors.primary,
          ),
        ),
      ),
    );
  }

  /// Badge type de client
  Widget _buildCustomerTypeBadge(String type) {
    IconData icon;
    Color color;
    String label;
    switch (type) {
      case 'company':
        icon = Icons.business;
        color = AppColors.success;
        label = 'Entreprise';
        break;
      case 'professional':
        icon = Icons.work;
        color = AppColors.warning;
        label = 'Pro';
        break;
      default:
        icon = Icons.person;
        color = AppColors.info;
        label = 'Particulier';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Pill de statistique
  Widget _buildStatPill({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Gestion des actions
  void _handleAction(CustomerEntity customer, String action) {
    switch (action) {
      case 'view':
        context.push('/sales/customers/${customer.id}');
        break;
      case 'edit':
        context.push('/sales/customers/${customer.id}/edit');
        break;
      case 'history':
        context.push('/sales/customers/${customer.id}/history');
        break;
      case 'activate':
      case 'deactivate':
        _toggleActiveStatus(customer);
        break;
    }
  }

  /// Activer/désactiver un client
  void _toggleActiveStatus(CustomerEntity customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          customer.isActive ? 'Désactiver le client' : 'Activer le client',
        ),
        content: Text(
          customer.isActive
              ? 'Le client ne pourra plus effectuer d\'achats.'
              : 'Le client pourra à nouveau effectuer des achats.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(customersProvider.notifier)
                  .toggleActiveStatus(customer.id);
            },
            style: FilledButton.styleFrom(
              backgroundColor:
              customer.isActive ? AppColors.error : AppColors.success,
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }
}