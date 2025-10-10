// ========================================
// lib/features/sales/presentation/providers/sale_detail_state.dart
// États pour le détail d'une vente
// ========================================

import 'package:equatable/equatable.dart';
import '../../domain/entities/sale_detail_entity.dart';

/// États du détail de vente
abstract class SaleDetailState extends Equatable {
  const SaleDetailState();

  @override
  List<Object?> get props => [];
}

/// État initial
class SaleDetailInitial extends SaleDetailState {
  const SaleDetailInitial();
}

/// État de chargement
class SaleDetailLoading extends SaleDetailState {
  const SaleDetailLoading();
}

/// État chargé
class SaleDetailLoaded extends SaleDetailState {
  final SaleDetailEntity sale;

  const SaleDetailLoaded(this.sale);

  @override
  List<Object?> get props => [sale];
}

/// État d'erreur
class SaleDetailError extends SaleDetailState {
  final String message;

  const SaleDetailError(this.message);

  @override
  List<Object?> get props => [message];
}