// ========================================
// lib/features/inventory/presentation/providers/stocks_provider.dart
// Provider pour la gestion des stocks
// ========================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../../../config/dependencies.dart';
import '../../domain/usecases/stock_usecases.dart';
import 'stocks_state.dart';

/// Provider pour l'état des stocks
final stocksProvider =
StateNotifierProvider<StocksNotifier, StocksState>((ref) {
  return StocksNotifier(
    getStocksUseCase: getIt<GetStocksUseCase>(),
    getStockByIdUseCase: getIt<GetStockByIdUseCase>(),
    adjustStockUseCase: getIt<AdjustStockUseCase>(),
    transferStockUseCase: getIt<TransferStockUseCase>(),
    getStockValuationUseCase: getIt<GetStockValuationUseCase>(),
    logger: getIt<Logger>(),
  );
});

/// Notifier pour gérer l'état des stocks
class StocksNotifier extends StateNotifier<StocksState> {
  final GetStocksUseCase getStocksUseCase;
  final GetStockByIdUseCase getStockByIdUseCase;
  final AdjustStockUseCase adjustStockUseCase;
  final TransferStockUseCase transferStockUseCase;
  final GetStockValuationUseCase getStockValuationUseCase;
  final Logger logger;

  StocksNotifier({
    required this.getStocksUseCase,
    required this.getStockByIdUseCase,
    required this.adjustStockUseCase,
    required this.transferStockUseCase,
    required this.getStockValuationUseCase,
    required this.logger,
  }) : super(const StocksInitial());

  /// Charge tous les stocks avec filtres optionnels
  Future<void> loadStocks({
    String? articleId,
    String? locationId,
    DateTime? expiryDate,
  }) async {
    logger.i('📦 Chargement stocks...');
    state = const StocksLoading();

    try {
      final (stocks, error) = await getStocksUseCase(
        articleId: articleId,
        locationId: locationId,
        expiryDate: expiryDate,
      );

      if (error != null) {
        logger.e('❌ Erreur chargement stocks: $error');
        state = StocksError(message: error);
        return;
      }

      if (stocks != null) {
        logger.i('✅ Stocks chargés: ${stocks.length}');
        state = StocksLoaded(
          stocks: stocks,
          currentArticleId: articleId,
          currentLocationId: locationId,
        );
      }
    } catch (e) {
      logger.e('❌ Exception chargement stocks: $e');
      state = const StocksError(message: 'Une erreur est survenue');
    }
  }

  /// Charge un stock par son ID
  Future<void> loadStockById(String id) async {
    logger.i('📦 Chargement stock $id...');
    state = const StocksLoading();

    try {
      final (stock, error) = await getStockByIdUseCase(id);

      if (error != null) {
        logger.e('❌ Erreur chargement stock: $error');
        state = StocksError(message: error);
        return;
      }

      if (stock != null) {
        logger.i('✅ Stock chargé');
        state = StockDetailLoaded(stock: stock);
      }
    } catch (e) {
      logger.e('❌ Exception chargement stock: $e');
      state = const StocksError(message: 'Une erreur est survenue');
    }
  }

  /// Ajuste un stock (inventaire, correction, etc.)
  Future<bool> adjustStock({
    required String articleId,
    required String locationId,
    required double newQuantity,
    required String reason,
    String? referenceDocument,
    String? notes,
  }) async {
    logger.i('📦 Ajustement stock...');

    try {
      final (result, error) = await adjustStockUseCase(
        articleId: articleId,
        locationId: locationId,
        newQuantity: newQuantity,
        reason: reason,
        referenceDocument: referenceDocument,
        notes: notes,
      );

      if (error != null) {
        logger.e('❌ Erreur ajustement stock: $error');
        state = StocksError(message: error);
        return false;
      }

      if (result != null) {
        logger.i('✅ Stock ajusté');
        state = StockOperationSuccess(
          message: 'Stock ajusté avec succès',
          data: result,
        );

        // Recharger les stocks
        await loadStocks(articleId: articleId, locationId: locationId);
        return true;
      }

      return false;
    } catch (e) {
      logger.e('❌ Exception ajustement stock: $e');
      state = const StocksError(message: 'Une erreur est survenue');
      return false;
    }
  }

  /// Transfère un stock entre emplacements
  Future<bool> transferStock({
    required String articleId,
    required String fromLocationId,
    required String toLocationId,
    required double quantity,
    String? referenceDocument,
    String? notes,
  }) async {
    logger.i('📦 Transfert stock...');

    try {
      final (result, error) = await transferStockUseCase(
        articleId: articleId,
        fromLocationId: fromLocationId,
        toLocationId: toLocationId,
        quantity: quantity,
        referenceDocument: referenceDocument,
        notes: notes,
      );

      if (error != null) {
        logger.e('❌ Erreur transfert stock: $error');
        state = StocksError(message: error);
        return false;
      }

      if (result != null) {
        logger.i('✅ Stock transféré');
        state = StockOperationSuccess(
          message: 'Stock transféré avec succès',
          data: result,
        );

        // Recharger les stocks
        await loadStocks(articleId: articleId);
        return true;
      }

      return false;
    } catch (e) {
      logger.e('❌ Exception transfert stock: $e');
      state = const StocksError(message: 'Une erreur est survenue');
      return false;
    }
  }

  /// Charge la valorisation du stock total
  Future<void> loadStockValuation() async {
    logger.i('📦 Chargement valorisation stock...');
    state = const StocksLoading();

    try {
      final (result, error) = await getStockValuationUseCase();

      if (error != null) {
        logger.e('❌ Erreur valorisation: $error');
        state = StocksError(message: error);
        return;
      }

      if (result != null) {
        logger.i('✅ Valorisation chargée');
        state = StockValuationLoaded(
          totalValue: (result['total_value'] as num?)?.toDouble() ?? 0.0,
          totalArticles: result['total_articles'] as int? ?? 0,
          byCategory: result['by_category'] as Map<String, dynamic>? ?? {},
        );
      }
    } catch (e) {
      logger.e('❌ Exception valorisation: $e');
      state = const StocksError(message: 'Une erreur est survenue');
    }
  }

  /// Réinitialise l'état
  void reset() {
    state = const StocksInitial();
  }
}