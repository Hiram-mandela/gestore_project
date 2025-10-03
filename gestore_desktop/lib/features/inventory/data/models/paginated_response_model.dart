// ========================================
// lib/features/inventory/data/models/paginated_response_model.dart
// Model générique pour les réponses paginées de l'API
// ========================================

import '../../domain/entities/paginated_response_entity.dart';

/// Model pour le mapping des réponses paginées depuis/vers l'API
/// Structure Django REST Framework standard
class PaginatedResponseModel<T> {
  final int count;
  final String? next;
  final String? previous;
  final List<T> results;

  PaginatedResponseModel({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  /// Convertit le JSON de l'API en Model
  /// [fromJsonT] : Fonction pour convertir chaque élément de results
  factory PaginatedResponseModel.fromJson(
      Map<String, dynamic> json,
      T Function(Map<String, dynamic>) fromJsonT,
      ) {
    return PaginatedResponseModel<T>(
      count: json['count'] as int,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: (json['results'] as List<dynamic>)
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Convertit le Model en JSON pour l'API
  /// [toJsonT] : Fonction pour convertir chaque élément de results
  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {
      'count': count,
      'next': next,
      'previous': previous,
      'results': results.map((item) => toJsonT(item)).toList(),
    };
  }

  /// Convertit le Model en Entity
  /// [toEntityT] : Fonction pour convertir chaque élément de results en entity
  PaginatedResponseEntity<E> toEntity<E>(E Function(T) toEntityT) {
    return PaginatedResponseEntity<E>(
      count: count,
      next: next,
      previous: previous,
      results: results.map((item) => toEntityT(item)).toList(),
    );
  }
}