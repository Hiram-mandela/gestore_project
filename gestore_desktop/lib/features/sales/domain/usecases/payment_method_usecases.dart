// ========================================
// lib/features/sales/domain/usecases/payment_method_usecases.dart
// Use cases pour les moyens de paiement
// ========================================

import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../entities/payment_method_entity.dart';
import '../repositories/sales_repository.dart';

// ==================== GET PAYMENT METHODS ====================

@lazySingleton
class GetPaymentMethodsUseCase {
  final SalesRepository repository;
  final Logger logger;

  GetPaymentMethodsUseCase({
    required this.repository,
    required this.logger,
  });

  Future<(List<PaymentMethodEntity>?, String?)> call({
    bool? isActive,
  }) async {
    try {
      logger.d('💳 UseCase: Récupération moyens de paiement');
      return await repository.getPaymentMethods(isActive: isActive);
    } catch (e) {
      logger.e('❌ UseCase: Erreur récupération moyens de paiement: $e');
      return (null, 'Erreur lors de la récupération des moyens de paiement');
    }
  }
}

// ==================== GET PAYMENT METHOD BY ID ====================

@lazySingleton
class GetPaymentMethodByIdUseCase {
  final SalesRepository repository;
  final Logger logger;

  GetPaymentMethodByIdUseCase({
    required this.repository,
    required this.logger,
  });

  Future<(PaymentMethodEntity?, String?)> call(String id) async {
    try {
      logger.d('💳 UseCase: Récupération moyen de paiement $id');
      return await repository.getPaymentMethodById(id);
    } catch (e) {
      logger.e('❌ UseCase: Erreur récupération moyen de paiement: $e');
      return (null, 'Erreur lors de la récupération du moyen de paiement');
    }
  }
}
