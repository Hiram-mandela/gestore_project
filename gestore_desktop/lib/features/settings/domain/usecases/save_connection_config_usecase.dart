// ========================================
// lib/features/settings/domain/usecases/save_connection_config_usecase.dart
// Use case pour sauvegarder et appliquer une configuration de connexion
// ========================================

import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/connection_mode.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/settings_repository.dart';

/// Use case pour sauvegarder et appliquer une configuration de connexion
class SaveConnectionConfigUseCase implements UseCase<void, SaveConnectionParams> {
  final SettingsRepository repository;

  SaveConnectionConfigUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveConnectionParams params) async {
    // 1. Sauvegarder la configuration
    final saveResult = await repository.saveConnectionConfig(params.config);

    // Vérifier si la sauvegarde a échoué
    return saveResult.fold(
          (failure) => left(failure), // Si erreur, retourner l'erreur
          (_) async {
        // 2. Ajouter à l'historique
        await repository.addToConnectionHistory(params.config);

        // 3. Appliquer la configuration si demandé
        if (params.applyImmediately) {
          return await repository.applyConnectionConfig(params.config);
        }

        return right(null);
      },
    );
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