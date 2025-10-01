// ========================================
// features/authentication/presentation/providers/auth_provider.dart
// VERSION CORRIGÉE
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

    final result = await checkAuthStatusUseCase(NoParams());

    // Utiliser isLeft/isRight au lieu de fold
    if (result.isLeft) {
      final failure = result.left!;
      logger.e('❌ Erreur vérification auth: ${failure.message}');
      state = const AuthUnauthenticated();
    } else {
      final isAuthenticated = result.right!;
      if (isAuthenticated) {
        logger.i('✅ Utilisateur authentifié, récupération du profil...');
        _loadCurrentUser();
      } else {
        logger.i('ℹ️ Utilisateur non authentifié');
        state = const AuthUnauthenticated();
      }
    }
  }

  /// Charger l'utilisateur actuel
  Future<void> _loadCurrentUser() async {
    final result = await getCurrentUserUseCase(NoParams());

    if (result.isLeft) {
      final failure = result.left!;
      logger.e('❌ Erreur chargement utilisateur: ${failure.message}');
      state = const AuthUnauthenticated();
    } else {
      final user = result.right!;
      logger.i('✅ Utilisateur chargé: ${user.username}');
      state = AuthAuthenticated(user: user);
    }
  }

  /// Se connecter
  Future<void> login({
    required String username,
    required String password,
  }) async {
    logger.i('🔐 Tentative de connexion pour $username...');

    state = const AuthLoading();

    final result = await loginUseCase(
      LoginParams(username: username, password: password),
    );

    if (result.isLeft) {
      final failure = result.left!;
      logger.e('❌ Échec connexion: ${failure.message}');

      if (failure is ValidationFailure && failure.fieldErrors != null) {
        state = AuthError(
          message: failure.message,
          fieldErrors: failure.fieldErrors,
        );
      } else {
        state = AuthError(message: failure.message);
      }
    } else {
      final user = result.right!;
      logger.i('✅ Connexion réussie: ${user.username}');
      state = AuthAuthenticated(user: user);
    }
  }

  /// Se déconnecter
  Future<void> logout() async {
    logger.i('🚪 Déconnexion...');

    state = const AuthLoading();

    final result = await logoutUseCase(NoParams());

    if (result.isLeft) {
      final failure = result.left!;
      logger.e('❌ Erreur déconnexion: ${failure.message}');
      // Même en cas d'erreur, on déconnecte localement
      state = const AuthUnauthenticated();
    } else {
      logger.i('✅ Déconnexion réussie');
      state = const AuthUnauthenticated();
    }
  }

  /// Réinitialiser l'état d'erreur
  void clearError() {
    if (state is AuthError) {
      state = const AuthUnauthenticated();
    }
  }

  /// Obtenir l'utilisateur actuel (si authentifié)
  UserEntity? get currentUser {
    if (state is AuthAuthenticated) {
      return (state as AuthAuthenticated).user;
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