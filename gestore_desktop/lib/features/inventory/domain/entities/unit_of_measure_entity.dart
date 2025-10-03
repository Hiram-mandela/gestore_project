// ========================================
// lib/features/inventory/domain/entities/unit_of_measure_entity.dart
// Entity pour les unités de mesure
// ========================================

import 'package:equatable/equatable.dart';

/// Entity représentant une unité de mesure
/// Correspond au modèle UnitOfMeasure du backend
class UnitOfMeasureEntity extends Equatable {
  final String id;
  final String name;
  final String symbol;
  final String? description;
  final bool isDecimal;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UnitOfMeasureEntity({
    required this.id,
    required this.name,
    required this.symbol,
    this.description,
    required this.isDecimal,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Retourne le nom avec le symbole
  String get displayName => '$name ($symbol)';

  @override
  List<Object?> get props => [
    id,
    name,
    symbol,
    description,
    isDecimal,
    isActive,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() => 'UnitOfMeasureEntity(name: $name, symbol: $symbol)';
}