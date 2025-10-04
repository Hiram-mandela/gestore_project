// ========================================
// lib/features/authentication/presentation/providers/auth_provider.dart
// VERSION CORRIGÉE - Utilisation de .$1 et .$2 pour les tuples
// ========================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../../config/dependencies.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/check_auth_status_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import 'auth_state.dart';

/// Provider pour l'état d'authentification
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    loginUseCase: getIt<LoginUseCase>(),
    logoutUseCase: getIt<LogoutUseCase>(),
    getCurrentUserUseCase: getIt<GetCurrentUserUseCase>(),
    checkAuthStatusUseCase: getIt<CheckAuthStatusUseCase>(),
    logger: getIt<Logger>(),
  );
});

/// Notifier pour gérer l'état d'authentification
class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final CheckAuthStatusUseCase checkAuthStatusUseCase;
  final Logger logger;

  AuthNotifier({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.checkAuthStatusUseCase,
    required this.logger,
  }) : super(const AuthInitial());

  /// Vérifier l'état d'authentification au démarrage
  Future<void> checkAuthStatus() async {
    logger.i('🔍 Vérification état authentification...');

    state = const AuthLoading();

    try {
      final result = await checkAuthStatusUseCase(const NoParams());

      // ✅ CORRECTION: Utiliser .$2 pour l'erreur et .$1 pour les données
      final error = result.$2;
      final isAuthenticated = result.$1;

      if (error != null) {
        // Il y a une erreur
        logger.e('❌ Erreur vérification auth: $error');
        state = const AuthUnauthenticated();
      } else if (isAuthenticated == true) {
        // Authentifié - Charger l'utilisateur
        logger.i('✅ Utilisateur authentifié - Chargement des données...');
        await _loadCurrentUser();
      } else {
        // Non authentifié
        logger.i('ℹ️ Utilisateur non authentifié');
        state = const AuthUnauthenticated();
      }
    } catch (e) {
      logger.e('❌ Exception vérification auth: $e');
      state = const AuthUnauthenticated();
    }
  }

  /// Charger l'utilisateur actuel
  Future<void> _loadCurrentUser() async {
    try {
      final result = await getCurrentUserUseCase(const NoParams());

      // ✅ CORRECTION: Utiliser .$2 pour l'erreur et .$1 pour les données
      final error = result.$2;
      final user = result.$1;

      if (error != null) {
        logger.e('❌ Erreur chargement utilisateur: $error');
        state = const AuthUnauthenticated();
      } else if (user != null) {
        logger.i('✅ Utilisateur chargé: ${user.username}');
        state = AuthAuthenticated(user: user);
      } else {
        logger.w('⚠️ Aucun utilisateur retourné');
        state = const AuthUnauthenticated();
      }
    } catch (e) {
      logger.e('❌ Exception chargement utilisateur: $e');
      state = const AuthUnauthenticated();
    }
  }

  /// Se connecter
  Future<void> login({
    required String username,
    required String password,
  }) async {
    logger.i('🔐 Tentative de connexion pour: $username');

    state = const AuthLoading();

    try {
      final params = LoginParams(username: username, password: password);
      final result = await loginUseCase(params);

      // ✅ CORRECTION: Utiliser .$2 pour l'erreur et .$1 pour les données
      final error = result.$2;
      final user = result.$1;

      if (error != null) {
        // Il y a une erreur
        logger.e('❌ Erreur connexion: $error');
        state = AuthError(message: error);

        // Revenir à unauthenticated après 3 secondes
        await Future.delayed(const Duration(seconds: 3));
        if (state is AuthError) {
          state = const AuthUnauthenticated();
        }
      } else if (user != null) {
        // Connexion réussie
        logger.i('✅ Connexion réussie pour ${user.username}');
        state = AuthAuthenticated(user: user);
      } else {
        // Cas improbable mais possible
        logger.w('⚠️ Connexion sans utilisateur ni erreur');
        state = const AuthError(message: 'Erreur inconnue lors de la connexion');

        await Future.delayed(const Duration(seconds: 3));
        if (state is AuthError) {
          state = const AuthUnauthenticated();
        }
      }
    } catch (e) {
      logger.e('❌ Exception connexion: $e');
      state = AuthError(message: 'Une erreur inattendue est survenue');

      await Future.delayed(const Duration(seconds: 3));
      if (state is AuthError) {
        state = const AuthUnauthenticated();
      }
    }
  }

  /// Se déconnecter
  Future<void> logout() async {
    logger.i('🚪 Déconnexion...');

    state = const AuthLoading();

    try {
      final result = await logoutUseCase(const NoParams());

      // ✅ CORRECTION: Utiliser .$2 pour l'erreur
      final error = result.$2;

      if (error != null) {
        logger.e('❌ Erreur déconnexion: $error');
        // Mais on déconnecte quand même localement
      }

      logger.i('✅ Déconnexion réussie');
      state = const AuthUnauthenticated();
    } catch (e) {
      logger.e('❌ Exception déconnexion: $e');
      // Déconnexion locale quand même
      state = const AuthUnauthenticated();
    }
  }

  /// Rafraîchir l'utilisateur actuel
  Future<void> refreshUser() async {
    if (state is! AuthAuthenticated) {
      logger.w('⚠️ Impossible de rafraîchir - non authentifié');
      return;
    }

    logger.d('🔄 Rafraîchissement utilisateur...');

    try {
      final result = await getCurrentUserUseCase(const NoParams());

      // ✅ CORRECTION: Utiliser .$2 pour l'erreur et .$1 pour les données
      final error = result.$2;
      final user = result.$1;

      if (error != null) {
        logger.e('❌ Erreur rafraîchissement: $error');
        // Garder l'état actuel
      } else if (user != null) {
        logger.i('✅ Utilisateur rafraîchi: ${user.username}');
        state = AuthAuthenticated(user: user);
      }
    } catch (e) {
      logger.e('❌ Exception rafraîchissement: $e');
      // Garder l'état actuel
    }
  }

  /// Réinitialiser l'état d'erreur
  void clearError() {
    if (state is AuthError) {
      logger.d('🧹 Nettoyage de l\'erreur');
      state = const AuthUnauthenticated();
    }
  }

  /// Obtenir l'utilisateur actuel (si authentifié)
  UserEntity? get currentUser {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      return currentState.user;
    }
    return null;
  }

  /// Vérifier si l'utilisateur est authentifié
  bool get isAuthenticated {
    return state is AuthAuthenticated;
  }

  /// Vérifier si en cours de chargement
  bool get isLoading {
    return state is AuthLoading;
  }
}


/// Provider pour l'utilisateur actuel
final currentUserProvider = Provider<UserEntity?>((ref) {
  final authState = ref.watch(authProvider);
  if (authState is AuthAuthenticated) {
    return authState.user;
  }
  return null;
});

/// Provider pour savoir si l'utilisateur est authentifié
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState is AuthAuthenticated;
});