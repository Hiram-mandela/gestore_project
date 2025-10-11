// ========================================
// lib/features/sales/presentation/providers/payment_method_form_state.dart
// États pour le formulaire de moyen de paiement
// ========================================

import 'package:equatable/equatable.dart';
import '../../domain/entities/payment_method_entity.dart';

/// État de base pour le formulaire
abstract class PaymentMethodFormState extends Equatable {
  const PaymentMethodFormState();

  @override
  List<Object?> get props => [];
}

/// État initial
class PaymentMethodFormInitial extends PaymentMethodFormState {
  const PaymentMethodFormInitial();
}

/// État de chargement (lors de la récupération pour édition)
class PaymentMethodFormLoading extends PaymentMethodFormState {
  const PaymentMethodFormLoading();
}

/// État de chargement pour édition
class PaymentMethodFormLoadedForEdit extends PaymentMethodFormState {
  final PaymentMethodEntity paymentMethod;

  const PaymentMethodFormLoadedForEdit(this.paymentMethod);

  @override
  List<Object?> get props => [paymentMethod];
}

/// État de soumission en cours
class PaymentMethodFormSubmitting extends PaymentMethodFormState {
  const PaymentMethodFormSubmitting();
}

/// État de succès
class PaymentMethodFormSuccess extends PaymentMethodFormState {
  final String message;
  final PaymentMethodEntity paymentMethod;

  const PaymentMethodFormSuccess({
    required this.message,
    required this.paymentMethod,
  });

  @override
  List<Object?> get props => [message, paymentMethod];
}

/// État d'erreur
class PaymentMethodFormError extends PaymentMethodFormState {
  final String message;

  const PaymentMethodFormError(this.message);

  @override
  List<Object?> get props => [message];
}