// ========================================
// lib/features/sales/domain/usecases/calculate_sale_usecase.dart
// Use case pour calculer une vente avant finalisation
// ========================================

import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

import '../repositories/sales_repository.dart';

@lazySingleton
class CalculateSaleUseCase {
  final SalesRepository repository;
  final Logger logger;

  CalculateSaleUseCase({
    required this.repository,
    required this.logger,
  });

  Future<(Map<String, dynamic>?, String?)> call({
    required List<Map<String, dynamic>> items,
    String? customerId,
    int loyaltyPointsToUse = 0,
    List<String> discountCodes = const [],
  }) async {
    try {
      logger.d('🧮 UseCase: Calcul vente (${items.length} articles)');

      if (items.isEmpty) {
        return (null, 'Le panier est vide');
      }

      return await repository.calculateSale(
        items: items,
        customerId: customerId,
        loyaltyPointsToUse: loyaltyPointsToUse,
        discountCodes: discountCodes,
      );
    } catch (e) {
      logger.e('❌ UseCase: Erreur calcul vente: $e');
      return (null, 'Erreur lors du calcul de la vente');
    }
  }
}
