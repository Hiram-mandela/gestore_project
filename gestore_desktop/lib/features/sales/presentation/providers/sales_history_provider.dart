// ========================================
// FICHIER 3: sales_history_provider.dart - VERSION FINALE CORRIGÉE
// ========================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../../../config/dependencies.dart';
import '../../domain/usecases/get_sales_usecase.dart';
import '../../domain/usecases/get_daily_summary_usecase.dart';
import 'sales_history_state.dart';

final salesHistoryProvider = StateNotifierProvider<SalesHistoryNotifier, SalesHistoryState>((ref) {
  return SalesHistoryNotifier(
    getSalesUseCase: getIt<GetSalesUseCase>(),
    getDailySummaryUseCase: getIt<GetDailySummaryUseCase>(),
    logger: getIt<Logger>(),
  );
});

class SalesHistoryNotifier extends StateNotifier<SalesHistoryState> {
  final GetSalesUseCase getSalesUseCase;
  final GetDailySummaryUseCase getDailySummaryUseCase;
  final Logger logger;

  static const int _pageSize = 20;

  SalesHistoryNotifier({
    required this.getSalesUseCase,
    required this.getDailySummaryUseCase,
    required this.logger,
  }) : super(const SalesHistoryInitial());

  Future<void> loadSales({bool refresh = false}) async {
    if (refresh) state = const SalesHistoryLoading();

    try {
      logger.i('📋 Chargement historique ventes...');

      final (salesResult, salesError) = await getSalesUseCase(page: 1, pageSize: _pageSize);

      if (salesError != null) throw Exception(salesError);
      if (salesResult == null) throw Exception('Aucune donnée reçue');

      final (dailySummary, summaryError) = await getDailySummaryUseCase();

      if (summaryError != null) logger.w('⚠️ Erreur chargement résumé: $summaryError');

      // ⭐ CORRECTION: PaginatedResponseEntity a `results` pas `items`
      state = SalesHistoryLoaded(
        sales: salesResult.results,
        totalCount: salesResult.count,
        currentPage: 1,
        hasMore: salesResult.results.length < salesResult.count,
        todaySalesCount: dailySummary?['sales_count'] ?? 0,
        todayRevenue: (dailySummary?['total_revenue'] ?? 0.0).toDouble(),
        averageBasket: (dailySummary?['average_basket'] ?? 0.0).toDouble(),
      );

      logger.i('✅ ${salesResult.results.length} ventes chargées');
    } catch (e, stackTrace) {
      logger.e('❌ Erreur chargement ventes', error: e, stackTrace: stackTrace);
      state = SalesHistoryError(e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state is! SalesHistoryLoaded) return;

    final currentState = state as SalesHistoryLoaded;
    if (!currentState.hasMore || currentState.isLoadingMore) return;

    state = currentState.copyWith(isLoadingMore: true);

    try {
      final nextPage = currentState.currentPage + 1;
      logger.i('📄 Chargement page $nextPage...');

      final (result, error) = await getSalesUseCase(
        page: nextPage,
        pageSize: _pageSize,
        search: currentState.searchQuery.isNotEmpty ? currentState.searchQuery : null,
        status: currentState.statusFilter,
      );

      if (error != null) throw Exception(error);
      if (result == null) throw Exception('Aucune donnée reçue');

      final allSales = [...currentState.sales, ...result.results];

      state = currentState.copyWith(
        sales: allSales,
        currentPage: nextPage,
        hasMore: allSales.length < result.count,
        isLoadingMore: false,
      );

      logger.i('✅ Page $nextPage chargée (${result.results.length} ventes)');
    } catch (e, stackTrace) {
      logger.e('❌ Erreur chargement page', error: e, stackTrace: stackTrace);
      state = (state as SalesHistoryLoaded).copyWith(isLoadingMore: false);
    }
  }

  Future<void> refresh() async => await loadSales(refresh: true);

  Future<void> search(String query) async {
    state = const SalesHistoryLoading();

    try {
      logger.i('🔍 Recherche: "$query"');

      final (result, error) = await getSalesUseCase(
        page: 1,
        pageSize: _pageSize,
        search: query.isNotEmpty ? query : null,
      );

      if (error != null) throw Exception(error);
      if (result == null) throw Exception('Aucune donnée reçue');

      final (dailySummary, _) = await getDailySummaryUseCase();

      state = SalesHistoryLoaded(
        sales: result.results,
        totalCount: result.count,
        currentPage: 1,
        hasMore: result.results.length < result.count,
        searchQuery: query,
        todaySalesCount: dailySummary?['sales_count'] ?? 0,
        todayRevenue: (dailySummary?['total_revenue'] ?? 0.0).toDouble(),
        averageBasket: (dailySummary?['average_basket'] ?? 0.0).toDouble(),
      );

      logger.i('✅ ${result.results.length} résultats trouvés');
    } catch (e, stackTrace) {
      logger.e('❌ Erreur recherche', error: e, stackTrace: stackTrace);
      state = SalesHistoryError(e.toString());
    }
  }

  Future<void> filterByStatus(String status) async {
    state = const SalesHistoryLoading();

    try {
      logger.i('🔧 Filtre statut: $status');

      final (result, error) = await getSalesUseCase(
        page: 1,
        pageSize: _pageSize,
        status: status != 'all' ? status : null,
      );

      if (error != null) throw Exception(error);
      if (result == null) throw Exception('Aucune donnée reçue');

      final (dailySummary, _) = await getDailySummaryUseCase();

      state = SalesHistoryLoaded(
        sales: result.results,
        totalCount: result.count,
        currentPage: 1,
        hasMore: result.results.length < result.count,
        statusFilter: status != 'all' ? status : null,
        todaySalesCount: dailySummary?['sales_count'] ?? 0,
        todayRevenue: (dailySummary?['total_revenue'] ?? 0.0).toDouble(),
        averageBasket: (dailySummary?['average_basket'] ?? 0.0).toDouble(),
      );

      logger.i('✅ ${result.results.length} ventes filtrées');
    } catch (e, stackTrace) {
      logger.e('❌ Erreur filtrage', error: e, stackTrace: stackTrace);
      state = SalesHistoryError(e.toString());
    }
  }

  Future<void> filterByDateRange(DateTime startDate, DateTime endDate) async {
    state = const SalesHistoryLoading();

    try {
      logger.i('🔧 Filtre période: ${startDate.toString()} - ${endDate.toString()}');

      final (result, error) = await getSalesUseCase(
        page: 1,
        pageSize: _pageSize,
        dateFrom: startDate,
        dateTo: endDate,
      );

      if (error != null) throw Exception(error);
      if (result == null) throw Exception('Aucune donnée reçue');

      final (dailySummary, _) = await getDailySummaryUseCase();

      state = SalesHistoryLoaded(
        sales: result.results,
        totalCount: result.count,
        currentPage: 1,
        hasMore: result.results.length < result.count,
        todaySalesCount: dailySummary?['sales_count'] ?? 0,
        todayRevenue: (dailySummary?['total_revenue'] ?? 0.0).toDouble(),
        averageBasket: (dailySummary?['average_basket'] ?? 0.0).toDouble(),
      );

      logger.i('✅ ${result.results.length} ventes trouvées pour la période');
    } catch (e, stackTrace) {
      logger.e('❌ Erreur filtrage période', error: e, stackTrace: stackTrace);
      state = SalesHistoryError(e.toString());
    }
  }
}
