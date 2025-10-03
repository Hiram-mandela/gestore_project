import 'package:equatable/equatable.dart';

import '../errors/failures.dart';

/// Type Either pour gérer les résultats avec succès ou échec
/// Left = Failure, Right = Success
typedef Either<L, R> = ({L? left, R? right});

/// Extension pour faciliter l'utilisation d'Either
extension EitherExtension<L, R> on Either<L, R> {
  /// Vérifie qu'il y a une erreur
  bool get isLeft => left != null;

  /// Vérifie qu'il y a un succès (pas d'erreur)
  bool get isRight => left == null;

  /// Applique la fonction appropriée selon le cas
  /// CORRECTION: Vérifie uniquement left, right peut être null pour void
  T fold<T>(T Function(L) leftFn, T Function(R) rightFn) {
    if (left != null) {
      // Cas d'erreur
      return leftFn(left as L);
    } else {
      // Cas de succès (left est null)
      // right peut être null pour void, c'est OK
      return rightFn(right as R);
    }
  }
}

/// Helper pour créer un Left (erreur)
Either<L, R> left<L, R>(L value) {
  return (left: value, right: null);
}

/// Helper pour créer un Right (succès)
Either<L, R> right<L, R>(R value) {
  return (left: null, right: value);
}

/// Classe de base pour tous les use cases
/// Utilise des named records Dart 3 pour retourner soit une erreur soit des données
abstract class UseCase<Type, Params> {
  /// Exécute le use case avec les paramètres fournis
  /// Retourne un named record avec :
  /// - left: String? (message d'erreur si présent)
  /// - right: Type? (données si présent)
  Future<(Type?, String?)> call(Params params);
}

/// Paramètres vides pour les use cases sans paramètres
class NoParams {
  const NoParams();
}

/// Classe pour les use cases avec un seul paramètre ID
class IdParams extends Equatable {
  final String id;

  const IdParams({required this.id});

  @override
  List<Object?> get props => [id];
}

/// Classe pour les paramètres de pagination
class PaginationParams extends Equatable {
  final int page;
  final int pageSize;
  final String? search;
  final Map<String, dynamic>? filters;
  final String? ordering;

  const PaginationParams({
    this.page = 1,
    this.pageSize = 50,
    this.search,
    this.filters,
    this.ordering,
  });

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'page_size': pageSize,
      if (search != null && search!.isNotEmpty) 'search': search,
      if (filters != null) ...filters!,
      if (ordering != null && ordering!.isNotEmpty) 'ordering': ordering,
    };
  }

  @override
  List<Object?> get props => [page, pageSize, search, filters, ordering];
}