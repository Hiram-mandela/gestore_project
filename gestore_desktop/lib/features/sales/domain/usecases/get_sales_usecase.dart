// ========================================
// lib/features/sales/domain/usecases/get_sales_usecase.dart
// Use case pour récupérer la liste des ventes
// ========================================

import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

import '../../../inventory/domain/entities/paginated_response_entity.dart';
import '../entities/sale_entity.dart';
import '../repositories/sales_repository.dart';

@lazySingleton
class GetSalesUseCase {
  final SalesRepository repository;
  final Logger logger;

  GetSalesUseCase({
    required this.repository,
    required this.logger,
  });

  Future<(PaginatedResponseEntity<SaleEntity>?, String?)> call({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? status,
    String? saleType,
    String? customerId,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? ordering,
  }) async {
    try {
      logger.d('📋 UseCase: Récupération ventes page $page');

      return await repository.getSales(
        page: page,
        pageSize: pageSize,
        search: search,
        status: status,
        saleType: saleType,
        customerId: customerId,
        dateFrom: dateFrom,
        dateTo: dateTo,
        ordering: ordering,
      );
    } catch (e) {
      logger.e('❌ UseCase: Erreur récupération ventes: $e');
      return (null, 'Erreur lors de la récupération des ventes');
    }
  }
}