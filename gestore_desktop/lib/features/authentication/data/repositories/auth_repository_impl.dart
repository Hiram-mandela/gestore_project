// ========================================
// features/authentication/data/repositories/auth_repository_impl.dart
// VERSION FINALE CORRIGÉE
// ========================================
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../../../core/errors/failures.dart';
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

  AuthRepositoryImpl(
      this.remoteDataSource,
      this.localDataSource,
      this.networkInfo,
      this.logger,
      );

  @override
  Future<Either<Failure, UserEntity>> login({
    required String username,
    required String password,
  }) async {
    try {
      // Vérifier la connexion réseau
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        return left(const NetworkFailure(
          message: 'Aucune connexion internet disponible',
        ));
      }

      // Créer la requête
      final request = LoginRequestModel(
        username: username,
        password: password,
      );

      // Appeler l'API
      final response = await remoteDataSource.login(request);

      // Sauvegarder les tokens et l'utilisateur
      await localDataSource.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
      await localDataSource.saveUser(response.user);
      await localDataSource.setAuthStatus(true);

      logger.i('✅ Login réussi pour ${response.user.username}');

      return right(response.user.toEntity());
    } on DioException catch (e) {
      logger.e('❌ Erreur login: ${e.message}');

      if (e.response?.statusCode == 401) {
        return left(const AuthenticationFailure(
          message: 'Identifiants incorrects',
          statusCode: 401,
        ));
      } else if (e.response?.statusCode == 400) {
        return left(ValidationFailure(
          message: 'Données invalides',
          statusCode: 400,
          fieldErrors: e.response?.data is Map
              ? Map<String, List<String>>.from(
            e.response!.data.map(
                  (key, value) => MapEntry(
                key,
                (value as List).map((e) => e.toString()).toList(),
              ),
            ),
          )
              : null,
        ));
      }

      return left(ServerFailure(
        message: 'Erreur serveur: ${e.message}',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      logger.e('❌ Erreur inattendue login: $e');
      return left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Appeler l'API (même sans connexion, on continue)
      try {
        await remoteDataSource.logout();
      } catch (e) {
        logger.w('⚠️ Logout API échoué, continuation locale: $e');
      }

      // Nettoyer les données locales
      await Future.wait([
        localDataSource.clearTokens(),
        localDataSource.clearUser(),
        localDataSource.setAuthStatus(false),
      ]);

      logger.i('✅ Logout réussi');
      return right(null);
    } catch (e) {
      logger.e('❌ Erreur logout: $e');
      return left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> refreshToken() async {
    try {
      final refreshToken = await localDataSource.getRefreshToken();
      if (refreshToken == null) {
        return left(const AuthenticationFailure(
          message: 'Aucun refresh token disponible',
        ));
      }

      final tokens = await remoteDataSource.refreshToken(refreshToken);
      await localDataSource.saveTokens(
        accessToken: tokens['access']!,
        refreshToken: tokens['refresh']!,
      );

      logger.i('✅ Token rafraîchi');
      return right(null);
    } catch (e) {
      logger.e('❌ Erreur refresh token: $e');
      return left(const AuthenticationFailure(
        message: 'Impossible de rafraîchir le token',
      ));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      // D'abord essayer le cache
      final cachedUser = await localDataSource.getCachedUser();
      if (cachedUser != null) {
        logger.i('ℹ️ Utilisateur depuis le cache');
        return right(cachedUser.toEntity());
      }

      // Sinon appeler l'API
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        return left(const NetworkFailure(
          message: 'Aucune connexion disponible',
        ));
      }

      final user = await remoteDataSource.getCurrentUser();
      await localDataSource.saveUser(user);

      logger.i('✅ Utilisateur depuis l\'API');
      return right(user.toEntity());
    } catch (e) {
      logger.e('❌ Erreur getCurrentUser: $e');
      return left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final hasToken = await localDataSource.getAccessToken() != null;
      final authStatus = await localDataSource.getAuthStatus();

      final isAuth = hasToken && authStatus;
      logger.i('ℹ️ État authentification: $isAuth');

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
      await localDataSource.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
      return right(null);
    } catch (e) {
      return left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearTokens() async {
    try {
      await localDataSource.clearTokens();
      return right(null);
    } catch (e) {
      return left(CacheFailure(message: e.toString()));
    }
  }
}