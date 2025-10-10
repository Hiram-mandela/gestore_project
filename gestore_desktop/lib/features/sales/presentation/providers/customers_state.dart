// ========================================
// lib/features/sales/presentation/providers/customers_state.dart
// États pour la liste des clients
// ========================================

import 'package:equatable/equatable.dart';
import '../../domain/entities/customer_entity.dart';

/// États de la liste des clients
abstract class CustomersState extends Equatable {
  const CustomersState();

  @override
  List<Object?> get props => [];
}

/// État initial
class CustomersInitial extends CustomersState {
  const CustomersInitial();
}

/// État de chargement
class CustomersLoading extends CustomersState {
  const CustomersLoading();
}

/// État chargé avec données
class CustomersLoaded extends CustomersState {
  final List<CustomerEntity> customers;
  final int totalCount;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final String searchQuery;
  final String? filterType;

  // Statistiques
  final int individuals;
  final int companies;
  final int loyaltyMembers;

  const CustomersLoaded({
    required this.customers,
    required this.totalCount,
    this.currentPage = 1,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.searchQuery = '',
    this.filterType,
    this.individuals = 0,
    this.companies = 0,
    this.loyaltyMembers = 0,
  });

  CustomersLoaded copyWith({
    List<CustomerEntity>? customers,
    int? totalCount,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    String? searchQuery,
    String? filterType,
    int? individuals,
    int? companies,
    int? loyaltyMembers,
  }) {
    return CustomersLoaded(
      customers: customers ?? this.customers,
      totalCount: totalCount ?? this.totalCount,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      searchQuery: searchQuery ?? this.searchQuery,
      filterType: filterType ?? this.filterType,
      individuals: individuals ?? this.individuals,
      companies: companies ?? this.companies,
      loyaltyMembers: loyaltyMembers ?? this.loyaltyMembers,
    );
  }

  @override
  List<Object?> get props => [
    customers,
    totalCount,
    currentPage,
    hasMore,
    isLoadingMore,
    searchQuery,
    filterType,
    individuals,
    companies,
    loyaltyMembers,
  ];
}

/// État d'erreur
class CustomersError extends CustomersState {
  final String message;

  const CustomersError(this.message);

  @override
  List<Object?> get props => [message];
}