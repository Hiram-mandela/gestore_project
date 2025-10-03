// ==================== check_auth_status_usecase.dart ====================
// Fichier: lib/features/authentication/domain/usecases/check_auth_status_usecase.dart

import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// Use case pour vérifier le statut d'authentification
class CheckAuthStatusUseCase implements UseCase<bool, NoParams> {
  final AuthRepository repository;

  CheckAuthStatusUseCase(this.repository);

  @override
  Future<(bool?, String?)> call(NoParams params) async {
    return await repository.isAuthenticated();
  }
}