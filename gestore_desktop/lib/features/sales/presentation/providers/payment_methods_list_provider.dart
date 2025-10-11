// ========================================
// lib/features/sales/presentation/providers/payment_methods_list_provider.dart
// Provider pour la liste des moyens de paiement
// ========================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../../../config/dependencies.dart';
import '../../domain/usecases/payment_method_usecases.dart';
import '../../domain/usecases/update_payment_method_usecase.dart';
import '../../domain/usecases/delete_payment_method_usecase.dart';
import '../../domain/entities/payment_method_entity.dart';
import 'payment_methods_list_state.dart';

/// Provider pour la liste des moyens de paiement
final paymentMethodsListProvider =
StateNotifierProvider<PaymentMethodsListNotifier, PaymentMethodsListState>(
      (ref) {
    return PaymentMethodsListNotifier(
      getPaymentMethodsUseCase: getIt<GetPaymentMethodsUseCase>(),
      deletePaymentMethodUseCase: getIt<DeletePaymentMethodUseCase>(),
      updatePaymentMethodUseCase: getIt<UpdatePaymentMethodUseCase>(),
      logger: getIt<Logger>(),
    );
  },
);

/// Notifier pour la gestion de la liste
class PaymentMethodsListNotifier extends StateNotifier<PaymentMethodsListState> {
  final GetPaymentMethodsUseCase getPaymentMethodsUseCase;
  final DeletePaymentMethodUseCase deletePaymentMethodUseCase;
  final UpdatePaymentMethodUseCase updatePaymentMethodUseCase;
  final Logger logger;

  PaymentMethodsListNotifier({
    required this.getPaymentMethodsUseCase,
    required this.deletePaymentMethodUseCase,
    required this.updatePaymentMethodUseCase,
    required this.logger,
  }) : super(const PaymentMethodsListInitial());

  /// Charge tous les moyens de paiement
  Future<void> loadPaymentMethods() async {
    if (state is PaymentMethodsListLoading) return;

    state = const PaymentMethodsListLoading();
    logger.d('💳 Chargement moyens de paiement...');

    final (paymentMethods, error) = await getPaymentMethodsUseCase();

    if (error != null) {
      logger.e('❌ Erreur chargement: $error');
      state = PaymentMethodsListError(error);
      return;
    }

    if (paymentMethods == null || paymentMethods.isEmpty) {
      state = const PaymentMethodsListLoaded(
        paymentMethods: [],
        filteredPaymentMethods: [],
      );
      return;
    }

    logger.i('✅ ${paymentMethods.length} moyens de paiement chargés');
    state = PaymentMethodsListLoaded(
      paymentMethods: paymentMethods,
      filteredPaymentMethods: paymentMethods,
    );
  }

  /// Filtre par type de paiement
  void filterByType(String? type) {
    if (state is! PaymentMethodsListLoaded) return;

    final currentState = state as PaymentMethodsListLoaded;
    logger.d('🔍 Filtre par type: $type');

    if (type == null || type.isEmpty) {
      state = currentState.copyWith(
        selectedType: null,
        filteredPaymentMethods: _applyFilters(
          currentState.paymentMethods,
          null,
          currentState.selectedStatus,
          currentState.searchQuery,
        ),
      );
    } else {
      state = currentState.copyWith(
        selectedType: type,
        filteredPaymentMethods: _applyFilters(
          currentState.paymentMethods,
          type,
          currentState.selectedStatus,
          currentState.searchQuery,
        ),
      );
    }
  }

  /// Filtre par statut actif/inactif
  void filterByStatus(bool? isActive) {
    if (state is! PaymentMethodsListLoaded) return;

    final currentState = state as PaymentMethodsListLoaded;
    logger.d('🔍 Filtre par statut: $isActive');

    state = currentState.copyWith(
      selectedStatus: isActive,
      filteredPaymentMethods: _applyFilters(
        currentState.paymentMethods,
        currentState.selectedType,
        isActive,
        currentState.searchQuery,
      ),
    );
  }

  /// Recherche par nom
  void searchPaymentMethods(String query) {
    if (state is! PaymentMethodsListLoaded) return;

    final currentState = state as PaymentMethodsListLoaded;
    logger.d('🔍 Recherche: $query');

    state = currentState.copyWith(
      searchQuery: query,
      filteredPaymentMethods: _applyFilters(
        currentState.paymentMethods,
        currentState.selectedType,
        currentState.selectedStatus,
        query,
      ),
    );
  }

  /// Applique tous les filtres
  List<PaymentMethodEntity> _applyFilters(
      List<PaymentMethodEntity> paymentMethods,
      String? type,
      bool? isActive,
      String searchQuery,
      ) {
    var filtered = paymentMethods;

    // Filtre par type
    if (type != null && type.isNotEmpty) {
      filtered = filtered.where((pm) => pm.paymentType == type).toList();
    }

    // Filtre par statut
    if (isActive != null) {
      filtered = filtered.where((pm) => pm.isActive == isActive).toList();
    }

    // Recherche par nom
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((pm) {
        return pm.name.toLowerCase().contains(query) ||
            (pm.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    return filtered;
  }

  /// Supprime un moyen de paiement
  Future<void> deletePaymentMethod(String id) async {
    if (state is! PaymentMethodsListLoaded) return;

    logger.d('🗑️ Suppression moyen de paiement $id');

    final (_, error) = await deletePaymentMethodUseCase(id);

    if (error != null) {
      logger.e('❌ Erreur suppression: $error');
      state = PaymentMethodsListError(error);
      return;
    }

    logger.i('✅ Moyen de paiement supprimé');
    state = const PaymentMethodDeleted('Moyen de paiement supprimé avec succès');

    // Recharger la liste
    await loadPaymentMethods();
  }

  /// Bascule l'état actif/inactif d'un moyen de paiement
  Future<void> toggleActivation(String id, bool currentStatus) async {
    if (state is! PaymentMethodsListLoaded) return;

    logger.d('🔄 Toggle activation moyen de paiement $id: ${!currentStatus}');

    final (_, error) = await updatePaymentMethodUseCase(
      id,
      {'is_active': !currentStatus},
    );

    if (error != null) {
      logger.e('❌ Erreur toggle activation: $error');
      state = PaymentMethodsListError(error);
      return;
    }

    logger.i('✅ État modifié');

    // Recharger la liste
    await loadPaymentMethods();
  }

  /// Réinitialise tous les filtres
  void resetFilters() {
    if (state is! PaymentMethodsListLoaded) return;

    final currentState = state as PaymentMethodsListLoaded;

    state = currentState.copyWith(
      selectedType: null,
      selectedStatus: null,
      searchQuery: '',
      filteredPaymentMethods: currentState.paymentMethods,
    );
  }
}