// ========================================
// lib/features/sales/domain/usecases/delete_discount_usecase.dart
// Use case pour supprimer une remise/promotion
// ========================================

import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../repositories/sales_repository.dart';

@lazySingleton
class DeleteDiscountUseCase {
  final SalesRepository repository;
  final Logger logger;

  DeleteDiscountUseCase({
    required this.repository,
    required this.logger,
  });

  /// Supprime une remise/promotion
  ///
  /// [id] : ID de la remise à supprimer
  ///
  /// Note: La suppression peut échouer si la remise est utilisée
  /// dans des ventes existantes
  Future<(void, String?)> call(String id) async {
    try {
      logger.d('🎁 UseCase: Suppression remise $id');

      // Validation de l'ID
      if (id.isEmpty) {
        return (null, 'ID de la remise requis');
      }

      // Appel au repository
      final result = await repository.deleteDiscount(id);

      if (result.$2 != null) {
        logger.e('❌ UseCase: Erreur suppression remise: ${result.$2}');
        return result;
      }

      logger.i('✅ UseCase: Remise supprimée avec succès');
      return (null, null);
    } catch (e) {
      logger.e('❌ UseCase: Exception suppression remise: $e');
      return (null, 'Erreur lors de la suppression de la remise');
    }
  }
}