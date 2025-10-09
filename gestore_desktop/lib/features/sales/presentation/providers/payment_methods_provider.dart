// ========================================
// lib/features/sales/presentation/providers/payment_methods_provider.dart
// Provider pour les moyens de paiement
// ========================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../../../config/dependencies.dart';
import '../../domain/usecases/payment_method_usecases.dart';
import 'pos_state.dart';

// ==================== PAYMENT METHODS PROVIDER ====================

/// Provider pour les moyens de paiement
final paymentMethodsProvider =
StateNotifierProvider<PaymentMethodsNotifier, PaymentMethodsState>((ref) {
  return PaymentMethodsNotifier(
    getPaymentMethodsUseCase: getIt<GetPaymentMethodsUseCase>(),
    logger: getIt<Logger>(),
  );
});

/// Notifier pour les moyens de paiement
class PaymentMethodsNotifier extends StateNotifier<PaymentMethodsState> {
  final GetPaymentMethodsUseCase getPaymentMethodsUseCase;
  final Logger logger;

  PaymentMethodsNotifier({
    required this.getPaymentMethodsUseCase,
    required this.logger,
  }) : super(const PaymentMethodsInitial());

  /// Charge les moyens de paiement actifs
  Future<void> loadPaymentMethods() async {
    if (state is PaymentMethodsLoading) return;

    state = const PaymentMethodsLoading();
    logger.d('💳 Loading payment methods...');

    final (paymentMethods, error) = await getPaymentMethodsUseCase(isActive: true);

    if (error != null) {
      logger.e('❌ Error loading payment methods: $error');
      state = PaymentMethodsError(error);
      return;
    }

    if (paymentMethods == null || paymentMethods.isEmpty) {
      state = const PaymentMethodsError('Aucun moyen de paiement disponible');
      return;
    }

    logger.i('✅ ${paymentMethods.length} payment methods loaded');
    state = PaymentMethodsLoaded(paymentMethods);
  }

  /// Rafraîchit la liste
  Future<void> refresh() async {
    await loadPaymentMethods();
  }
}