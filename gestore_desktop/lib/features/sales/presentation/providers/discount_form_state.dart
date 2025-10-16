// ========================================
// lib/features/sales/presentation/providers/discount_form_state.dart
// États pour le formulaire de remise/promotion
// ========================================

import 'package:equatable/equatable.dart';
import '../../domain/entities/discount_entity.dart';

/// État de base pour le formulaire
abstract class DiscountFormState extends Equatable {
  const DiscountFormState();

  @override
  List<Object?> get props => [];
}

/// État initial
class DiscountFormInitial extends DiscountFormState {
  const DiscountFormInitial();
}

/// État de chargement (lors de la récupération pour édition)
class DiscountFormLoading extends DiscountFormState {
  const DiscountFormLoading();
}

/// État de chargement pour édition
class DiscountFormLoadedForEdit extends DiscountFormState {
  final DiscountEntity discount;

  const DiscountFormLoadedForEdit(this.discount);

  @override
  List<Object?> get props => [discount];
}

/// État de soumission en cours
class DiscountFormSubmitting extends DiscountFormState {
  const DiscountFormSubmitting();
}

/// État de succès
class DiscountFormSuccess extends DiscountFormState {
  final String message;
  final DiscountEntity discount;

  const DiscountFormSuccess({
    required this.message,
    required this.discount,
  });

  @override
  List<Object?> get props => [message, discount];
}

/// État d'erreur
class DiscountFormError extends DiscountFormState {
  final String message;

  const DiscountFormError(this.message);

  @override
  List<Object?> get props => [message];
}

/// État de calcul de simulation
class DiscountFormCalculating extends DiscountFormState {
  const DiscountFormCalculating();
}

/// État de résultat de calcul
class DiscountFormCalculated extends DiscountFormState {
  final Map<String, dynamic> calculationResult;

  const DiscountFormCalculated(this.calculationResult);

  @override
  List<Object?> get props => [calculationResult];
}