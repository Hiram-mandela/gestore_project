// ========================================
// lib/features/sales/domain/usecases/pos_checkout_usecase.dart
// Use case pour finaliser une vente (checkout)
// ========================================

import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../entities/sale_detail_entity.dart';
import '../repositories/sales_repository.dart';

@lazySingleton
class PosCheckoutUseCase {
  final SalesRepository repository;
  final Logger logger;

  PosCheckoutUseCase({
    required this.repository,
    required this.logger,
  });

  Future<(SaleDetailEntity?, String?)> call({
    required List<Map<String, dynamic>> items,
    required List<Map<String, dynamic>> payments,
    String? customerId,
    int loyaltyPointsToUse = 0,
    List<String> discountCodes = const [],
    String? notes,
  }) async {
    try {
      logger.d('🛒 UseCase: Checkout POS (${items.length} articles)');

      // Validation
      if (items.isEmpty) {
        return (null, 'Le panier est vide');
      }

      if (payments.isEmpty) {
        return (null, 'Aucun paiement fourni');
      }

      // Calcul du total des paiements
      final totalPayments = payments.fold<double>(
        0.0,
            (sum, payment) => sum + (payment['amount'] as num).toDouble(),
      );

      if (totalPayments <= 0) {
        return (null, 'Le montant total des paiements doit être positif');
      }

      return await repository.checkout(
        items: items,
        payments: payments,
        customerId: customerId,
        loyaltyPointsToUse: loyaltyPointsToUse,
        discountCodes: discountCodes,
        notes: notes,
      );
    } catch (e) {
      logger.e('❌ UseCase: Erreur checkout POS: $e');
      return (null, 'Erreur lors de la finalisation de la vente');
    }
  }
}