// ========================================
// lib/core/usecases/usecase.dart
// VERSION NETTOYÉE - Suppression des définitions Either inutilisées
// ========================================

import 'package:equatable/equatable.dart';

/// Classe de base pour tous les use cases
/// Utilise des tuples Dart 3 pour retourner soit une erreur soit des données
/// Format: (Type?, String?)
/// - Premier élément ($1): Les données (null si erreur)
/// - Deuxième élément ($2): Le message d'erreur (null si succès)
abstract class UseCase<Type, Params> {
  /// Exécute le use case avec les paramètres fournis
  /// Retourne un tuple avec :
  /// - $1: Type? (données si présent, null si erreur)
  /// - $2: String? (message d'erreur si présent, null si succès)
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