// ========================================
// AUTH REPOSITORY - VERSION CORRIGÉE
// Remplacer lib/features/authentication/domain/repositories/auth_repository.dart
// ========================================

import '../entities/user_entity.dart';

/// Interface du repository d'authentification
/// Utilise maintenant (Type?, String?) au lieu de Either<Failure, Type>
abstract class AuthRepository {
  /// Se connecter avec username et mot de passe
  /// Retourne (UserEntity?, String?) - user OU message d'erreur
  Future<(UserEntity?, String?)> login({
    required String username,
    required String password,
  });

  /// Se déconnecter
  /// Retourne (void, String?) - null OU message d'erreur
  Future<(void, String?)> logout();

  /// Rafraîchir le token d'accès
  /// Retourne (void, String?) - null OU message d'erreur
  Future<(void, String?)> refreshToken();

  /// Obtenir l'utilisateur actuellement connecté
  /// Retourne (UserEntity?, String?) - user OU message d'erreur
  Future<(UserEntity?, String?)> getCurrentUser();

  /// Vérifier si l'utilisateur est authentifié
  /// Retourne (bool?, String?) - true/false OU message d'erreur
  Future<(bool?, String?)> isAuthenticated();

  /// Sauvegarder les tokens localement
  /// Retourne (void, String?) - null OU message d'erreur
  Future<(void, String?)> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  /// Supprimer les tokens localement
  /// Retourne (void, String?) - null OU message d'erreur
  Future<(void, String?)> clearTokens();
}