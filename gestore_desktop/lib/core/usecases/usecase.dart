import 'package:equatable/equatable.dart';

import '../errors/failures.dart';

/// Type Either pour gérer les résultats avec succès ou échec
/// Left = Failure, Right = Success
typedef Either<L, R> = ({L? left, R? right});

/// Extension pour faciliter l'utilisation d'Either
extension EitherExtension<L, R> on Either<L, R> {
  /// ✅ CORRECTION: Vérifie que left est null ET que right n'est pas null
  bool get isLeft => left != null;

  /// ✅ CORRECTION: Vérifie que right est non-null ET que left est null
  bool get isRight => right != null && left == null;

  T fold<T>(T Function(L) leftFn, T Function(R) rightFn) {
    if (left != null) {
      return leftFn(left as L);
    } else if (right != null) {
      return rightFn(right as R);
    } else {
      // Cas invalide: les deux sont null
      throw StateError('Either invalide: left et right sont tous les deux null');
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

/// Classe de base abstraite pour tous les use cases
/// Un use case représente une action métier unique
abstract class UseCase<T, Params> {
  /// Exécuter le use case
  Future<Either<Failure, T>> call(Params params);
}

/// Classe pour les use cases sans paramètres
class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
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