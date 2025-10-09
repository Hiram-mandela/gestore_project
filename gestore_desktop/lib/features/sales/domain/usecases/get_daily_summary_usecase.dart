// ========================================
// lib/features/sales/domain/usecases/get_daily_summary_usecase.dart
// Use case pour récupérer le résumé quotidien
// ========================================

import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

import '../repositories/sales_repository.dart';

@lazySingleton
class GetDailySummaryUseCase {
  final SalesRepository repository;
  final Logger logger;

  GetDailySummaryUseCase({
    required this.repository,
    required this.logger,
  });

  Future<(Map<String, dynamic>?, String?)> call() async {
    try {
      logger.d('📊 UseCase: Récupération résumé quotidien');
      return await repository.getDailySummary();
    } catch (e) {
      logger.e('❌ UseCase: Erreur récupération résumé: $e');
      return (null, 'Erreur lors de la récupération du résumé');
    }
  }
}