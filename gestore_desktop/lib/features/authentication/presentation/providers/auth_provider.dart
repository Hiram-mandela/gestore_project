// ========================================
// lib/features/authentication/presentation/providers/auth_provider.dart
// VERSION ROBUSTE - Sans erreurs null check
// ========================================
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../../../config/dependencies.dart';
import '../../../../core/errors/failures.dart';
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
      final result = await checkAuthStatusUseCase(NoParams());

      // Vérifier que le result n'est pas null
      if (result.isRight) {
        final isAuthenticated = result.right;
        if (isAuthenticated != null && isAuthenticated) {
          logger.i('✅ Utilisateur authentifié, récupération du profil...');
          await _loadCurrentUser();
        } else {
          logger.i('ℹ️ Utilisateur non authentifié');
          state = const AuthUnauthenticated();
        }
      } else {
        final failure = result.left;
        logger.e('❌ Erreur vérification auth: ${failure?.message ?? "Unknown error"}');
        state = const AuthUnauthenticated();
      }
    } catch (e) {
      logger.e('❌ Exception dans checkAuthStatus: $e');
      state = const AuthUnauthenticated();
    }
  }

  /// Charger l'utilisateur actuel
  Future<void> _loadCurrentUser() async {
    try {
      final result = await getCurrentUserUseCase(NoParams());

      if (result.isRight) {
        final user = result.right;
        if (user != null) {
          logger.i('✅ Utilisateur chargé: ${user.username}');
          state = AuthAuthenticated(user: user);
        } else {
          logger.e('❌ Utilisateur null après récupération');
          state = const AuthUnauthenticated();
        }
      } else {
        final failure = result.left;
        logger.e('❌ Erreur chargement utilisateur: ${failure?.message ?? "Unknown error"}');
        state = const AuthUnauthenticated();
      }
    } catch (e) {
      logger.e('❌ Exception dans _loadCurrentUser: $e');
      state = const AuthUnauthenticated();
    }
  }

  /// Se connecter
  Future<void> login({
    required String username,
    required String password,
  }) async {
    logger.i('🔐 Tentative de connexion pour $username...');

    state = const AuthLoading();

    try {
      final result = await loginUseCase(
        LoginParams(username: username, password: password),
      );

      if (result.isRight) {
        // Succès
        final user = result.right;
        if (user != null) {
          logger.i('✅ Connexion réussie: ${user.username}');
          state = AuthAuthenticated(user: user);
        } else {
          logger.e('❌ Utilisateur null après login');
          state = const AuthError(
            message: 'Erreur lors de la connexion.',
          );
        }
      } else {
        // Échec
        final failure = result.left;
        logger.e('❌ Échec connexion: ${failure?.message ?? "Unknown error"}');

        // Vérifier que failure n'est pas null
        if (failure != null) {
          if (failure is ValidationFailure && failure.fieldErrors != null) {
            state = AuthError(
              message: failure.message,
              fieldErrors: failure.fieldErrors,
            );
          } else {
            state = AuthError(message: failure.message);
          }
        } else {
          state = const AuthError(
            message: 'Une erreur est survenue lors de la connexion.',
          );
        }
      }
    } catch (e, stackTrace) {
      logger.e('❌ Exception dans login: $e');
      logger.e('StackTrace: $stackTrace');
      state = const AuthError(
        message: 'Une erreur inattendue est survenue.',
      );
    }
  }

  /// Se déconnecter
  Future<void> logout() async {
    logger.i('🚪 Déconnexion...');

    state = const AuthLoading();

    try {
      final result = await logoutUseCase(NoParams());

      if (result.isRight) {
        logger.i('✅ Déconnexion réussie');
        state = const AuthUnauthenticated();
      } else {
        final failure = result.left;
        logger.e('❌ Erreur déconnexion: ${failure?.message ?? "Unknown error"}');
        // Même en cas d'erreur, on déconnecte localement
        state = const AuthUnauthenticated();
      }
    } catch (e, stackTrace) {
      logger.e('❌ Exception dans logout: $e');
      logger.e('StackTrace: $stackTrace');
      // Même en cas d'erreur, on déconnecte localement
      state = const AuthUnauthenticated();
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

/// Provider pour obtenir l'utilisateur actuel
final currentUserProvider = Provider<UserEntity?>((ref) {
  final authState = ref.watch(authProvider);
  if (authState is AuthAuthenticated) {
    return authState.user;
  }
  return null;
});

/// Provider pour vérifier si authentifié
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState is AuthAuthenticated;
});