import 'package:equatable/equatable.dart';

/// Classe de base abstraite pour toutes les failures
/// Utilise Equatable pour faciliter les comparaisons
/// Implémente Exception pour pouvoir être lancée
abstract class Failure extends Equatable implements Exception {
  final String message;
  final int? statusCode;
  final dynamic error;

  const Failure({
    required this.message,
    this.statusCode,
    this.error,
  });

  @override
  List<Object?> get props => [message, statusCode, error];

  @override
  String toString() => 'Failure(message: $message, statusCode: $statusCode)';
}

/// Erreur serveur (5xx)
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.statusCode,
    super.error,
  });
}

/// Erreur de connexion réseau
class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.error,
  }) : super(statusCode: null);
}

/// Erreur d'authentification (401, 403)
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({
    required super.message,
    super.statusCode,
    super.error,
  });
}

/// Erreur de validation (400, 422)
class ValidationFailure extends Failure {
  final Map<String, List<String>>? fieldErrors;

  const ValidationFailure({
    required super.message,
    super.statusCode,
    super.error,
    this.fieldErrors,
  });

  @override
  List<Object?> get props => [message, statusCode, error, fieldErrors];
}

/// Ressource non trouvée (404)
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    required super.message,
    super.statusCode = 404,
    super.error,
  });
}

/// Erreur de conflit (409)
class ConflictFailure extends Failure {
  const ConflictFailure({
    required super.message,
    super.statusCode = 409,
    super.error,
  });
}

/// Erreur de cache
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.error,
  }) : super(statusCode: null);
}

/// Erreur de base de données locale
class DatabaseFailure extends Failure {
  const DatabaseFailure({
    required super.message,
    super.error,
  }) : super(statusCode: null);
}

/// Erreur de synchronisation
class SyncFailure extends Failure {
  const SyncFailure({
    required super.message,
    super.error,
  }) : super(statusCode: null);
}

/// Erreur de permission
class PermissionFailure extends Failure {
  const PermissionFailure({
    required super.message,
    super.statusCode = 403,
    super.error,
  });
}

/// Erreur de timeout
class TimeoutFailure extends Failure {
  const TimeoutFailure({
    required super.message,
    super.error,
  }) : super(statusCode: null);
}

/// Erreur générique
class UnknownFailure extends Failure {
  const UnknownFailure({
    required super.message,
    super.statusCode,
    super.error,
  });
}

/// Classe pour les exceptions API personnalisées
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic response;

  const ApiException({
    required this.message,
    this.statusCode,
    this.response,
  });

  @override
  String toString() => 'ApiException(message: $message, statusCode: $statusCode)';
}

/// Exception de connexion réseau
class NetworkException implements Exception {
  final String message;

  const NetworkException({required this.message});

  @override
  String toString() => 'NetworkException(message: $message)';
}

/// Exception de cache
class CacheException implements Exception {
  final String message;

  const CacheException({required this.message});

  @override
  String toString() => 'CacheException(message: $message)';
}

/// Exception de base de données
class DatabaseException implements Exception {
  final String message;

  const DatabaseException({required this.message});

  @override
  String toString() => 'DatabaseException(message: $message)';
}