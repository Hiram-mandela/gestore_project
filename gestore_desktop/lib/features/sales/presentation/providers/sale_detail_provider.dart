// ========================================
// lib/features/sales/presentation/providers/sale_detail_provider.dart
// Provider pour le détail d'une vente - VERSION CORRIGÉE
// ========================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../../../config/dependencies.dart';
import '../../domain/usecases/get_sale_detail_usecase.dart';
import '../../domain/usecases/void_sale_usecase.dart';
import 'sale_detail_state.dart';

/// Provider du détail de vente (family pour ID)
final saleDetailProvider = StateNotifierProvider.family<SaleDetailNotifier, SaleDetailState, String>(
      (ref, saleId) {
    return SaleDetailNotifier(
      saleId: saleId,
      getSaleDetailUseCase: getIt<GetSaleDetailUseCase>(),
      voidSaleUseCase: getIt<VoidSaleUseCase>(),
      logger: getIt<Logger>(),
    );
  },
);

/// Notifier pour le détail de vente
class SaleDetailNotifier extends StateNotifier<SaleDetailState> {
  final String saleId;
  final GetSaleDetailUseCase getSaleDetailUseCase;
  final VoidSaleUseCase voidSaleUseCase;
  final Logger logger;

  SaleDetailNotifier({
    required this.saleId,
    required this.getSaleDetailUseCase,
    required this.voidSaleUseCase,
    required this.logger,
  }) : super(const SaleDetailInitial());

  /// Charger le détail de la vente
  Future<void> loadSale() async {
    state = const SaleDetailLoading();

    try {
      logger.i('📋 Chargement détail vente: $saleId');

      final (sale, error) = await getSaleDetailUseCase(saleId);

      if (error != null) {
        throw Exception(error);
      }

      if (sale == null) {
        throw Exception('Vente non trouvée');
      }

      state = SaleDetailLoaded(sale);
      logger.i('✅ Détail vente chargé');
    } catch (e, stackTrace) {
      logger.e('❌ Erreur chargement détail', error: e, stackTrace: stackTrace);
      state = SaleDetailError(e.toString());
    }
  }

  /// Annuler la vente
  Future<void> voidSale(String reason) async {
    try {
      logger.i('❌ Annulation vente: $saleId - $reason');

      final (success, error) = await voidSaleUseCase(
        saleId: saleId,
        reason: reason,
      );

      if (error != null) {
        throw Exception(error);
      }

      // Recharger le détail
      await loadSale();
      logger.i('✅ Vente annulée');
    } catch (e, stackTrace) {
      logger.e('❌ Erreur annulation vente', error: e, stackTrace: stackTrace);
      state = SaleDetailError(e.toString());
    }
  }
}