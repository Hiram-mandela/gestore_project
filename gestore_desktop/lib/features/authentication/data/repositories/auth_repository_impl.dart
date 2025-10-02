// ========================================
// lib/features/authentication/data/repositories/auth_repository_impl.dart
// VERSION CORRIGÉE FINALE - Gestion d'erreurs complète
// ========================================
import 'package:logger/logger.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/login_request_model.dart';

/// Implémentation du repository d'authentification
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final Logger logger;
  final ApiClient apiClient;

  AuthRepositoryImpl(
      this.remoteDataSource,
      this.localDataSource,
      this.networkInfo,
      this.logger,
      this.apiClient,
      );

  @override
  Future<Either<Failure, UserEntity>> login({
    required String username,
    required String password,
  }) async {
    try {
      logger.i('🔐 Tentative de login pour: $username');

      // Vérifier la connexion réseau
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        logger.w('⚠️ Pas de connexion réseau');
        return left(const NetworkFailure(
          message: 'Aucune connexion internet disponible.',
        ));
      }

      // Créer la requête
      final request = LoginRequestModel(
        username: username,
        password: password,
      );

      // Appeler l'API via le remote datasource
      final response = await remoteDataSource.login(request);

      // Sauvegarder les tokens dans le storage ET le cache ApiClient
      await Future.wait([
        localDataSource.saveTokens(
          accessToken: response.accessToken,
          refreshToken: response.refreshToken,
        ),
        apiClient.saveTokens(
          accessToken: response.accessToken,
          refreshToken: response.refreshToken,
        ),
      ]);

      // Sauvegarder l'utilisateur et le statut
      await localDataSource.saveUser(response.user);
      await localDataSource.setAuthStatus(true);

      logger.i('✅ Login réussi pour ${response.user.username}');

      return right(response.user.toEntity());
    } on Failure catch (failure) {
      // Les Failures sont déjà créés par ApiClient._handleDioError()
      logger.e('❌ Erreur login (Failure): ${failure.message}');
      return left(failure);
    } on Exception catch (e) {
      // Attraper toutes les autres exceptions
      logger.e('❌ Erreur login (Exception): $e');

      // Transformer en Failure approprié
      if (e.toString().contains('SocketException') ||
          e.toString().contains('NetworkException')) {
        return left(const NetworkFailure(
          message: 'Impossible de se connecter au serveur.',
        ));
      }

      return left(UnknownFailure(
        message: 'Une erreur inattendue est survenue.',
        error: e,
      ));
    } catch (e) {
      // Attraper absolument tout le reste
      logger.e('❌ Erreur login (catch all): $e');
      return left(UnknownFailure(
        message: 'Une erreur inattendue est survenue.',
        error: e,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      logger.i('🚪 Début logout...');

      // Appeler l'API de logout (AVANT de supprimer les tokens)
      try {
        await remoteDataSource.logout();
        logger.i('✅ Logout API réussi');
      } catch (e) {
        logger.w('⚠️ Logout API échoué (continuons localement): $e');
        // On continue même si l'API échoue
      }

      // Nettoyer le storage ET le cache ApiClient
      await Future.wait([
        localDataSource.clearTokens(),
        apiClient.clearTokens(),
        localDataSource.clearUser(),
        localDataSource.setAuthStatus(false),
      ]);

      logger.i('✅ Logout réussi (storage + cache nettoyés)');
      return right(null);
    } on Failure catch (failure) {
      logger.e('❌ Erreur logout (Failure): ${failure.message}');
      // Même en cas d'erreur, on nettoie localement
      await _forceLocalCleanup();
      return left(failure);
    } catch (e) {
      logger.e('❌ Erreur logout: $e');
      // Même en cas d'erreur, on nettoie localement
      await _forceLocalCleanup();
      return left(UnknownFailure(message: e.toString()));
    }
  }

  /// Nettoyage local forcé en cas d'erreur
  Future<void> _forceLocalCleanup() async {
    try {
      await Future.wait([
        localDataSource.clearTokens(),
        apiClient.clearTokens(),
        localDataSource.clearUser(),
        localDataSource.setAuthStatus(false),
      ]);
      logger.i('✅ Nettoyage local forcé réussi');
    } catch (e) {
      logger.e('❌ Erreur nettoyage local forcé: $e');
    }
  }

  @override
  Future<Either<Failure, void>> refreshToken() async {
    try {
      logger.i('🔄 Tentative de refresh token...');

      final refreshToken = await localDataSource.getRefreshToken();
      if (refreshToken == null) {
        logger.w('⚠️ Aucun refresh token disponible');
        return left(const AuthenticationFailure(
          message: 'Aucun refresh token disponible.',
        ));
      }

      final tokens = await remoteDataSource.refreshToken(refreshToken);

      // Sauvegarder dans le storage ET dans le cache
      await Future.wait([
        localDataSource.saveTokens(
          accessToken: tokens['access']!,
          refreshToken: tokens['refresh']!,
        ),
        apiClient.saveTokens(
          accessToken: tokens['access']!,
          refreshToken: tokens['refresh']!,
        ),
      ]);

      logger.i('✅ Token rafraîchi (storage + cache)');
      return right(null);
    } on Failure catch (failure) {
      logger.e('❌ Erreur refresh token (Failure): ${failure.message}');
      return left(failure);
    } catch (e) {
      logger.e('❌ Erreur refresh token: $e');
      return left(const AuthenticationFailure(
        message: 'Impossible de rafraîchir le token.',
      ));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      logger.d('📥 Récupération utilisateur actuel...');

      // D'abord essayer le cache
      final cachedUser = await localDataSource.getCachedUser();
      if (cachedUser != null) {
        logger.i('ℹ️ Utilisateur depuis le cache');
        return right(cachedUser.toEntity());
      }

      // Sinon appeler l'API
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        logger.w('⚠️ Pas de connexion pour getCurrentUser');
        return left(const NetworkFailure(
          message: 'Aucune connexion disponible.',
        ));
      }

      final user = await remoteDataSource.getCurrentUser();
      await localDataSource.saveUser(user);

      logger.i('✅ Utilisateur depuis l\'API');
      return right(user.toEntity());
    } on Failure catch (failure) {
      logger.e('❌ Erreur getCurrentUser (Failure): ${failure.message}');
      return left(failure);
    } catch (e) {
      logger.e('❌ Erreur getCurrentUser: $e');
      return left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      // Vérifier dans le cache ApiClient D'ABORD (plus rapide)
      final hasTokenInCache = apiClient.accessToken != null;

      // Vérifier aussi dans le storage
      final hasTokenInStorage = await localDataSource.getAccessToken() != null;
      final authStatus = await localDataSource.getAuthStatus();

      final isAuth = (hasTokenInCache || hasTokenInStorage) && authStatus;

      logger.d(
        'ℹ️ État authentification: $isAuth (cache: $hasTokenInCache, storage: $hasTokenInStorage)',
      );

      return right(isAuth);
    } catch (e) {
      logger.e('❌ Erreur isAuthenticated: $e');
      return right(false);
    }
  }

  @override
  Future<Either<Failure, void>> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      // Sauvegarder dans le storage ET dans le cache
      await Future.wait([
        localDataSource.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        ),
        apiClient.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        ),
      ]);
      return right(null);
    } catch (e) {
      logger.e('❌ Erreur saveTokens: $e');
      return left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearTokens() async {
    try {
      // Supprimer du storage ET du cache
      await Future.wait([
        localDataSource.clearTokens(),
        apiClient.clearTokens(),
      ]);
      return right(null);
    } catch (e) {
      logger.e('❌ Erreur clearTokens: $e');
      return left(CacheFailure(message: e.toString()));
    }
  }
}