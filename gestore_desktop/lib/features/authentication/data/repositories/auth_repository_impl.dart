// ========================================
// AUTH REPOSITORY IMPLEMENTATION - VERSION CORRIGÉE
// Remplacer lib/features/authentication/data/repositories/auth_repository_impl.dart
// ========================================

import 'package:logger/logger.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/login_request_model.dart';

/// Implémentation du repository d'authentification
/// Utilise maintenant (Type?, String?) au lieu de Either<Failure, Type>
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
  Future<(UserEntity?, String?)> login({
    required String username,
    required String password,
  }) async {
    try {
      logger.i('🔐 Tentative de login pour: $username');

      final request = LoginRequestModel(username: username, password: password);
      final response = await remoteDataSource.login(request);

      // Sauvegarder les tokens
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

      await localDataSource.saveUser(response.user);
      await localDataSource.setAuthStatus(true);

      logger.i('✅ Login réussi pour ${response.user.username}');
      return (response.user.toEntity(), null);
    } catch (e) {
      logger.e('❌ Erreur login: $e');
      final errorMessage = _extractErrorMessage(e);
      return (null, errorMessage);
    }
  }

  @override
  Future<(void, String?)> logout() async {
    try {
      logger.i('🚪 Déconnexion...');

      await remoteDataSource.logout();
      await Future.wait([
        localDataSource.clearTokens(),
        apiClient.clearTokens(),
        localDataSource.clearUser(),
        localDataSource.setAuthStatus(false),
      ]);

      logger.i('✅ Déconnexion réussie');
      return (null, null);
    } catch (e) {
      logger.e('❌ Erreur logout: $e');
      // Même en cas d'erreur, nettoyer localement
      await Future.wait([
        localDataSource.clearTokens(),
        apiClient.clearTokens(),
        localDataSource.clearUser(),
        localDataSource.setAuthStatus(false),
      ]);
      return (null, null); // Pas d'erreur pour logout
    }
  }

  @override
  Future<(void, String?)> refreshToken() async {
    try {
      logger.d('🔄 Rafraîchissement du token...');

      final refreshToken = await localDataSource.getRefreshToken();
      if (refreshToken == null) {
        return (null, 'Aucun refresh token disponible');
      }

      final tokens = await remoteDataSource.refreshToken(refreshToken);

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

      logger.i('✅ Token rafraîchi');
      return (null, null);
    } catch (e) {
      logger.e('❌ Erreur refresh token: $e');
      return (null, _extractErrorMessage(e));
    }
  }

  @override
  Future<(UserEntity?, String?)> getCurrentUser() async {
    try {
      logger.d('📥 Récupération utilisateur actuel...');

      // Essayer le cache d'abord
      final cachedUser = await localDataSource.getCachedUser();
      if (cachedUser != null) {
        logger.i('ℹ️ Utilisateur depuis le cache');
        return (cachedUser.toEntity(), null);
      }

      // Sinon, appeler l'API
      final user = await remoteDataSource.getCurrentUser();
      await localDataSource.saveUser(user);

      logger.i('✅ Utilisateur depuis l\'API');
      return (user.toEntity(), null);
    } catch (e) {
      logger.e('❌ Erreur getCurrentUser: $e');
      return (null, _extractErrorMessage(e));
    }
  }

  @override
  Future<(bool?, String?)> isAuthenticated() async {
    try {
      final hasTokenInCache = apiClient.accessToken != null;
      final hasTokenInStorage = await localDataSource.getAccessToken() != null;
      final authStatus = await localDataSource.getAuthStatus();

      final isAuth = (hasTokenInCache || hasTokenInStorage) && authStatus;
      logger.d('ℹ️ État authentification: $isAuth');

      return (isAuth, null);
    } catch (e) {
      logger.e('❌ Erreur isAuthenticated: $e');
      return (false, null); // Par défaut, pas authentifié
    }
  }

  @override
  Future<(void, String?)> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
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
      return (null, null);
    } catch (e) {
      logger.e('❌ Erreur saveTokens: $e');
      return (null, _extractErrorMessage(e));
    }
  }

  @override
  Future<(void, String?)> clearTokens() async {
    try {
      await Future.wait([
        localDataSource.clearTokens(),
        apiClient.clearTokens(),
      ]);
      return (null, null);
    } catch (e) {
      logger.e('❌ Erreur clearTokens: $e');
      return (null, _extractErrorMessage(e));
    }
  }

  /// Extrait un message d'erreur lisible d'une exception
  String _extractErrorMessage(Object error) {
    final errorString = error.toString();

    if (errorString.contains('SocketException') ||
        errorString.contains('NetworkException')) {
      return 'Impossible de se connecter au serveur.';
    }

    if (errorString.contains('TimeoutException')) {
      return 'Délai d\'attente dépassé.';
    }

    if (errorString.contains('401')) {
      return 'Identifiants incorrects.';
    }

    if (errorString.contains('403')) {
      return 'Accès refusé.';
    }

    if (errorString.contains('500')) {
      return 'Erreur serveur. Réessayez plus tard.';
    }

    return 'Une erreur est survenue.';
  }
}