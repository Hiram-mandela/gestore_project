// ========================================
// lib/features/settings/domain/usecases/get_connection_config_usecase.dart
// Use case pour obtenir la configuration de connexion actuelle
// ========================================

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/connection_settings_entity.dart';
import '../repositories/settings_repository.dart';

/// Use case pour obtenir la configuration de connexion actuelle
class GetConnectionConfigUseCase
    implements UseCase<ConnectionSettingsEntity, NoParams> {
  final SettingsRepository repository;

  GetConnectionConfigUseCase(this.repository);

  @override
  Future<Either<Failure, ConnectionSettingsEntity>> call(
      NoParams params,
      ) async {
    return await repository.getCurrentConnectionSettings();
  }
}
