// ========================================
// lib/features/inventory/presentation/providers/categories_brands_providers.dart
// MISE À JOUR - Ajout du provider Units
// ========================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../../../config/dependencies.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/brand_entity.dart';
import '../../domain/entities/unit_of_measure_entity.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_brands_usecase.dart';
import '../../domain/usecases/unit_usecases.dart';

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
  }) : super(CategoriesInitial()) {
    loadCategories();
  }

  /// Charge les catégories
  Future<void> loadCategories({bool? isActive}) async {
    try {
      logger.d('📂 Chargement catégories...');
      state = CategoriesLoading();

      final params = GetCategoriesParams(isActive: isActive);
      final result = await getCategoriesUseCase(params);

      final error = result.$2;
      final categories = result.$1;

      if (error != null || categories == null) {
        logger.e('❌ Erreur: $error');
        state = CategoriesError(error ?? 'Erreur inconnue');
        return;
      }

      logger.i('✅ ${categories.length} catégories chargées');
      state = CategoriesLoaded(categories);
    } catch (e) {
      logger.e('❌ Exception: $e');
      state = CategoriesError(e.toString());
    }
  }

  /// Rafraîchit les catégories
  Future<void> refresh() => loadCategories();
}

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
final brandsProvider =
StateNotifierProvider<BrandsNotifier, BrandsState>((ref) {
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
  }) : super(BrandsInitial()) {
    loadBrands();
  }

  /// Charge les marques
  Future<void> loadBrands({bool? isActive}) async {
    try {
      logger.d('🏷️ Chargement marques...');
      state = BrandsLoading();

      final params = GetBrandsParams(isActive: isActive);
      final result = await getBrandsUseCase(params);

      final error = result.$2;
      final brands = result.$1;

      if (error != null || brands == null) {
        logger.e('❌ Erreur: $error');
        state = BrandsError(error ?? 'Erreur inconnue');
        return;
      }

      logger.i('✅ ${brands.length} marques chargées');
      state = BrandsLoaded(brands);
    } catch (e) {
      logger.e('❌ Exception: $e');
      state = BrandsError(e.toString());
    }
  }

  /// Rafraîchit les marques
  Future<void> refresh() => loadBrands();
}

// ==================== UNITS OF MEASURE (NOUVEAU) ====================

/// État pour les unités de mesure
sealed class UnitsState {}

class UnitsInitial extends UnitsState {}

class UnitsLoading extends UnitsState {}

class UnitsLoaded extends UnitsState {
  final List<UnitOfMeasureEntity> units;
  UnitsLoaded(this.units);
}

class UnitsError extends UnitsState {
  final String message;
  UnitsError(this.message);
}

/// Provider pour les unités de mesure
final unitsProvider =
StateNotifierProvider<UnitsNotifier, UnitsState>((ref) {
  return UnitsNotifier(
    getUnitsUseCase: getIt<GetUnitsUseCase>(),
    logger: getIt<Logger>(),
  );
});

/// Notifier pour les unités de mesure
class UnitsNotifier extends StateNotifier<UnitsState> {
  final GetUnitsUseCase getUnitsUseCase;
  final Logger logger;

  UnitsNotifier({
    required this.getUnitsUseCase,
    required this.logger,
  }) : super(UnitsInitial()) {
    loadUnits();
  }

  /// Charge les unités de mesure
  Future<void> loadUnits({bool? isActive}) async {
    try {
      logger.d('📏 Chargement unités de mesure...');
      state = UnitsLoading();

      final params = GetUnitsParams(isActive: isActive);
      final result = await getUnitsUseCase(params);

      final error = result.$2;
      final units = result.$1;

      if (error != null || units == null) {
        logger.e('❌ Erreur: $error');
        state = UnitsError(error ?? 'Erreur inconnue');
        return;
      }

      logger.i('✅ ${units.length} unités chargées');
      state = UnitsLoaded(units);
    } catch (e) {
      logger.e('❌ Exception: $e');
      state = UnitsError(e.toString());
    }
  }

  /// Rafraîchit les unités
  Future<void> refresh() => loadUnits();
}