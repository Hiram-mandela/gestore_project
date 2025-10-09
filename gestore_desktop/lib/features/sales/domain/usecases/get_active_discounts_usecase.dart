// ========================================
// lib/features/sales/domain/usecases/get_active_discounts_usecase.dart
// Use case pour récupérer les remises actives
// ========================================

import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

import '../entities/discount_entity.dart';
import '../repositories/sales_repository.dart';

@lazySingleton
class GetActiveDiscountsUseCase {
  final SalesRepository repository;
  final Logger logger;

  GetActiveDiscountsUseCase({
    required this.repository,
    required this.logger,
  });

  Future<(List<DiscountEntity>?, String?)> call() async {
    try {
      logger.d('🎁 UseCase: Récupération remises actives');
      return await repository.getActiveDiscounts();
    } catch (e) {
      logger.e('❌ UseCase: Erreur récupération remises: $e');
      return (null, 'Erreur lors de la récupération des remises');
    }
  }
}

// ==================== GET DISCOUNT BY ID ====================

@lazySingleton
class GetDiscountByIdUseCase {
  final SalesRepository repository;
  final Logger logger;

  GetDiscountByIdUseCase({
    required this.repository,
    required this.logger,
  });

  Future<(DiscountEntity?, String?)> call(String id) async {
    try {
      logger.d('🎁 UseCase: Récupération remise $id');
      return await repository.getDiscountById(id);
    } catch (e) {
      logger.e('❌ UseCase: Erreur récupération remise: $e');
      return (null, 'Erreur lors de la récupération de la remise');
    }
  }
}