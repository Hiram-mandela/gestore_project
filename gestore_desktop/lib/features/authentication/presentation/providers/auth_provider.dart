// ========================================
// lib/features/authentication/presentation/providers/auth_provider.dart
// VERSION MISE À JOUR - Support multi-magasins
// Date: 23 Octobre 2025
// ========================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../config/dependencies.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/store_info_entity.dart';
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
    sharedPreferences: getIt<SharedPreferences>(),
    logger: getIt<Logger>(),
  );
});

/// Notifier pour gérer l'état d'authentification
/// 🔴 VERSION MULTI-MAGASINS: Ajout gestion des magasins
class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final CheckAuthStatusUseCase checkAuthStatusUseCase;
  final SharedPreferences sharedPreferences;
  final Logger logger;

  // 🔴 Clé de stockage du dernier magasin sélectionné
  static const String _lastSelectedStoreKey = 'last_selected_store_id';

  AuthNotifier({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.checkAuthStatusUseCase,
    required this.sharedPreferences,
    required this.logger,
  }) : super(const AuthInitial());

  /// Vérifier l'état d'authentification au démarrage
  Future<void> checkAuthStatus() async {
    logger.i('🔍 Vérification état authentification...');

    state = const AuthLoading();

    try {
      final result = await checkAuthStatusUseCase(const NoParams());
      final error = result.$2;
      final isAuth = result.$1;

      if (error != null) {
        logger.e('❌ Erreur vérification: $error');
        state = const AuthUnauthenticated();
      } else if (isAuth == true) {
        // Récupérer l'utilisateur actuel
        final userResult = await getCurrentUserUseCase(const NoParams());
        final userError = userResult.$2;
        final user = userResult.$1;

        if (userError != null || user == null) {
          logger.e('❌ Impossible de récupérer l\'utilisateur');
          state = const AuthUnauthenticated();
        } else {
          logger.i('✅ Utilisateur authentifié: ${user.username}');

          // 🔴 INITIALISER LE CONTEXTE MULTI-MAGASINS
          final currentStore = _determineCurrentStore(user);

          state = AuthAuthenticated(
            user: user,
            currentStore: currentStore,
            isMultiStoreAdmin: user.isMultiStoreAdmin,
            availableStores: user.availableStores,
          );
        }
      } else {
        logger.i('ℹ️ Utilisateur non authentifié');
        state = const AuthUnauthenticated();
      }
    } catch (e) {
      logger.e('❌ Exception vérification auth: $e');
      state = const AuthUnauthenticated();
    }
  }

  /// Se connecter avec username et password
  Future<void> login({
    required String username,
    required String password,
  }) async {
    logger.i('🔐 Tentative de login pour: $username');

    state = const AuthLoading();

    try {
      final result = await loginUseCase(
        LoginParams(username: username, password: password),
      );

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

        // 🔴 INITIALISER LE CONTEXTE MULTI-MAGASINS
        final currentStore = _determineCurrentStore(user);

        state = AuthAuthenticated(
          user: user,
          currentStore: currentStore,
          isMultiStoreAdmin: user.isMultiStoreAdmin,
          availableStores: user.availableStores,
        );
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
      final error = result.$2;

      if (error != null) {
        logger.e('❌ Erreur déconnexion: $error');
        // Mais on déconnecte quand même localement
      }

      // 🔴 NETTOYER LE MAGASIN SÉLECTIONNÉ
      await _clearLastSelectedStore();

      logger.i('✅ Déconnexion réussie');
      state = const AuthUnauthenticated();
    } catch (e) {
      logger.e('❌ Exception déconnexion: $e');
      // Déconnexion locale quand même
      await _clearLastSelectedStore();
      state = const AuthUnauthenticated();
    }
  }

  /// 🔴 NOUVELLE MÉTHODE: Changer le magasin sélectionné (admins uniquement)
  Future<void> selectStore(String storeId) async {
    final currentState = state;

    if (currentState is! AuthAuthenticated) {
      logger.w('⚠️ Impossible de changer de magasin - non authentifié');
      return;
    }

    if (!currentState.isMultiStoreAdmin) {
      logger.w('⚠️ Impossible de changer de magasin - non admin multi-magasins');
      return;
    }

    // Trouver le magasin dans la liste des magasins disponibles
    final store = currentState.availableStores.firstWhere(
          (s) => s.id == storeId,
      orElse: () => throw Exception('Magasin non trouvé dans les magasins disponibles'),
    );

    logger.i('🏪 Changement de magasin vers: ${store.name}');

    // Sauvegarder le dernier magasin sélectionné
    await _saveLastSelectedStore(storeId);

    // Mettre à jour l'état avec le nouveau magasin
    state = currentState.copyWith(currentStore: store);

    logger.i('✅ Magasin changé avec succès');
  }

  /// 🔴 NOUVELLE MÉTHODE: Obtenir le magasin actuellement sélectionné
  StoreInfoEntity? getCurrentStore() {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      return currentState.currentStore;
    }
    return null;
  }

  /// 🔴 NOUVELLE MÉTHODE: Vérifier si l'utilisateur peut accéder à plusieurs magasins
  bool canAccessMultipleStores() {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      return currentState.canSwitchStore;
    }
    return false;
  }

  /// 🔴 MÉTHODE PRIVÉE: Déterminer le magasin initial au login
  StoreInfoEntity? _determineCurrentStore(UserEntity user) {
    // Cas 1: Employé assigné à un magasin
    if (user.assignedStore != null) {
      logger.d('📍 Magasin assigné: ${user.assignedStore!.name}');
      return user.assignedStore;
    }

    // Cas 2: Admin multi-magasins
    if (user.isMultiStoreAdmin && user.availableStores.isNotEmpty) {
      // Essayer de récupérer le dernier magasin sélectionné
      final lastStoreId = sharedPreferences.getString(_lastSelectedStoreKey);

      if (lastStoreId != null) {
        try {
          final lastStore = user.availableStores.firstWhere(
                (s) => s.id == lastStoreId,
          );
          logger.d('📍 Dernier magasin sélectionné restauré: ${lastStore.name}');
          return lastStore;
        } catch (e) {
          logger.w('⚠️ Dernier magasin non trouvé, sélection du premier');
        }
      }

      // Par défaut: premier magasin de la liste
      logger.d('📍 Premier magasin sélectionné par défaut: ${user.availableStores.first.name}');
      return user.availableStores.first;
    }

    // Cas 3: Aucun magasin (cas rare)
    logger.w('⚠️ Aucun magasin disponible pour cet utilisateur');
    return null;
  }

  /// 🔴 MÉTHODE PRIVÉE: Sauvegarder le dernier magasin sélectionné
  Future<void> _saveLastSelectedStore(String storeId) async {
    try {
      await sharedPreferences.setString(_lastSelectedStoreKey, storeId);
      logger.d('💾 Dernier magasin sauvegardé: $storeId');
    } catch (e) {
      logger.e('❌ Erreur sauvegarde magasin: $e');
    }
  }

  /// 🔴 MÉTHODE PRIVÉE: Nettoyer le dernier magasin sélectionné
  Future<void> _clearLastSelectedStore() async {
    try {
      await sharedPreferences.remove(_lastSelectedStoreKey);
      logger.d('🧹 Dernier magasin nettoyé');
    } catch (e) {
      logger.e('❌ Erreur nettoyage magasin: $e');
    }
  }

  /// Rafraîchir l'utilisateur actuel
  Future<void> refreshUser() async {
    if (state is! AuthAuthenticated) {
      logger.w('⚠️ Impossible de rafraîchir - non authentifié');
      return;
    }

    final currentState = state as AuthAuthenticated;
    logger.d('🔄 Rafraîchissement utilisateur...');

    try {
      final result = await getCurrentUserUseCase(const NoParams());
      final error = result.$2;
      final user = result.$1;

      if (error != null) {
        logger.e('❌ Erreur rafraîchissement: $error');
        // Garder l'état actuel
      } else if (user != null) {
        logger.i('✅ Utilisateur rafraîchi: ${user.username}');

        // 🔴 CONSERVER LE MAGASIN ACTUELLEMENT SÉLECTIONNÉ
        state = currentState.copyWith(
          user: user,
          isMultiStoreAdmin: user.isMultiStoreAdmin,
          availableStores: user.availableStores,
        );
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

/// 🔴 NOUVEAU PROVIDER: Magasin actuellement sélectionné
final currentStoreProvider = Provider<StoreInfoEntity?>((ref) {
  final authState = ref.watch(authProvider);
  if (authState is AuthAuthenticated) {
    return authState.currentStore;
  }
  return null;
});

/// 🔴 NOUVEAU PROVIDER: Vérifie si l'utilisateur est admin multi-magasins
final isMultiStoreAdminProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  if (authState is AuthAuthenticated) {
    return authState.isMultiStoreAdmin;
  }
  return false;
});

/// 🔴 NOUVEAU PROVIDER: Magasins disponibles
final availableStoresProvider = Provider<List<StoreInfoEntity>>((ref) {
  final authState = ref.watch(authProvider);
  if (authState is AuthAuthenticated) {
    return authState.availableStores;
  }
  return [];
});