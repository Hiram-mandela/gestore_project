// ========================================
// lib/features/inventory/presentation/screens/brands_list_screen.dart
// Écran de la liste des marques
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
      backgroundColor: Colors.grey[50],
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
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle marque'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  /// Construit l'en-tête
  Widget _buildHeader(BuildContext context, BrandState state) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _buildSubtitle(state),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
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
                icon: const Icon(Icons.refresh),
                tooltip: 'Actualiser',
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Barre de recherche
          TextField(
            decoration: InputDecoration(
              hintText: 'Rechercher une marque...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey[100],
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
        child: CircularProgressIndicator(),
      );
    }

    if (state is BrandError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Erreur',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(brandsListProvider.notifier).refresh();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
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
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 300,
            childAspectRatio: 1.2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
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
                      color: brand.logoUrl != null
                          ? Colors.white
                          : AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 1,
                      ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Inactif',
                        style: TextStyle(fontSize: 11),
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
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              if (brand.description != null && brand.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  brand.description!,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
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
                    Icon(
                      Icons.language,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        brand.website!,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
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
        style: TextStyle(
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
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? 'Aucune marque' : 'Aucun résultat',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Créez votre première marque pour commencer'
                : 'Essayez une autre recherche',
            style: TextStyle(color: Colors.grey[500]),
          ),
          if (_searchQuery.isEmpty) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/inventory/brands/new'),
              icon: const Icon(Icons.add),
              label: const Text('Créer une marque'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }
}