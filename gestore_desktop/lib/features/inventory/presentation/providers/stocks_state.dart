// ========================================
// lib/features/inventory/presentation/providers/stocks_state.dart
// États pour la gestion des stocks
// ========================================

import 'package:equatable/equatable.dart';
import '../../domain/entities/stock_entity.dart';

/// État de base
abstract class StocksState extends Equatable {
  const StocksState();

  @override
  List<Object?> get props => [];
}

/// État initial
class StocksInitial extends StocksState {
  const StocksInitial();
}

/// État de chargement
class StocksLoading extends StocksState {
  const StocksLoading();
}

/// État de succès avec liste de stocks
class StocksLoaded extends StocksState {
  final List<StockEntity> stocks;
  final String? currentArticleId;
  final String? currentLocationId;

  const StocksLoaded({
    required this.stocks,
    this.currentArticleId,
    this.currentLocationId,
  });

  @override
  List<Object?> get props => [stocks, currentArticleId, currentLocationId];

  /// Nombre total de stocks
  int get count => stocks.length;

  /// Valeur totale du stock
  double get totalValue {
    return stocks.fold(0.0, (sum, stock) => sum + stock.stockValue);
  }

  /// Quantité totale en stock
  double get totalQuantity {
    return stocks.fold(0.0, (sum, stock) => sum + stock.quantityOnHand);
  }

  /// Quantité totale disponible
  double get totalAvailable {
    return stocks.fold(0.0, (sum, stock) => sum + stock.quantityAvailable);
  }

  /// Stocks périmés
  List<StockEntity> get expiredStocks {
    return stocks.where((stock) => stock.isExpired).toList();
  }

  /// Stocks péremption proche
  List<StockEntity> get expiringSoonStocks {
    return stocks.where((stock) => stock.isExpiringSoon).toList();
  }

  /// Stocks épuisés
  List<StockEntity> get outOfStocks {
    return stocks.where((stock) => stock.isOutOfStock).toList();
  }

  /// Filtre les stocks par article
  List<StockEntity> filterByArticle(String articleId) {
    return stocks.where((stock) => stock.articleId == articleId).toList();
  }

  /// Filtre les stocks par emplacement
  List<StockEntity> filterByLocation(String locationId) {
    return stocks.where((stock) => stock.locationId == locationId).toList();
  }
}

/// État d'erreur
class StocksError extends StocksState {
  final String message;

  const StocksError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// État pour un seul stock
class StockDetailLoaded extends StocksState {
  final StockEntity stock;

  const StockDetailLoaded({required this.stock});

  @override
  List<Object?> get props => [stock];
}

/// État de succès pour ajustement/transfert
class StockOperationSuccess extends StocksState {
  final String message;
  final Map<String, dynamic>? data;

  const StockOperationSuccess({
    required this.message,
    this.data,
  });

  @override
  List<Object?> get props => [message, data];
}

/// État pour la valorisation du stock
class StockValuationLoaded extends StocksState {
  final double totalValue;
  final int totalArticles;
  final Map<String, dynamic> byCategory;

  const StockValuationLoaded({
    required this.totalValue,
    required this.totalArticles,
    required this.byCategory,
  });

  @override
  List<Object?> get props => [totalValue, totalArticles, byCategory];
}