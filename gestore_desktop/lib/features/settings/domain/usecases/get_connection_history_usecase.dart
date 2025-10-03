// ==================== get_connection_history_usecase.dart ====================
// Fichier: lib/features/settings/domain/usecases/get_connection_history_usecase.dart

import '../../../../core/network/connection_mode.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/settings_repository.dart';

/// Use case pour obtenir l'historique des connexions
class GetConnectionHistoryUseCase
    implements UseCase<List<ConnectionConfig>, NoParams> {
  final SettingsRepository repository;

  GetConnectionHistoryUseCase(this.repository);

  @override
  Future<(List<ConnectionConfig>?, String?)> call(NoParams params) async {
    return await repository.getConnectionHistory();
  }
}