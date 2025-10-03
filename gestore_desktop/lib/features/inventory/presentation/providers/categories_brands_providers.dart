// ========================================
// lib/features/inventory/presentation/providers/categories_brands_providers.dart
// Providers pour catégories et marques
// ========================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../../../config/dependencies.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/brand_entity.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_brands_usecase.dart';

// ==================== CATEGORIES ====================

/// État pour les catégories
sealed class CategoriesState {}

class CategoriesInitial extends CategoriesState {}

class CategoriesLoading extends CategoriesState {}

class CategoriesLoaded extends CategoriesState {
  final List<CategoryEntity> categories;
  CategoriesLoaded(this.categories);
}

class CategoriesError extends CategoriesState {
  final String message;
  CategoriesError(this.message);
}

/// Provider pour les catégories
final categoriesProvider =
StateNotifierProvider<CategoriesNotifier, CategoriesState>((ref) {
  return CategoriesNotifier(
    getCategoriesUseCase: getIt<GetCategoriesUseCase>(),
    logger: getIt<Logger>(),
  );
});

/// Notifier pour les catégories
class CategoriesNotifier extends StateNotifier<CategoriesState> {
  final GetCategoriesUseCase getCategoriesUseCase;
  final Logger logger;

  CategoriesNotifier({
    required this.getCategoriesUseCase,
    required this.logger,
  }) : super(CategoriesInitial());

  /// Charge les catégories
  Future<void> loadCategories({bool? isActive}) async {
    logger.d('📂 Chargement catégories...');
    state = CategoriesLoading();

    try {
      final params = GetCategoriesParams(isActive: isActive);
      final (categories, error) = await getCategoriesUseCase(params);

      if (error != null) {
        logger.e('❌ Erreur chargement catégories: $error');
        state = CategoriesError(error);
        return;
      }

      if (categories != null) {
        logger.i('✅ ${categories.length} catégories chargées');
        state = CategoriesLoaded(categories);
      }
    } catch (e) {
      logger.e('❌ Exception catégories: $e');
      state = CategoriesError('Une erreur est survenue');
    }
  }
}

/// Provider pour obtenir la liste des catégories actives
final activeCategoriesProvider = Provider<List<CategoryEntity>>((ref) {
  final categoriesState = ref.watch(categoriesProvider);
  if (categoriesState is CategoriesLoaded) {
    return categoriesState.categories;
  }
  return [];
});

// ==================== BRANDS ====================

/// État pour les marques
sealed class BrandsState {}

class BrandsInitial extends BrandsState {}

class BrandsLoading extends BrandsState {}

class BrandsLoaded extends BrandsState {
  final List<BrandEntity> brands;
  BrandsLoaded(this.brands);
}

class BrandsError extends BrandsState {
  final String message;
  BrandsError(this.message);
}

/// Provider pour les marques
final brandsProvider = StateNotifierProvider<BrandsNotifier, BrandsState>((ref) {
  return BrandsNotifier(
    getBrandsUseCase: getIt<GetBrandsUseCase>(),
    logger: getIt<Logger>(),
  );
});

/// Notifier pour les marques
class BrandsNotifier extends StateNotifier<BrandsState> {
  final GetBrandsUseCase getBrandsUseCase;
  final Logger logger;

  BrandsNotifier({
    required this.getBrandsUseCase,
    required this.logger,
  }) : super(BrandsInitial());

  /// Charge les marques
  Future<void> loadBrands({bool? isActive}) async {
    logger.d('🏷️ Chargement marques...');
    state = BrandsLoading();

    try {
      final params = GetBrandsParams(isActive: isActive);
      final (brands, error) = await getBrandsUseCase(params);

      if (error != null) {
        logger.e('❌ Erreur chargement marques: $error');
        state = BrandsError(error);
        return;
      }

      if (brands != null) {
        logger.i('✅ ${brands.length} marques chargées');
        state = BrandsLoaded(brands);
      }
    } catch (e) {
      logger.e('❌ Exception marques: $e');
      state = BrandsError('Une erreur est survenue');
    }
  }
}

/// Provider pour obtenir la liste des marques actives
final activeBrandsProvider = Provider<List<BrandEntity>>((ref) {
  final brandsState = ref.watch(brandsProvider);
  if (brandsState is BrandsLoaded) {
    return brandsState.brands;
  }
  return [];
});