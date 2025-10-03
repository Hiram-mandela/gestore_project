// ========================================
// lib/features/settings/domain/repositories/settings_repository.dart
// Interface du repository Settings
// ========================================

import '../../../../core/errors/failures.dart';
import '../../../../core/network/connection_mode.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/connection_settings_entity.dart';

/// Interface du repository pour les paramètres
abstract class SettingsRepository {
  /// Obtenir la configuration de connexion actuelle
  Future<Either<Failure, ConnectionSettingsEntity>> getCurrentConnectionSettings();

  /// Sauvegarder une nouvelle configuration de connexion
  Future<Either<Failure, void>> saveConnectionConfig(ConnectionConfig config);

  /// Valider une connexion (tester la connectivité)
  Future<Either<Failure, ConnectionValidationResult>> validateConnection(
      ConnectionConfig config,
      );

  /// Obtenir l'historique des connexions récentes
  Future<Either<Failure, List<ConnectionConfig>>> getConnectionHistory();

  /// Ajouter une connexion à l'historique
  Future<Either<Failure, void>> addToConnectionHistory(ConnectionConfig config);

  /// Supprimer une connexion de l'historique
  Future<Either<Failure, void>> removeFromConnectionHistory(int index);

  /// Effacer tout l'historique
  Future<Either<Failure, void>> clearConnectionHistory();

  /// Obtenir le mode de connexion actuel
  Future<Either<Failure, ConnectionMode>> getCurrentConnectionMode();

  /// Appliquer une configuration (changer l'environnement de l'API)
  Future<Either<Failure, void>> applyConnectionConfig(ConnectionConfig config);
}