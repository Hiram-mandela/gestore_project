// ==================== validate_connection_usecase.dart ====================
// Fichier: lib/features/settings/domain/usecases/validate_connection_usecase.dart

import 'package:equatable/equatable.dart';
import '../../../../core/network/connection_mode.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/settings_repository.dart';

/// Use case pour valider une connexion
class ValidateConnectionUseCase
    implements UseCase<ConnectionValidationResult, ValidateConnectionParams> {
  final SettingsRepository repository;

  ValidateConnectionUseCase(this.repository);

  @override
  Future<(ConnectionValidationResult?, String?)> call(
      ValidateConnectionParams params,
      ) async {
    return await repository.validateConnection(params.config);
  }
}

/// Paramètres pour valider une connexion
class ValidateConnectionParams extends Equatable {
  final ConnectionConfig config;

  const ValidateConnectionParams({required this.config});

  @override
  List<Object?> get props => [config];
}