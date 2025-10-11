// ========================================
// lib/features/sales/domain/usecases/create_payment_method_usecase.dart
// Use case pour créer un moyen de paiement
// ========================================

import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../entities/payment_method_entity.dart';
import '../repositories/sales_repository.dart';

@lazySingleton
class CreatePaymentMethodUseCase {
  final SalesRepository repository;
  final Logger logger;

  CreatePaymentMethodUseCase({
    required this.repository,
    required this.logger,
  });

  /// Crée un nouveau moyen de paiement
  ///
  /// Paramètres requis dans [data] :
  /// - name: String
  /// - payment_type: String ('cash', 'card', 'mobile_money', etc.)
  ///
  /// Paramètres optionnels :
  /// - description: String
  /// - requires_authorization: bool
  /// - max_amount: double
  /// - fee_percentage: double
  /// - integration_config: Map<String, dynamic>
  /// - is_active: bool
  Future<(PaymentMethodEntity?, String?)> call(
      Map<String, dynamic> data,
      ) async {
    try {
      logger.d('💳 UseCase: Création moyen de paiement');
      logger.d('Data: $data');

      // Validation des champs requis
      if (!data.containsKey('name') || data['name'].toString().isEmpty) {
        return (null, 'Le nom du moyen de paiement est requis');
      }

      if (!data.containsKey('payment_type') || data['payment_type'].toString().isEmpty) {
        return (null, 'Le type de paiement est requis');
      }

      // Validation du type de paiement
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

      // Appel au repository
      final result = await repository.createPaymentMethod(data);

      if (result.$2 != null) {
        logger.e('❌ UseCase: Erreur création moyen de paiement: ${result.$2}');
        return result;
      }

      logger.i('✅ UseCase: Moyen de paiement ${result.$1?.name} créé avec succès');
      return result;
    } catch (e) {
      logger.e('❌ UseCase: Exception création moyen de paiement: $e');
      return (null, 'Erreur lors de la création du moyen de paiement');
    }
  }
}