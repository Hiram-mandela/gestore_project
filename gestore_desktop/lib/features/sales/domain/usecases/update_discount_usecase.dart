// ========================================
// lib/features/sales/domain/usecases/update_discount_usecase.dart
// Use case pour modifier une remise/promotion
// ========================================

import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../entities/discount_entity.dart';
import '../repositories/sales_repository.dart';

@lazySingleton
class UpdateDiscountUseCase {
  final SalesRepository repository;
  final Logger logger;

  UpdateDiscountUseCase({
    required this.repository,
    required this.logger,
  });

  /// Met à jour une remise/promotion existante
  ///
  /// [id] : ID de la remise à modifier
  /// [data] : Champs à mettre à jour (même structure que création)
  Future<(DiscountEntity?, String?)> call(
      String id,
      Map<String, dynamic> data,
      ) async {
    try {
      logger.d('🎁 UseCase: Modification remise $id');
      logger.d('Data: $data');

      // Validation de l'ID
      if (id.isEmpty) {
        return (null, 'ID de la remise requis');
      }

      // Validation conditionnelle des types si fournis
      if (data.containsKey('discount_type')) {
        final validTypes = ['percentage', 'fixed_amount', 'buy_x_get_y', 'loyalty_points'];
        if (!validTypes.contains(data['discount_type'])) {
          return (null, 'Type de remise invalide');
        }
      }

      if (data.containsKey('scope')) {
        final validScopes = ['sale', 'category', 'article', 'customer'];
        if (!validScopes.contains(data['scope'])) {
          return (null, 'Portée de remise invalide');
        }
      }

      // Appel au repository
      final result = await repository.updateDiscount(id, data);

      if (result.$2 != null) {
        logger.e('❌ UseCase: Erreur modification remise: ${result.$2}');
        return result;
      }

      logger.i('✅ UseCase: Remise ${result.$1?.name} modifiée avec succès');
      return result;
    } catch (e) {
      logger.e('❌ UseCase: Exception modification remise: $e');
      return (null, 'Erreur lors de la modification de la remise');
    }
  }
}