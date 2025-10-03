// ==================== logout_usecase.dart ====================
// Fichier: lib/features/authentication/domain/usecases/logout_usecase.dart

import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// Use case pour se déconnecter
class LogoutUseCase implements UseCase<void, NoParams> {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  @override
  Future<(void, String?)> call(NoParams params) async {
    return await repository.logout();
  }
}