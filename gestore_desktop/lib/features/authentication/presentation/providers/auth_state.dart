// ========================================
// features/authentication/presentation/providers/auth_state.dart
// VERSION CORRIGÉE - Sans Freezed
// ========================================
import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

/// États d'authentification
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// État initial
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// État de chargement
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// État authentifié avec succès
class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

/// État non authentifié
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// État d'erreur
class AuthError extends AuthState {
  final String message;
  final Map<String, List<String>>? fieldErrors;

  const AuthError({
    required this.message,
    this.fieldErrors,
  });

  @override
  List<Object?> get props => [message, fieldErrors];
}