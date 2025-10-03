// ========================================
// SETTINGS REPOSITORY - VERSION CORRIGÉE
// Remplacer lib/features/settings/domain/repositories/settings_repository.dart
// ========================================

import '../../../../core/network/connection_mode.dart';
import '../entities/connection_settings_entity.dart';

/// Interface du repository pour les paramètres
/// Utilise maintenant (Type?, String?) au lieu de Either<Failure, Type>
abstract class SettingsRepository {
  /// Obtenir la configuration de connexion actuelle
  Future<(ConnectionSettingsEntity?, String?)> getCurrentConnectionSettings();

  /// Sauvegarder une nouvelle configuration de connexion
  Future<(void, String?)> saveConnectionConfig(ConnectionConfig config);

  /// Valider une connexion (tester la connectivité)
  Future<(ConnectionValidationResult?, String?)> validateConnection(
      ConnectionConfig config,
      );

  /// Obtenir l'historique des connexions récentes
  Future<(List<ConnectionConfig>?, String?)> getConnectionHistory();

  /// Ajouter une connexion à l'historique
  Future<(void, String?)> addToConnectionHistory(ConnectionConfig config);

  /// Supprimer une connexion de l'historique
  Future<(void, String?)> removeFromConnectionHistory(int index);

  /// Effacer tout l'historique
  Future<(void, String?)> clearConnectionHistory();

  /// Obtenir le mode de connexion actuel
  Future<(ConnectionMode?, String?)> getCurrentConnectionMode();

  /// Appliquer une configuration (changer l'environnement de l'API)
  Future<(void, String?)> applyConnectionConfig(ConnectionConfig config);
}