// ========================================
// lib/features/sales/presentation/providers/payment_method_form_provider.dart
// Provider pour le formulaire de moyen de paiement
// ========================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../../../config/dependencies.dart';
import '../../domain/usecases/payment_method_usecases.dart';
import '../../domain/usecases/create_payment_method_usecase.dart';
import '../../domain/usecases/update_payment_method_usecase.dart';
import 'payment_method_form_state.dart';

/// Provider pour le formulaire de moyen de paiement
final paymentMethodFormProvider =
StateNotifierProvider.autoDispose<PaymentMethodFormNotifier, PaymentMethodFormState>(
      (ref) {
    return PaymentMethodFormNotifier(
      getPaymentMethodByIdUseCase: getIt<GetPaymentMethodByIdUseCase>(),
      createPaymentMethodUseCase: getIt<CreatePaymentMethodUseCase>(),
      updatePaymentMethodUseCase: getIt<UpdatePaymentMethodUseCase>(),
      logger: getIt<Logger>(),
    );
  },
);

/// Notifier pour la gestion du formulaire
class PaymentMethodFormNotifier extends StateNotifier<PaymentMethodFormState> {
  final GetPaymentMethodByIdUseCase getPaymentMethodByIdUseCase;
  final CreatePaymentMethodUseCase createPaymentMethodUseCase;
  final UpdatePaymentMethodUseCase updatePaymentMethodUseCase;
  final Logger logger;

  PaymentMethodFormNotifier({
    required this.getPaymentMethodByIdUseCase,
    required this.createPaymentMethodUseCase,
    required this.updatePaymentMethodUseCase,
    required this.logger,
  }) : super(const PaymentMethodFormInitial());

  /// Charge un moyen de paiement pour édition
  Future<void> loadPaymentMethodForEdit(String id) async {
    state = const PaymentMethodFormLoading();
    logger.d('📝 Chargement moyen de paiement $id pour édition');

    final (paymentMethod, error) = await getPaymentMethodByIdUseCase(id);

    if (error != null) {
      logger.e('❌ Erreur chargement: $error');
      state = PaymentMethodFormError(error);
      return;
    }

    if (paymentMethod == null) {
      state = const PaymentMethodFormError('Moyen de paiement non trouvé');
      return;
    }

    logger.i('✅ Moyen de paiement chargé pour édition');
    state = PaymentMethodFormLoadedForEdit(paymentMethod);
  }

  /// Crée un nouveau moyen de paiement
  Future<void> createPaymentMethod(Map<String, dynamic> data) async {
    state = const PaymentMethodFormSubmitting();
    logger.d('💾 Création moyen de paiement');
    logger.d('Data: $data');

    final (paymentMethod, error) = await createPaymentMethodUseCase(data);

    if (error != null) {
      logger.e('❌ Erreur création: $error');
      state = PaymentMethodFormError(error);
      return;
    }

    if (paymentMethod == null) {
      state = const PaymentMethodFormError('Erreur lors de la création');
      return;
    }

    logger.i('✅ Moyen de paiement créé: ${paymentMethod.name}');
    state = PaymentMethodFormSuccess(
      message: 'Moyen de paiement créé avec succès',
      paymentMethod: paymentMethod,
    );
  }

  /// Met à jour un moyen de paiement existant
  Future<void> updatePaymentMethod(String id, Map<String, dynamic> data) async {
    state = const PaymentMethodFormSubmitting();
    logger.d('💾 Modification moyen de paiement $id');
    logger.d('Data: $data');

    final (paymentMethod, error) = await updatePaymentMethodUseCase(id, data);

    if (error != null) {
      logger.e('❌ Erreur modification: $error');
      state = PaymentMethodFormError(error);
      return;
    }

    if (paymentMethod == null) {
      state = const PaymentMethodFormError('Erreur lors de la modification');
      return;
    }

    logger.i('✅ Moyen de paiement modifié: ${paymentMethod.name}');
    state = PaymentMethodFormSuccess(
      message: 'Moyen de paiement modifié avec succès',
      paymentMethod: paymentMethod,
    );
  }

  /// Réinitialise le formulaire
  void resetForm() {
    logger.d('🔄 Réinitialisation formulaire');
    state = const PaymentMethodFormInitial();
  }
}