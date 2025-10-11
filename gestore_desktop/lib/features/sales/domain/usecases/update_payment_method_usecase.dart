// ========================================
// lib/features/sales/domain/usecases/update_payment_method_usecase.dart
// Use case pour modifier un moyen de paiement
// ========================================

import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../entities/payment_method_entity.dart';
import '../repositories/sales_repository.dart';

@lazySingleton
class UpdatePaymentMethodUseCase {
  final SalesRepository repository;
  final Logger logger;

  UpdatePaymentMethodUseCase({
    required this.repository,
    required this.logger,
  });

  /// Met à jour un moyen de paiement existant
  ///
  /// [id] : ID du moyen de paiement à modifier
  /// [data] : Champs à mettre à jour (même structure que création)
  Future<(PaymentMethodEntity?, String?)> call(
      String id,
      Map<String, dynamic> data,
      ) async {
    try {
      logger.d('💳 UseCase: Modification moyen de paiement $id');
      logger.d('Data: $data');

      // Validation de l'ID
      if (id.isEmpty) {
        return (null, 'ID du moyen de paiement requis');
      }

      // Si payment_type est fourni, le valider
      if (data.containsKey('payment_type')) {
        final validTypes = [
          'cash',
          'card',
          'mobile_money',
          'check',
          'credit',
          'voucher',
          'loyalty_points'
        ];

        if (!validTypes.contains(data['payment_type'])) {
          return (null, 'Type de paiement invalide');
        }
      }

      // Appel au repository
      final result = await repository.updatePaymentMethod(id, data);

      if (result.$2 != null) {
        logger.e('❌ UseCase: Erreur modification moyen de paiement: ${result.$2}');
        return result;
      }

      logger.i('✅ UseCase: Moyen de paiement ${result.$1?.name} modifié avec succès');
      return result;
    } catch (e) {
      logger.e('❌ UseCase: Exception modification moyen de paiement: $e');
      return (null, 'Erreur lors de la modification du moyen de paiement');
    }
  }
}