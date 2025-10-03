// ==================== get_current_user_usecase.dart ====================
// Fichier: lib/features/authentication/domain/usecases/get_current_user_usecase.dart

import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case pour obtenir l'utilisateur actuel
class GetCurrentUserUseCase implements UseCase<UserEntity, NoParams> {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  @override
  Future<(UserEntity?, String?)> call(NoParams params) async {
    return await repository.getCurrentUser();
  }
}