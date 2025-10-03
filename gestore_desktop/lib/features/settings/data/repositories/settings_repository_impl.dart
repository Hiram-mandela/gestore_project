// ========================================
// lib/features/settings/data/repositories/settings_repository_impl.dart
// Implémentation du repository Settings
// ========================================

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../../../config/environment.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/connection_mode.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/connection_settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';

/// Implémentation du repository Settings
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
  Future<Either<Failure, ConnectionSettingsEntity>>
  getCurrentConnectionSettings() async {
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

      return right(ConnectionSettingsEntity(
        currentConfig: config,
        recentConnections: history,
        lastValidated: lastValidated,
        isValidated: lastValidated != null,
      ));
    } catch (e) {
      logger.e('❌ Erreur récupération settings: $e');
      return left(CacheFailure(
        message: 'Erreur lors de la récupération des paramètres.',
        error: e,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> saveConnectionConfig(
      ConnectionConfig config,
      ) async {
    try {
      await localDataSource.saveConnectionConfig(config);
      logger.i('✅ Configuration sauvegardée: ${config.displayName}');
      return right(null);
    } catch (e) {
      logger.e('❌ Erreur sauvegarde config: $e');
      return left(CacheFailure(
        message: 'Erreur lors de la sauvegarde de la configuration.',
        error: e,
      ));
    }
  }

  @override
  Future<Either<Failure, ConnectionValidationResult>> validateConnection(
      ConnectionConfig config,
      ) async {
    try {
      logger.i('🔍 Validation connexion: ${config.fullApiUrl}');

      // Créer un Dio temporaire pour tester la connexion
      final testDio = Dio(
        BaseOptions(
          baseUrl: config.fullApiUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      // Mesurer le temps de réponse
      final startTime = DateTime.now();

      try {
        // Tester avec l'endpoint health ou un endpoint simple
        final response = await testDio.get('/health/');

        final responseTime = DateTime.now().difference(startTime).inMilliseconds;

        if (response.statusCode == 200 || response.statusCode == 404) {
          // 200 = OK, 404 = serveur répond mais endpoint pas trouvé (c'est OK)
          logger.i('✅ Connexion validée en ${responseTime}ms');

          // Marquer comme validé
          await localDataSource.markConnectionValidated();

          return right(ConnectionValidationResult.success(
            responseTimeMs: responseTime,
          ));
        } else {
          return right(ConnectionValidationResult.failure(
            'Le serveur a répondu avec le code ${response.statusCode}.',
          ));
        }
      } on DioException catch (e) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          return right(ConnectionValidationResult.failure(
            'Délai d\'attente dépassé. Le serveur ne répond pas.',
          ));
        } else if (e.type == DioExceptionType.connectionError) {
          return right(ConnectionValidationResult.failure(
            'Impossible de se connecter au serveur.\n'
                'Vérifiez l\'adresse IP et le port.',
          ));
        } else {
          return right(ConnectionValidationResult.failure(
            'Erreur de connexion: ${e.message}',
          ));
        }
      }
    } catch (e) {
      logger.e('❌ Erreur validation: $e');
      return left(NetworkFailure(
        message: 'Erreur lors de la validation de la connexion.',
        error: e,
      ));
    }
  }

  @override
  Future<Either<Failure, List<ConnectionConfig>>>
  getConnectionHistory() async {
    try {
      final history = await localDataSource.getConnectionHistory();
      return right(history);
    } catch (e) {
      logger.e('❌ Erreur récupération historique: $e');
      return left(CacheFailure(
        message: 'Erreur lors de la récupération de l\'historique.',
        error: e,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> addToConnectionHistory(
      ConnectionConfig config,
      ) async {
    try {
      await localDataSource.addToConnectionHistory(config);
      return right(null);
    } catch (e) {
      logger.e('❌ Erreur ajout historique: $e');
      return left(CacheFailure(
        message: 'Erreur lors de l\'ajout à l\'historique.',
        error: e,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromConnectionHistory(int index) async {
    try {
      await localDataSource.removeFromConnectionHistory(index);
      return right(null);
    } catch (e) {
      logger.e('❌ Erreur suppression historique: $e');
      return left(CacheFailure(
        message: 'Erreur lors de la suppression de l\'historique.',
        error: e,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> clearConnectionHistory() async {
    try {
      await localDataSource.clearConnectionHistory();
      return right(null);
    } catch (e) {
      logger.e('❌ Erreur effacement historique: $e');
      return left(CacheFailure(
        message: 'Erreur lors de l\'effacement de l\'historique.',
        error: e,
      ));
    }
  }

  @override
  Future<Either<Failure, ConnectionMode>> getCurrentConnectionMode() async {
    try {
      var mode = await localDataSource.getCurrentConnectionMode();

      // Si aucun mode défini, utiliser localhost par défaut
      if (mode == null) {
        mode = ConnectionMode.localhost;
      }

      return right(mode);
    } catch (e) {
      logger.e('❌ Erreur récupération mode: $e');
      return left(CacheFailure(
        message: 'Erreur lors de la récupération du mode.',
        error: e,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> applyConnectionConfig(
      ConnectionConfig config,
      ) async {
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

      return right(null);
    } catch (e) {
      logger.e('❌ Erreur application config: $e');
      return left(UnknownFailure(
        message: 'Erreur lors de l\'application de la configuration.',
        error: e,
      ));
    }
  }
}