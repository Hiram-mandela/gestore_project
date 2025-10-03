// ==================== refresh_token_usecase.dart ====================
// Fichier: lib/features/authentication/domain/usecases/refresh_token_usecase.dart

import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// Use case pour rafraîchir le token
class RefreshTokenUseCase implements UseCase<void, NoParams> {
  final AuthRepository repository;

  RefreshTokenUseCase(this.repository);

  @override
  Future<(void, String?)> call(NoParams params) async {
    return await repository.refreshToken();
  }
}