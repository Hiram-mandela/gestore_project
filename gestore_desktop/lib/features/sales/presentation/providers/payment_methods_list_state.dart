// ========================================
// lib/features/sales/presentation/providers/payment_methods_list_state.dart
// États pour la liste des moyens de paiement
// ========================================

import 'package:equatable/equatable.dart';
import '../../domain/entities/payment_method_entity.dart';

/// État de base pour la liste des moyens de paiement
abstract class PaymentMethodsListState extends Equatable {
  const PaymentMethodsListState();

  @override
  List<Object?> get props => [];
}

/// État initial
class PaymentMethodsListInitial extends PaymentMethodsListState {
  const PaymentMethodsListInitial();
}

/// État de chargement
class PaymentMethodsListLoading extends PaymentMethodsListState {
  const PaymentMethodsListLoading();
}

/// État de succès avec données
class PaymentMethodsListLoaded extends PaymentMethodsListState {
  final List<PaymentMethodEntity> paymentMethods;
  final List<PaymentMethodEntity> filteredPaymentMethods;
  final String? selectedType;
  final bool? selectedStatus;
  final String searchQuery;

  const PaymentMethodsListLoaded({
    required this.paymentMethods,
    required this.filteredPaymentMethods,
    this.selectedType,
    this.selectedStatus,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [
    paymentMethods,
    filteredPaymentMethods,
    selectedType,
    selectedStatus,
    searchQuery,
  ];

  /// Copie avec modifications
  PaymentMethodsListLoaded copyWith({
    List<PaymentMethodEntity>? paymentMethods,
    List<PaymentMethodEntity>? filteredPaymentMethods,
    String? selectedType,
    bool? selectedStatus,
    String? searchQuery,
  }) {
    return PaymentMethodsListLoaded(
      paymentMethods: paymentMethods ?? this.paymentMethods,
      filteredPaymentMethods: filteredPaymentMethods ?? this.filteredPaymentMethods,
      selectedType: selectedType ?? this.selectedType,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// État d'erreur
class PaymentMethodsListError extends PaymentMethodsListState {
  final String message;

  const PaymentMethodsListError(this.message);

  @override
  List<Object?> get props => [message];
}

/// État de suppression réussie
class PaymentMethodDeleted extends PaymentMethodsListState {
  final String message;

  const PaymentMethodDeleted(this.message);

  @override
  List<Object?> get props => [message];
}