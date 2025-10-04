// ========================================
// lib/features/inventory/presentation/providers/brands_crud_provider.dart
// Provider Riverpod pour le CRUD des marques
// ========================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../../../config/dependencies.dart';
import '../../domain/entities/brand_entity.dart';
import '../../domain/usecases/get_brands_usecase.dart';
import '../../domain/usecases/brand_usecases.dart';
import 'brand_state.dart';

// ==================== PROVIDER LISTE MARQUES ====================

/// Provider pour la liste des marques
final brandsListProvider = StateNotifierProvider<BrandsListNotifier, BrandState>((ref) {
  return BrandsListNotifier(
    getBrandsUseCase: getIt<GetBrandsUseCase>(),
    logger: getIt<Logger>(),
  );
});

/// Notifier pour gérer la liste des marques
class BrandsListNotifier extends StateNotifier<BrandState> {
  final GetBrandsUseCase getBrandsUseCase;
  final Logger logger;

  BrandsListNotifier({
    required this.getBrandsUseCase,
    required this.logger,
  }) : super(const BrandInitial());

  /// Charge toutes les marques
  Future<void> loadBrands({bool? isActive}) async {
    try {
      logger.i('🏷️ Chargement marques...');
      state = const BrandLoading();

      final params = GetBrandsParams(isActive: isActive);
      final (brands, error) = await getBrandsUseCase(params);

      if (error != null) {
        logger.e('❌ Erreur chargement marques: $error');
        state = BrandError(message: error);
        return;
      }

      if (brands != null) {
        logger.i('✅ ${brands.length} marques chargées');
        state = BrandLoaded(brands: brands);
      }
    } catch (e) {
      logger.e('❌ Exception chargement marques: $e');
      state = const BrandError(message: 'Une erreur est survenue');
    }
  }

  /// Recharge les marques
  Future<void> refresh() async {
    await loadBrands(isActive: true);
  }
}

// ==================== PROVIDER FORMULAIRE MARQUE ====================

/// Provider pour le formulaire marque
final brandFormProvider = StateNotifierProvider.family<
    BrandFormNotifier,
    BrandFormState,
    (BrandFormMode, String?)>((ref, params) {
  final mode = params.$1;
  final brandId = params.$2;

  return BrandFormNotifier(
    mode: mode,
    brandId: brandId,
    createBrandUseCase: getIt<CreateBrandUseCase>(),
    updateBrandUseCase: getIt<UpdateBrandUseCase>(),
    deleteBrandUseCase: getIt<DeleteBrandUseCase>(),
    getBrandByIdUseCase: getIt<GetBrandByIdUseCase>(),
    logger: getIt<Logger>(),
  );
});

/// Notifier pour gérer le formulaire marque
class BrandFormNotifier extends StateNotifier<BrandFormState> {
  final BrandFormMode mode;
  final String? brandId;
  final CreateBrandUseCase createBrandUseCase;
  final UpdateBrandUseCase updateBrandUseCase;
  final DeleteBrandUseCase deleteBrandUseCase;
  final GetBrandByIdUseCase getBrandByIdUseCase;
  final Logger logger;

  BrandFormNotifier({
    required this.mode,
    this.brandId,
    required this.createBrandUseCase,
    required this.updateBrandUseCase,
    required this.deleteBrandUseCase,
    required this.getBrandByIdUseCase,
    required this.logger,
  }) : super(BrandFormInitial(mode: mode, brandId: brandId)) {
    _initialize();
  }

  /// Initialise le formulaire
  Future<void> _initialize() async {
    if (mode == BrandFormMode.edit && brandId != null) {
      await _loadBrandForEdit();
    } else {
      state = BrandFormReady(
        mode: mode,
        formData: const BrandFormData(),
      );
      logger.d('📝 Formulaire marque prêt pour création');
    }
  }

  /// Charge la marque pour édition
  Future<void> _loadBrandForEdit() async {
    try {
      logger.d('📝 Chargement marque pour édition: $brandId');
      state = BrandFormLoading(brandId: brandId!);

      final params = GetBrandByIdParams(brandId: brandId!);
      final (brand, error) = await getBrandByIdUseCase(params);

      if (error != null) {
        logger.e('❌ Erreur chargement: $error');
        state = BrandFormError(message: error, mode: mode);
        return;
      }

      if (brand != null) {
        state = BrandFormReady(
          mode: mode,
          brandId: brandId,
          formData: BrandFormData.fromEntity(brand),
        );
        logger.i('✅ Marque chargée: ${brand.name}');
      }
    } catch (e) {
      logger.e('❌ Exception: $e');
      state = BrandFormError(
        message: 'Erreur lors du chargement',
        mode: mode,
      );
    }
  }

