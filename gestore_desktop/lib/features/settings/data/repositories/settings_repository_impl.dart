// ========================================
// lib/features/settings/data/repositories/settings_repository_impl.dart
// VERSION CORRIGÉE - Utilisation de tuples simples (Type?, String?)
// ========================================

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../../../config/environment.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/connection_mode.dart';
import '../../domain/entities/connection_settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';

/// Implémentation du repository Settings
/// ✅ CORRECTION: Utilise des tuples simples (Type?, String?)
class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;
  final ApiClient apiClient;
  final Logger logger;

  SettingsRepositoryImpl(
      this.localDataSource,
      this.apiClient,
      this.logger,
      );

  @override
  Future<(ConnectionSettingsEntity?, String?)> getCurrentConnectionSettings() async {
    try {
      // Obtenir la config actuelle
      var config = await localDataSource.getCurrentConnectionConfig();

      // Si aucune config, utiliser localhost par défaut
      if (config == null) {
        config = ConnectionConfig.localhost();
        await localDataSource.saveConnectionConfig(config);
      }

      // Obtenir l'historique
      final history = await localDataSource.getConnectionHistory();

      // Obtenir la dernière validation
      final lastValidated = await localDataSource.getLastValidationDate();

      final settings = ConnectionSettingsEntity(
        currentConfig: config,
        recentConnections: history,
        lastValidated: lastValidated,
        isValidated: lastValidated != null,
      );

      return (settings, null);
    } catch (e) {
      logger.e('❌ Erreur récupération settings: $e');
      return (null, 'Erreur lors de la récupération des paramètres.');
    }
  }

  @override
  Future<(void, String?)> saveConnectionConfig(ConnectionConfig config) async {
    try {
      await localDataSource.saveConnectionConfig(config);
      logger.i('✅ Configuration sauvegardée: ${config.displayName}');
      return (null, null);
    } catch (e) {
      logger.e('❌ Erreur sauvegarde config: $e');
      return (null, 'Erreur lors de la sauvegarde de la configuration.');
    }
  }

  @override
  Future<(ConnectionValidationResult?, String?)> validateConnection(
      ConnectionConfig config,
      ) async {
    try {
      logger.i('🔍 Validation connexion: ${config.displayName}');

      // Créer un client Dio temporaire pour tester
      final testDio = Dio(BaseOptions(
        baseUrl: config.serverUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));

      // Essayer de ping l'API
      final response = await testDio.get('/health/');

      if (response.statusCode == 200) {
        logger.i('✅ Connexion validée avec succès');

        // Marquer comme validé
        await localDataSource.markConnectionValidated();

        return (
        ConnectionValidationResult(
          isValid: true,
          errorMessage: 'Connexion établie avec succès',
          responseTimeMs: response.extra['duration'] as int? ?? 0,
        ),
        null,
        );
      } else {
        logger.w('⚠️ Réponse inattendue: ${response.statusCode}');
        return (
        ConnectionValidationResult(
          isValid: false,
          errorMessage: 'Réponse inattendue du serveur',
          responseTimeMs: 0,
        ),
        null,
        );
      }
    } on DioException catch (e) {
      logger.e('❌ Erreur réseau: ${e.type}');

      String errorMessage;
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Délai de connexion dépassé';
          break;
        case DioExceptionType.badResponse:
          errorMessage = 'Serveur inaccessible';
          break;
        case DioExceptionType.cancel:
          errorMessage = 'Connexion annulée';
          break;
        case DioExceptionType.unknown:
        default:
          errorMessage = 'Impossible de se connecter au serveur';
          break;
      }

      return (
      ConnectionValidationResult(
        isValid: false,
        errorMessage: errorMessage,
        responseTimeMs: 0,
      ),
      null,
      );
    } catch (e) {
      logger.e('❌ Erreur validation: $e');
      return (
      ConnectionValidationResult(
        isValid: false,
        errorMessage: 'Erreur lors de la validation',
        responseTimeMs: 0,
      ),
      null,
      );
    }
  }

  @override
  Future<(List<ConnectionConfig>?, String?)> getConnectionHistory() async {
    try {
      final history = await localDataSource.getConnectionHistory();
      return (history, null);
    } catch (e) {
      logger.e('❌ Erreur récupération historique: $e');
      return (null, 'Erreur lors de la récupération de l\'historique.');
    }
  }

  @override
  Future<(void, String?)> addToConnectionHistory(ConnectionConfig config) async {
    try {
      await localDataSource.addToConnectionHistory(config);
      return (null, null);
    } catch (e) {
      logger.e('❌ Erreur ajout historique: $e');
      return (null, 'Erreur lors de l\'ajout à l\'historique.');
    }
  }

  @override
  Future<(void, String?)> removeFromConnectionHistory(int index) async {
    try {
      await localDataSource.removeFromConnectionHistory(index);
      return (null, null);
    } catch (e) {
      logger.e('❌ Erreur suppression historique: $e');
      return (null, 'Erreur lors de la suppression de l\'historique.');
    }
  }

  @override
  Future<(void, String?)> clearConnectionHistory() async {
    try {
      await localDataSource.clearConnectionHistory();
      return (null, null);
    } catch (e) {
      logger.e('❌ Erreur effacement historique: $e');
      return (null, 'Erreur lors de l\'effacement de l\'historique.');
    }
  }

  @override
  Future<(ConnectionMode?, String?)> getCurrentConnectionMode() async {
    try {
      var mode = await localDataSource.getCurrentConnectionMode();

      // Si aucun mode défini, utiliser localhost par défaut
      if (mode == null) {
        mode = ConnectionMode.localhost;
      }

      return (mode, null);
    } catch (e) {
      logger.e('❌ Erreur récupération mode: $e');
      return (null, 'Erreur lors de la récupération du mode.');
    }
  }

  @override
  Future<(void, String?)> applyConnectionConfig(ConnectionConfig config) async {
    try {
      logger.i('🔄 Application de la configuration: ${config.displayName}');

      // Créer le nouvel environnement
      final newEnvironment = AppEnvironment.fromConnectionConfig(config);

      // Mettre à jour l'environnement global
      AppEnvironment.setCurrent(newEnvironment);

      // Mettre à jour l'ApiClient avec le nouvel environnement
      apiClient.updateEnvironment(newEnvironment);

      logger.i('✅ Configuration appliquée avec succès');
      logger.i('📡 Nouvelle URL API: ${newEnvironment.apiBaseUrl}');

      return (null, null);
    } catch (e) {
      logger.e('❌ Erreur application config: $e');
      return (null, 'Erreur lors de l\'application de la configuration.');
    }
  }
}