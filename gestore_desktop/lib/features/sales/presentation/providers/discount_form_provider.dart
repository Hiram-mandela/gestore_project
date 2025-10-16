// ========================================
// lib/features/sales/presentation/providers/discount_form_provider.dart
// Provider pour le formulaire de remise/promotion
// ========================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../../../config/dependencies.dart';
import '../../domain/usecases/create_discount_usecase.dart';
import '../../domain/usecases/get_active_discounts_usecase.dart';
import '../../domain/usecases/update_discount_usecase.dart';
import '../../domain/usecases/calculate_discount_usecase.dart';
import 'discount_form_state.dart';

/// Provider pour le formulaire de remise
final discountFormProvider =
StateNotifierProvider.autoDispose<DiscountFormNotifier, DiscountFormState>(
      (ref) {
    return DiscountFormNotifier(
      getDiscountByIdUseCase: getIt<GetDiscountByIdUseCase>(),
      createDiscountUseCase: getIt<CreateDiscountUseCase>(),
      updateDiscountUseCase: getIt<UpdateDiscountUseCase>(),
      calculateDiscountUseCase: getIt<CalculateDiscountUseCase>(),
      logger: getIt<Logger>(),
    );
  },
);

/// Notifier pour la gestion du formulaire
class DiscountFormNotifier extends StateNotifier<DiscountFormState> {
  final GetDiscountByIdUseCase getDiscountByIdUseCase;
  final CreateDiscountUseCase createDiscountUseCase;
  final UpdateDiscountUseCase updateDiscountUseCase;
  final CalculateDiscountUseCase calculateDiscountUseCase;
  final Logger logger;

  DiscountFormNotifier({
    required this.getDiscountByIdUseCase,
    required this.createDiscountUseCase,
    required this.updateDiscountUseCase,
    required this.calculateDiscountUseCase,
    required this.logger,
  }) : super(const DiscountFormInitial());

  /// Charge une remise pour édition
  Future<void> loadDiscountForEdit(String id) async {
    state = const DiscountFormLoading();
    logger.d('📝 Chargement remise $id pour édition');

    final (discount, error) = await getDiscountByIdUseCase(id);

    if (error != null) {
      logger.e('❌ Erreur chargement: $error');
      state = DiscountFormError(error);
      return;
    }

    if (discount == null) {
      state = const DiscountFormError('Remise non trouvée');
      return;
    }

    logger.i('✅ Remise chargée pour édition');
    state = DiscountFormLoadedForEdit(discount);
  }

  /// Crée une nouvelle remise
  Future<void> createDiscount(Map<String, dynamic> data) async {
    state = const DiscountFormSubmitting();
    logger.d('💾 Création remise');
    logger.d('Data: $data');

    final (discount, error) = await createDiscountUseCase(data);

    if (error != null) {
      logger.e('❌ Erreur création: $error');
      state = DiscountFormError(error);
      return;
    }

    if (discount == null) {
      state = const DiscountFormError('Erreur lors de la création');
      return;
    }

    logger.i('✅ Remise créée: ${discount.name}');
    state = DiscountFormSuccess(
      message: 'Remise créée avec succès',
      discount: discount,
    );
  }

  /// Met à jour une remise existante
  Future<void> updateDiscount(String id, Map<String, dynamic> data) async {
    state = const DiscountFormSubmitting();
    logger.d('💾 Modification remise $id');
    logger.d('Data: $data');

    final (discount, error) = await updateDiscountUseCase(id, data);

    if (error != null) {
      logger.e('❌ Erreur modification: $error');
      state = DiscountFormError(error);
      return;
    }

    if (discount == null) {
      state = const DiscountFormError('Erreur lors de la modification');
      return;
    }

    logger.i('✅ Remise modifiée: ${discount.name}');
    state = DiscountFormSuccess(
      message: 'Remise modifiée avec succès',
      discount: discount,
    );
  }

  /// Simule/calcule une remise
  Future<void> calculateDiscount(
      String discountId,
      Map<String, dynamic> params,
      ) async {
    state = const DiscountFormCalculating();
    logger.d('🧮 Calcul remise $discountId');
    logger.d('Params: $params');

    final (result, error) = await calculateDiscountUseCase(discountId, params);

    if (error != null) {
      logger.e('❌ Erreur calcul: $error');
      state = DiscountFormError(error);
      return;
    }

    if (result == null) {
      state = const DiscountFormError('Erreur lors du calcul');
      return;
    }

    logger.i('✅ Remise calculée');
    state = DiscountFormCalculated(result);
  }

  /// Réinitialise le formulaire
  void resetForm() {
    logger.d('🔄 Réinitialisation formulaire');
    state = const DiscountFormInitial();
  }
}