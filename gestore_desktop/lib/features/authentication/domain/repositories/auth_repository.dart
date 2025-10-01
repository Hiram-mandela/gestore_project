// ========================================
// auth_repository.dart (Interface)
// ========================================
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';

/// Interface du repository d'authentification
/// Définit le contrat que doit respecter l'implémentation
abstract class AuthRepository {
  /// Se connecter avec username et mot de passe
  Future<Either<Failure, UserEntity>> login({
    required String username,
    required String password,
  });

  /// Se déconnecter
  Future<Either<Failure, void>> logout();

  /// Rafraîchir le token d'accès
  Future<Either<Failure, void>> refreshToken();

  /// Obtenir l'utilisateur actuellement connecté
  Future<Either<Failure, UserEntity>> getCurrentUser();

  /// Vérifier si l'utilisateur est authentifié
  Future<Either<Failure, bool>> isAuthenticated();

  /// Sauvegarder les tokens localement
  Future<Either<Failure, void>> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  /// Supprimer les tokens localement
  Future<Either<Failure, void>> clearTokens();
}