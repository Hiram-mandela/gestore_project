// ========================================
// lib/core/network/api_client.dart
// VERSION CORRIGÉE - Gestion intelligente des tokens JWT
// Utilise les Failures du fichier failures.dart existant
// ========================================
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../config/environment.dart';
import '../constants/api_endpoints.dart';
import '../constants/storage_keys.dart';
import '../errors/failures.dart';
import '../utils/jwt_helper.dart';

/// Client API avec gestion intelligente des tokens JWT
class ApiClient {
  late Dio _dio;
  final FlutterSecureStorage _secureStorage;
  final Logger _logger;
  final JwtHelper _jwtHelper;
  AppEnvironment _environment;

  // Cache des tokens
  String? _cachedAccessToken;
  String? _cachedRefreshToken;

  // Protection contre les refreshes multiples simultanés
  bool _isRefreshing = false;
  Completer<bool>? _refreshCompleter;

  // Buffer avant expiration pour refresh proactif (5 minutes)
  static const int _refreshBufferSeconds = 300;

  ApiClient({
    required FlutterSecureStorage secureStorage,
    required Logger logger,
    required JwtHelper jwtHelper,
    AppEnvironment? environment,
  })  : _secureStorage = secureStorage,
        _logger = logger,
        _jwtHelper = jwtHelper,
        _environment = environment ?? AppEnvironment.current {
    _dio = _createDio();
    _setupInterceptors();
    _loadTokensToCache();
  }

  // ==================== GESTION URL DYNAMIQUE ====================

  /// Mettre à jour l'environnement et l'URL de l'API
  void updateEnvironment(AppEnvironment newEnvironment) {
    _logger.i('🔄 Changement environnement: ${_environment.name} → ${newEnvironment.name}');
    _logger.i('📡 Nouvelle URL: ${newEnvironment.apiBaseUrl}');

    _environment = newEnvironment;
    _dio.options.baseUrl = newEnvironment.apiBaseUrl;
    _dio.options.connectTimeout = Duration(milliseconds: newEnvironment.connectTimeout);
    _dio.options.receiveTimeout = Duration(milliseconds: newEnvironment.receiveTimeout);

    _reconfigureLogging();
    _logger.i('✅ Environnement mis à jour');
  }

  AppEnvironment get currentEnvironment => _environment;
  String get currentApiUrl => _environment.apiBaseUrl;

  // ==================== CRÉATION DIO ====================

  Dio _createDio() {
    return Dio(
      BaseOptions(
        baseUrl: _environment.apiBaseUrl,
        connectTimeout: Duration(milliseconds: _environment.connectTimeout),
        receiveTimeout: Duration(milliseconds: _environment.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );
  }

  // ==================== INTERCEPTEURS ====================

  void _setupInterceptors() {
    // 1. Intercepteur d'authentification avec vérification proactive
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // ✅ Vérifier et rafraîchir AVANT la requête
          await _ensureValidToken();

          // Ajouter le token à la requête
          if (_cachedAccessToken != null && _cachedAccessToken!.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $_cachedAccessToken';
            _logger.d('🔑 Token ajouté à la requête: ${options.path}');
          }

          return handler.next(options);
        },
        onError: (error, handler) async {
          // ✅ Gérer 401 avec retry automatique
          if (error.response?.statusCode == 401) {
            _logger.w('⚠️ 401 Unauthorized - Tentative refresh token');

            // Tenter le refresh (avec protection race condition)
            if (await _refreshTokenWithLock()) {
              try {
                // Retry la requête avec le nouveau token
                final opts = error.requestOptions;
                opts.headers['Authorization'] = 'Bearer $_cachedAccessToken';
                final response = await _dio.fetch(opts);
                return handler.resolve(response);
              } catch (e) {
                _logger.e('❌ Échec retry après refresh: $e');
                return handler.next(error);
              }
            } else {
              _logger.e('❌ Refresh token échoué - Déconnexion requise');
              await clearTokens();
            }
          }
          return handler.next(error);
        },
      ),
    );