  /// Met à jour un champ du formulaire
  void updateField(String field, dynamic value) {
    final currentState = state;
    if (currentState is! BrandFormReady) return;

    BrandFormData updatedData;

    switch (field) {
      case 'name':
        updatedData = currentState.formData.copyWith(name: value as String);
        break;
      case 'description':
        updatedData = currentState.formData.copyWith(description: value as String);
        break;
      case 'logoPath':
        updatedData = currentState.formData.copyWith(
          logoPath: value as String?,
          clearLogo: value == null,
        );
        break;
      case 'website':
        updatedData = currentState.formData.copyWith(website: value as String);
        break;
      case 'isActive':
        updatedData = currentState.formData.copyWith(isActive: value as bool);
        break;
      default:
        return;
    }

    // Validation en temps réel
    final errors = _validateFormData(updatedData);

    state = currentState.copyWith(
      formData: updatedData,
      errors: errors,
    );
  }

  /// Valide les données du formulaire
  Map<String, String> _validateFormData(BrandFormData data) {
    final errors = <String, String>{};

    if (data.name.trim().isEmpty) {
      errors['name'] = 'Le nom est requis';
    } else if (data.name.trim().length < 2) {
      errors['name'] = 'Le nom doit contenir au moins 2 caractères';
    }

    if (data.website.isNotEmpty && !_isValidUrl(data.website)) {
      errors['website'] = 'URL du site web invalide';
    }

    return errors;
  }

  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// Soumet le formulaire (création ou édition)
  Future<void> submit() async {
    final currentState = state;
    if (currentState is! BrandFormReady) return;

    // Validation finale
    final errors = _validateFormData(currentState.formData);
    if (errors.isNotEmpty) {
      state = currentState.copyWith(errors: errors);
      return;
    }

    state = BrandFormSubmitting(mode: mode);

    try {
      if (mode == BrandFormMode.create) {
        await _createBrand(currentState.formData);
      } else {
        await _updateBrand(currentState.formData);
      }
    } catch (e) {
      logger.e('❌ Erreur soumission: $e');
      state = BrandFormError(
        message: 'Une erreur est survenue',
        mode: mode,
      );
    }
  }

  /// Crée une nouvelle marque
  Future<void> _createBrand(BrandFormData data) async {
    logger.d('📝 Création marque "${data.name}"');

    final params = CreateBrandParams(
      name: data.name,
      description: data.description,
      logoPath: data.logoPath,
      website: data.website,
      isActive: data.isActive,
    );

    final (brand, error) = await createBrandUseCase(params);

    if (error != null) {
      logger.e('❌ Erreur création: $error');
      state = BrandFormError(message: error, mode: mode);
      return;
    }

    if (brand != null) {
      logger.i('✅ Marque créée: ${brand.name}');
      state = BrandFormSuccess(brand: brand, mode: mode);
    }
  }

  /// Met à jour une marque
  Future<void> _updateBrand(BrandFormData data) async {
    if (brandId == null) return;

    logger.d('📝 Mise à jour marque $brandId');

    final params = UpdateBrandParams(
      id: brandId!,
      name: data.name,
      description: data.description,
      logoPath: data.logoPath,
      website: data.website,
      isActive: data.isActive,
    );

    final (brand, error) = await updateBrandUseCase(params);

    if (error != null) {
      logger.e('❌ Erreur mise à jour: $error');
      state = BrandFormError(message: error, mode: mode);
      return;
    }

    if (brand != null) {
      logger.i('✅ Marque mise à jour: ${brand.name}');
      state = BrandFormSuccess(brand: brand, mode: mode);
    }
  }

  /// Supprime la marque (mode édition uniquement)
  Future<void> delete() async {
    if (brandId == null || mode != BrandFormMode.edit) return;

    logger.d('🗑️ Suppression marque $brandId');

    state = BrandFormSubmitting(mode: mode);

    final params = DeleteBrandParams(brandId: brandId!);
    final (_, error) = await deleteBrandUseCase(params);

    if (error != null) {
      logger.e('❌ Erreur suppression: $error');
      state = BrandFormError(message: error, mode: mode);
      return;
    }

    logger.i('✅ Marque supprimée');
    state = BrandFormSuccess(
      brand: BrandEntity(
        id: brandId!,
        name: 'DELETED',
        description: '',
        isActive: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      mode: mode,
    );
  }
}