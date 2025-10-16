// ========================================
// lib/features/sales/presentation/providers/discounts_list_state.dart
// États pour la liste des remises/promotions
// ========================================

import 'package:equatable/equatable.dart';
import '../../domain/entities/discount_entity.dart';

/// État de base pour la liste des remises
abstract class DiscountsListState extends Equatable {
  const DiscountsListState();

  @override
  List<Object?> get props => [];
}

/// État initial
class DiscountsListInitial extends DiscountsListState {
  const DiscountsListInitial();
}

/// État de chargement
class DiscountsListLoading extends DiscountsListState {
  const DiscountsListLoading();
}

/// État de succès avec données
class DiscountsListLoaded extends DiscountsListState {
  final List<DiscountEntity> discounts;
  final int totalCount;
  final int currentPage;
  final bool hasNextPage;
  final String? selectedType;
  final String? selectedScope;
  final bool? selectedStatus;
  final bool showActiveOnly;
  final String searchQuery;

  const DiscountsListLoaded({
    required this.discounts,
    required this.totalCount,
    this.currentPage = 1,
    this.hasNextPage = false,
    this.selectedType,
    this.selectedScope,
    this.selectedStatus,
    this.showActiveOnly = false,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [
    discounts,
    totalCount,
    currentPage,
    hasNextPage,
    selectedType,
    selectedScope,
    selectedStatus,
    showActiveOnly,
    searchQuery,
  ];

  /// Copie avec modifications
  DiscountsListLoaded copyWith({
    List<DiscountEntity>? discounts,
    int? totalCount,
    int? currentPage,
    bool? hasNextPage,
    String? selectedType,
    String? selectedScope,
    bool? selectedStatus,
    bool? showActiveOnly,
    String? searchQuery,
  }) {
    return DiscountsListLoaded(
      discounts: discounts ?? this.discounts,
      totalCount: totalCount ?? this.totalCount,
      currentPage: currentPage ?? this.currentPage,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      selectedType: selectedType ?? this.selectedType,
      selectedScope: selectedScope ?? this.selectedScope,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      showActiveOnly: showActiveOnly ?? this.showActiveOnly,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// État d'erreur
class DiscountsListError extends DiscountsListState {
  final String message;

  const DiscountsListError(this.message);

  @override
  List<Object?> get props => [message];
}

/// État de suppression réussie
class DiscountDeleted extends DiscountsListState {
  final String message;

  const DiscountDeleted(this.message);

  @override
  List<Object?> get props => [message];
}