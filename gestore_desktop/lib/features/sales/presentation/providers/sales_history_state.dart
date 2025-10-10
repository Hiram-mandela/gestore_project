// ========================================
// lib/features/sales/presentation/providers/sales_history_state.dart
// États pour l'historique des ventes
// ========================================

import 'package:equatable/equatable.dart';
import '../../domain/entities/sale_entity.dart';

/// États de l'historique des ventes
abstract class SalesHistoryState extends Equatable {
  const SalesHistoryState();

  @override
  List<Object?> get props => [];
}

/// État initial
class SalesHistoryInitial extends SalesHistoryState {
  const SalesHistoryInitial();
}

/// État de chargement
class SalesHistoryLoading extends SalesHistoryState {
  const SalesHistoryLoading();
}

/// État chargé avec données
class SalesHistoryLoaded extends SalesHistoryState {
  final List<SaleEntity> sales;
  final int totalCount;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final String searchQuery;
  final String? statusFilter;

  // Statistiques du jour
  final int todaySalesCount;
  final double todayRevenue;
  final double averageBasket;

  const SalesHistoryLoaded({
    required this.sales,
    required this.totalCount,
    this.currentPage = 1,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.searchQuery = '',
    this.statusFilter,
    this.todaySalesCount = 0,
    this.todayRevenue = 0.0,
    this.averageBasket = 0.0,
  });

  SalesHistoryLoaded copyWith({
    List<SaleEntity>? sales,
    int? totalCount,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    String? searchQuery,
    String? statusFilter,
    int? todaySalesCount,
    double? todayRevenue,
    double? averageBasket,
  }) {
    return SalesHistoryLoaded(
      sales: sales ?? this.sales,
      totalCount: totalCount ?? this.totalCount,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      todaySalesCount: todaySalesCount ?? this.todaySalesCount,
      todayRevenue: todayRevenue ?? this.todayRevenue,
      averageBasket: averageBasket ?? this.averageBasket,
    );
  }

  @override
  List<Object?> get props => [
    sales,
    totalCount,
    currentPage,
    hasMore,
    isLoadingMore,
    searchQuery,
    statusFilter,
    todaySalesCount,
    todayRevenue,
    averageBasket,
  ];
}

/// État d'erreur
class SalesHistoryError extends SalesHistoryState {
  final String message;

  const SalesHistoryError(this.message);

  @override
  List<Object?> get props => [message];
}