    // 2. Intercepteur de logs (si activé)
    if (_environment.enableLogging) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
        ),
      );
    }
  }

  void _reconfigureLogging() {
    _dio.interceptors.removeWhere((i) => i is PrettyDioLogger);
    if (_environment.enableLogging) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
        ),
      );
    }
  }

  // ==================== GESTION TOKENS (AMÉLIORÉE) ====================

  /// ✅ S'assurer que le token est valide avant requête
  Future<void> _ensureValidToken() async {
    // Si pas de token, rien à vérifier
    if (_cachedAccessToken == null || _cachedAccessToken!.isEmpty) {
      _logger.d('ℹ️ Aucun token en cache');
      return;
    }

    // ✅ Vérifier si le token va bientôt expirer
    if (_jwtHelper.willExpireSoon(_cachedAccessToken, bufferSeconds: _refreshBufferSeconds)) {
      final remainingTime = _jwtHelper.getRemainingTime(_cachedAccessToken);
      _logger.w('⚠️ Token expire bientôt (${remainingTime}s) - Refresh proactif');

      await _refreshTokenWithLock();
    } else {
      final remainingTime = _jwtHelper.getRemainingTime(_cachedAccessToken);
      _logger.d('✅ Token valide (${remainingTime}s restantes)');
    }
  }

  /// ✅ Refresh avec protection contre race conditions
  Future<bool> _refreshTokenWithLock() async {
    // Si un refresh est déjà en cours, attendre sa fin
    if (_isRefreshing) {
      _logger.d('⏳ Refresh déjà en cours - Attente...');
      return await _refreshCompleter!.future;
    }

    // Démarrer un nouveau refresh
    _isRefreshing = true;
    _refreshCompleter = Completer<bool>();

    try {
      final success = await _refreshToken();
      _refreshCompleter!.complete(success);
      return success;
    } catch (e) {
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      _isRefreshing = false;
      _refreshCompleter = null;
    }
  }

  /// ✅ Refresh token
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = _cachedRefreshToken;
      if (refreshToken == null || refreshToken.isEmpty) {
        _logger.w('⚠️ Aucun refresh token disponible');
        return false;
      }

      // Vérifier si le refresh token lui-même est expiré
      if (_jwtHelper.isTokenExpired(refreshToken)) {
        _logger.e('❌ Refresh token expiré - Déconnexion requise');
        await clearTokens();
        return false;
      }

      _logger.i('🔄 Rafraîchissement du token...');

      // Créer un Dio temporaire SANS intercepteurs pour éviter boucle infinie
      final tempDio = Dio(
        BaseOptions(
          baseUrl: _environment.apiBaseUrl,
          connectTimeout: Duration(milliseconds: _environment.connectTimeout),
          receiveTimeout: Duration(milliseconds: _environment.receiveTimeout),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      // ✅ Format correct pour Django
      final response = await tempDio.post(
        ApiEndpoints.authRefresh,
        data: {'refresh': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['access'] as String;

        // ✅ Django avec ROTATE_REFRESH_TOKENS retourne un nouveau refresh token
        final newRefreshToken = response.data['refresh'] as String? ?? refreshToken;

        await saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );

        // Vérifier la nouvelle expiration
        final expirationDate = _jwtHelper.getExpirationDate(newAccessToken);
        _logger.i('✅ Token rafraîchi - Expire le: $expirationDate');

        return true;
      }

      _logger.e('❌ Refresh échoué - Status: ${response.statusCode}');
      return false;
    } catch (e) {
      _logger.e('❌ Erreur refresh token: $e');
      return false;
    }
  }

  Future<void> _loadTokensToCache() async {
    try {
      _cachedAccessToken = await _secureStorage.read(key: StorageKeys.accessToken);
      _cachedRefreshToken = await _secureStorage.read(key: StorageKeys.refreshToken);

      if (_cachedAccessToken != null) {
        // Afficher l'expiration du token chargé
        final expirationDate = _jwtHelper.getExpirationDate(_cachedAccessToken);
        final remainingTime = _jwtHelper.getRemainingTime(_cachedAccessToken);
        _logger.i('✅ Token chargé - Expire le: $expirationDate (${remainingTime}s)');
      }
    } catch (e) {
      _logger.e('❌ Erreur chargement tokens: $e');
    }
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      await Future.wait([
        _secureStorage.write(key: StorageKeys.accessToken, value: accessToken),
        _secureStorage.write(key: StorageKeys.refreshToken, value: refreshToken),
      ]);

      _cachedAccessToken = accessToken;
      _cachedRefreshToken = refreshToken;

      // Afficher l'expiration
      final expirationDate = _jwtHelper.getExpirationDate(accessToken);
      _logger.i('✅ Tokens sauvegardés - Expire le: $expirationDate');
    } catch (e) {
      _logger.e('❌ Erreur sauvegarde tokens: $e');
      rethrow;
    }
  }

  Future<void> clearTokens() async {
    try {
      await Future.wait([
        _secureStorage.delete(key: StorageKeys.accessToken),
        _secureStorage.delete(key: StorageKeys.refreshToken),
      ]);

      _cachedAccessToken = null;
      _cachedRefreshToken = null;

      _logger.i('✅ Tokens supprimés');
    } catch (e) {
      _logger.e('❌ Erreur suppression tokens: $e');
      rethrow;
    }
  }

  String? get accessToken => _cachedAccessToken;
  String? get refreshToken => _cachedRefreshToken;

  /// ✅ Vérifier si le token actuel est valide
  bool get hasValidToken {
    if (_cachedAccessToken == null) return false;
    return !_jwtHelper.isTokenExpired(_cachedAccessToken);
  }

  // ==================== MÉTHODES HTTP ====================

  Future<Response> get(
      String path, {
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> post(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> put(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> patch(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> delete(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ==================== GESTION RÉPONSES/ERREURS ====================

  Response _handleResponse(Response response) {
    if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
      return response;
    }
    throw _createFailureFromResponse(response);
  }

  Failure _handleDioError(DioException error) {
    _logger.e('❌ Erreur Dio: ${error.type} - ${error.message}');

    // Si on a une réponse HTTP, traiter selon le code
    if (error.response != null) {
      return _createFailureFromResponse(error.response!);
    }

    // Sinon, gérer selon le type d'erreur Dio
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutFailure(
          message: 'Délai de connexion dépassé. Vérifiez votre réseau.',
        );

      case DioExceptionType.connectionError:
        return const NetworkFailure(
          message: 'Impossible de se connecter au serveur.\n'
              'Vérifiez votre configuration de connexion.',
        );

      case DioExceptionType.badCertificate:
        return const NetworkFailure(
          message: 'Erreur de certificat SSL. Connexion non sécurisée.',
        );

      case DioExceptionType.badResponse:
        return const ServerFailure(
          message: 'Réponse invalide du serveur.',
        );

      case DioExceptionType.cancel:
        return const NetworkFailure(
          message: 'Requête annulée.',
        );

      case DioExceptionType.unknown:
        if (error.message?.contains('SocketException') ?? false) {
          return const NetworkFailure(
            message: 'Pas de connexion internet.',
          );
        }
        return UnknownFailure(
          message: 'Erreur réseau: ${error.message ?? "Inconnue"}',
        );

      }
  }

  Failure _createFailureFromResponse(Response response) {
    final statusCode = response.statusCode ?? 0;
    final data = response.data;

    String message = 'Une erreur est survenue.';
    Map<String, List<String>>? fieldErrors;

    // Extraire le message d'erreur
    if (data is Map<String, dynamic>) {
      if (data.containsKey('detail')) {
        message = data['detail'].toString();
      } else if (data.containsKey('message')) {
        message = data['message'].toString();
      } else if (data.containsKey('error')) {
        message = data['error'].toString();
      }

      // Extraire les erreurs de champs pour ValidationFailure
      fieldErrors = _extractFieldErrors(data);
    } else if (data is String) {
      message = data;
    }

    // Créer le Failure approprié selon le code HTTP
    switch (statusCode) {
      case 400:
        return ValidationFailure(
          message: message,
          statusCode: statusCode,
          fieldErrors: fieldErrors,
        );

      case 401:
        return AuthenticationFailure(
          message: message.isEmpty ? 'Session expirée. Veuillez vous reconnecter.' : message,
          statusCode: statusCode,
        );

      case 403:
        return PermissionFailure(
          message: message.isEmpty ? 'Vous n\'avez pas les permissions nécessaires.' : message,
          statusCode: statusCode,
        );

      case 404:
        return NotFoundFailure(
          message: message.isEmpty ? 'Ressource introuvable.' : message,
          statusCode: statusCode,
        );

      case 409:
        return ConflictFailure(
          message: message,
          statusCode: statusCode,
        );

      case 422:
        return ValidationFailure(
          message: message,
          statusCode: statusCode,
          fieldErrors: fieldErrors,
        );

      case 500:
      case 502:
      case 503:
      case 504:
        return ServerFailure(
          message: message.isEmpty ? 'Erreur serveur. Veuillez réessayer plus tard.' : message,
          statusCode: statusCode,
        );

      default:
        if (statusCode >= 400 && statusCode < 500) {
          return ValidationFailure(
            message: message,
            statusCode: statusCode,
            fieldErrors: fieldErrors,
          );
        } else if (statusCode >= 500) {
          return ServerFailure(
            message: message,
            statusCode: statusCode,
          );
        }
        return UnknownFailure(
          message: message,
          statusCode: statusCode,
        );
    }
  }

  /// Extraire les erreurs de champs depuis la réponse API
  Map<String, List<String>>? _extractFieldErrors(Map<String, dynamic> responseData) {
    final errors = <String, List<String>>{};

    // Parcourir les clés de la réponse
    responseData.forEach((key, value) {
      // Ignorer les clés meta
      if (key == 'message' ||
          key == 'detail' ||
          key == 'error' ||
          key == 'non_field_errors' ||
          key == '_meta' ||
          key == 'status' ||
          key == 'code') {
        return;
      }

      // Convertir les erreurs de champ
      if (value is List) {
        errors[key] = value.map((e) => e.toString()).toList();
      } else if (value is String) {
        errors[key] = [value];
      } else if (value is Map) {
        // Gérer les erreurs de champs imbriqués
        errors[key] = [value.toString()];
      }
    });

    return errors.isNotEmpty ? errors : null;
  }

  // ==================== CLEANUP ====================

  void dispose() {
    _dio.close();
    _cachedAccessToken = null;
    _cachedRefreshToken = null;
    _logger.i('🔌 ApiClient disposed');
  }
}