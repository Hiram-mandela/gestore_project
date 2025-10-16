// ========================================
// lib/features/inventory/presentation/screens/brands_list_screen.dart
// Écran de la liste des marques
// VERSION 2.2 - Correction du style de la barre de recherche
// --
// Changements :
// - Ajout des styles pour le texte de saisie et le texte d'aide (hint)
//   dans la barre de recherche pour garantir leur visibilité.
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/constants/app_colors.dart';
import '../providers/brands_crud_provider.dart';
import '../providers/brand_state.dart';
import '../../domain/entities/brand_entity.dart';

/// Écran de la liste des marques
class BrandsListScreen extends ConsumerStatefulWidget {
  const BrandsListScreen({super.key});

  @override
  ConsumerState<BrandsListScreen> createState() => _BrandsListScreenState();
}

class _BrandsListScreenState extends ConsumerState<BrandsListScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Charger les marques au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(brandsListProvider.notifier).loadBrands(isActive: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(brandsListProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          // Header
          _buildHeader(context, state),
          // Corps
          Expanded(
            child: _buildBody(state),
          ),
        ],
      ),
      // Bouton flottant pour créer
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/inventory/brands/new'),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nouvelle marque', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Construit l'en-tête
  Widget _buildHeader(BuildContext context, BrandState state) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        boxShadow: [AppColors.subtleShadow()],
      ),
      padding: const EdgeInsets.all(24).copyWith(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          // Titre
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Marques',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _buildSubtitle(state),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Bouton refresh
              IconButton(
                onPressed: () {
                  ref.read(brandsListProvider.notifier).refresh();
                },
                icon: const Icon(Icons.refresh, color: AppColors.primary),
                tooltip: 'Actualiser',
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Barre de recherche
          TextField(
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Rechercher une marque...',
              hintStyle: const TextStyle(color: AppColors.textTertiary),
              prefixIcon: const Icon(Icons.search, color: AppColors.textTertiary),
              filled: true,
              fillColor: AppColors.backgroundLight,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
        ],
      ),
    );
  }

  /// Construit le sous-titre
  String _buildSubtitle(BrandState state) {
    if (state is BrandLoaded) {
      return '${state.brands.length} marques enregistrées';
    }
    return 'Gestion des marques d\'articles';
  }

  /// Construit le corps
  Widget _buildBody(BrandState state) {
    if (state is BrandLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (state is BrandError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              const Text(
                'Une erreur est survenue',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
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
                  ref.read(brandsListProvider.notifier).refresh();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (state is BrandLoaded) {
      // Filtrer par recherche
      final filteredBrands = _searchQuery.isEmpty
          ? state.brands
          : state.brands.where((brand) {
        return brand.name.toLowerCase().contains(_searchQuery) ||
            (brand.description?.toLowerCase().contains(_searchQuery) ?? false);
      }).toList();

      if (filteredBrands.isEmpty) {
        return _buildEmptyState();
      }
      return RefreshIndicator(
        onRefresh: () async {
          await ref.read(brandsListProvider.notifier).refresh();
        },
        color: AppColors.primary,
        child: GridView.builder(
          padding: const EdgeInsets.all(24),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 350,
            childAspectRatio: 1.25,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
          ),
          itemCount: filteredBrands.length,
          itemBuilder: (context, index) {
            return _buildBrandCard(context, filteredBrands[index]);
          },
        ),
      );
    }
    return const SizedBox();
  }

  /// Construit une carte marque
  Widget _buildBrandCard(BuildContext context, BrandEntity brand) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [AppColors.cardShadow()],
      ),
      child: InkWell(
        onTap: () {
          context.push('/inventory/brands/${brand.id}/edit');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec logo
              Row(
                children: [
                  // Logo ou initiale
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: brand.logoUrl != null ? Colors.transparent : AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: brand.logoUrl != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        brand.logoUrl!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => _buildInitial(brand.name),
                      ),
                    )
                        : _buildInitial(brand.name),
                  ),
                  const Spacer(),
                  // Badge statut
                  if (!brand.isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Inactif',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.warning,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              // Nom
              Text(
                brand.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (brand.description != null && brand.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  brand.description!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const Spacer(),
              // Site web
              if (brand.website != null && brand.website!.isNotEmpty)
                Row(
                  children: [
                    const Icon(Icons.language, size: 14, color: AppColors.textTertiary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        brand.website!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

  /// Construit l'initiale de la marque
  Widget _buildInitial(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'M',
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  /// État vide
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.branding_watermark_outlined,
            size: 80,
            color: AppColors.border,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? 'Aucune marque enregistrée' : 'Aucun résultat',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Créez votre première marque pour commencer'
                : 'Essayez avec un autre mot-clé',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          if (_searchQuery.isEmpty) ...[
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.push('/inventory/brands/new'),
              icon: const Icon(Icons.add),
              label: const Text('Créer une marque'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}