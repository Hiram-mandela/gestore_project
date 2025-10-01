// ========================================
// refresh_token_usecase.dart
// ========================================
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// Use case pour rafraîchir le token
class RefreshTokenUseCase implements UseCase<void, NoParams> {
  final AuthRepository repository;

  RefreshTokenUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.refreshToken();
  }
}
