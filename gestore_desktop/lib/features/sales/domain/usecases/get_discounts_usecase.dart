// ========================================
// lib/features/sales/domain/usecases/get_discounts_usecase.dart
// Use case pour récupérer la liste paginée des remises
// ========================================

import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../entities/discount_entity.dart';
import '../repositories/sales_repository.dart';
import '../../../inventory/domain/entities/paginated_response_entity.dart';

@lazySingleton
class GetDiscountsUseCase {
  final SalesRepository repository;
  final Logger logger;

  GetDiscountsUseCase({
    required this.repository,
    required this.logger,
  });

  /// Récupère la liste paginée des remises avec filtres
  ///
  /// Paramètres :
  /// - [page] : Numéro de page (défaut 1)
  /// - [pageSize] : Nombre d'éléments par page (défaut 20)
  /// - [search] : Recherche par nom ou code
  /// - [discountType] : Filtre par type (percentage, fixed_amount, etc.)
  /// - [scope] : Filtre par portée (sale, category, article, customer)
  /// - [isActive] : Filtre par statut actif/inactif
  /// - [activeOnly] : Afficher uniquement les remises actuellement actives
  Future<(PaginatedResponseEntity<DiscountEntity>?, String?)> call({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? discountType,
    String? scope,
    bool? isActive,
    bool activeOnly = false,
  }) async {
    try {
      logger.d('🎁 UseCase: Récupération remises (page $page)');

      return await repository.getDiscounts(
        page: page,
        pageSize: pageSize,
        search: search,
        discountType: discountType,
        scope: scope,
        isActive: isActive,
        activeOnly: activeOnly,
      );
    } catch (e) {
      logger.e('❌ UseCase: Erreur récupération remises: $e');
      return (null, 'Erreur lors de la récupération des remises');
    }
  }
}