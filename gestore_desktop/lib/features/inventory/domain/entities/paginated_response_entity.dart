// ========================================
// lib/features/inventory/domain/entities/paginated_response_entity.dart
// Entity générique pour les réponses paginées de l'API
// ========================================

import 'package:equatable/equatable.dart';

/// Entity représentant une réponse paginée de l'API
/// Structure standard Django REST Framework :
/// { "count": int, "next": string?, "previous": string?, "results": T[] }
class PaginatedResponseEntity<T> extends Equatable {
  final int count;
  final String? next;
  final String? previous;
  final List<T> results;

  const PaginatedResponseEntity({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  /// Vérifie s'il y a une page suivante
  bool get hasNext => next != null;

  /// Vérifie s'il y a une page précédente
  bool get hasPrevious => previous != null;

  /// Retourne le nombre de résultats dans cette page
  int get resultsCount => results.length;

  /// Vérifie si la liste est vide
  bool get isEmpty => results.isEmpty;

  /// Vérifie si la liste n'est pas vide
  bool get isNotEmpty => results.isNotEmpty;

  @override
  List<Object?> get props => [count, next, previous, results];

  @override
  String toString() =>
      'PaginatedResponseEntity(count: $count, resultsCount: $resultsCount, hasNext: $hasNext)';
}