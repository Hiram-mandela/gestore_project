// ========================================
// lib/features/sales/domain/usecases/delete_payment_method_usecase.dart
// Use case pour supprimer un moyen de paiement
// ========================================

import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../repositories/sales_repository.dart';

@lazySingleton
class DeletePaymentMethodUseCase {
  final SalesRepository repository;
  final Logger logger;

  DeletePaymentMethodUseCase({
    required this.repository,
    required this.logger,
  });

  /// Supprime un moyen de paiement
  ///
  /// [id] : ID du moyen de paiement à supprimer
  ///
  /// Note: La suppression peut échouer si le moyen de paiement
  /// est utilisé dans des transactions existantes
  Future<(void, String?)> call(String id) async {
    try {
      logger.d('💳 UseCase: Suppression moyen de paiement $id');

      // Validation de l'ID
      if (id.isEmpty) {
        return (null, 'ID du moyen de paiement requis');
      }

      // Appel au repository
      final result = await repository.deletePaymentMethod(id);

      if (result.$2 != null) {
        logger.e('❌ UseCase: Erreur suppression moyen de paiement: ${result.$2}');
        return result;
      }

      logger.i('✅ UseCase: Moyen de paiement supprimé avec succès');
      return (null, null);
    } catch (e) {
      logger.e('❌ UseCase: Exception suppression moyen de paiement: $e');
      return (null, 'Erreur lors de la suppression du moyen de paiement');
    }
  }
}