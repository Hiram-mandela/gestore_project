// ========================================
// lib/features/sales/domain/usecases/get_sale_detail_usecase.dart
// Use case pour récupérer le détail d'une vente
// ========================================

import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

import '../entities/sale_detail_entity.dart';
import '../repositories/sales_repository.dart';

@lazySingleton
class GetSaleDetailUseCase {
  final SalesRepository repository;
  final Logger logger;

  GetSaleDetailUseCase({
    required this.repository,
    required this.logger,
  });

  Future<(SaleDetailEntity?, String?)> call(String saleId) async {
    try {
      logger.d('📄 UseCase: Récupération détail vente $saleId');
      return await repository.getSaleDetail(saleId);
    } catch (e) {
      logger.e('❌ UseCase: Erreur récupération détail vente: $e');
      return (null, 'Erreur lors de la récupération du détail de la vente');
    }
  }
}