// ========================================
// lib/features/sales/domain/usecases/void_sale_usecase.dart
// Use case pour annuler une vente
// ========================================

import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

import '../entities/sale_detail_entity.dart';
import '../repositories/sales_repository.dart';

@lazySingleton
class VoidSaleUseCase {
  final SalesRepository repository;
  final Logger logger;

  VoidSaleUseCase({
    required this.repository,
    required this.logger,
  });

  Future<(SaleDetailEntity?, String?)> call({
    required String saleId,
    required String reason,
    String? authorizationCode,
  }) async {
    try {
      logger.d('🚫 UseCase: Annulation vente $saleId');

      if (reason.trim().isEmpty) {
        return (null, 'La raison de l\'annulation est requise');
      }

      return await repository.voidSale(
        saleId: saleId,
        reason: reason,
        authorizationCode: authorizationCode,
      );
    } catch (e) {
      logger.e('❌ UseCase: Erreur annulation vente: $e');
      return (null, 'Erreur lors de l\'annulation de la vente');
    }
  }
}