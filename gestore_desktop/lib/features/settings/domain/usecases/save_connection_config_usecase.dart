// ==================== save_connection_config_usecase.dart ====================
// Fichier: lib/features/settings/domain/usecases/save_connection_config_usecase.dart

import 'package:equatable/equatable.dart';
import '../../../../core/network/connection_mode.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/settings_repository.dart';

/// Use case pour sauvegarder et appliquer une configuration de connexion
class SaveConnectionConfigUseCase implements UseCase<void, SaveConnectionParams> {
  final SettingsRepository repository;

  SaveConnectionConfigUseCase(this.repository);

  @override
  Future<(void, String?)> call(SaveConnectionParams params) async {
    // 1. Sauvegarder la configuration
    final (_, saveError) = await repository.saveConnectionConfig(params.config);
    if (saveError != null) {
      return (null, saveError);
    }

    // 2. Ajouter à l'historique
    await repository.addToConnectionHistory(params.config);

    // 3. Appliquer la configuration si demandé
    if (params.applyImmediately) {
      final (_, applyError) = await repository.applyConnectionConfig(params.config);
      if (applyError != null) {
        return (null, applyError);
      }
    }

    return (null, null);
  }
}

/// Paramètres pour sauvegarder une configuration
class SaveConnectionParams extends Equatable {
  final ConnectionConfig config;
  final bool applyImmediately;

  const SaveConnectionParams({
    required this.config,
    this.applyImmediately = true,
  });

  @override
  List<Object?> get props => [config, applyImmediately];
}