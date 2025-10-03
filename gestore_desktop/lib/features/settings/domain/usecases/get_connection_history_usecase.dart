
// ========================================
// lib/features/settings/domain/usecases/get_connection_history_usecase.dart
// Use case pour obtenir l'historique des connexions
// ========================================

import '../../../../core/errors/failures.dart';
import '../../../../core/network/connection_mode.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/settings_repository.dart';

/// Use case pour obtenir l'historique des connexions
class GetConnectionHistoryUseCase
    implements UseCase<List<ConnectionConfig>, NoParams> {
  final SettingsRepository repository;

  GetConnectionHistoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<ConnectionConfig>>> call(NoParams params) async {
    return await repository.getConnectionHistory();
  }
}