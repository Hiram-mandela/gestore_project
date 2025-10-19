// ========================================
// lib/features/inventory/data/models/stock_movement_model.dart
// Model pour le mapping JSON <-> Entity StockMovement
// ========================================

import '../../domain/entities/stock_movement_entity.dart';
import 'article_model.dart';
import 'stock_model.dart';

/// Model pour le mapping des mouvements de stock depuis/vers l'API
class StockMovementModel {
  final String id;
  final ArticleModel article;
  final StockModel stock;
  final String movementType;
  final String reason;
  final double quantity;
  final double? unitCost;
  final String? referenceDocument;
  final String? notes;
  final double stockBefore;
  final double stockAfter;
  final double movementValue;
  final String? createdBy;
  final String createdAt;

  StockMovementModel({
    required this.id,
    required this.article,
    required this.stock,
    required this.movementType,
    required this.reason,
    required this.quantity,
    this.unitCost,
    this.referenceDocument,
    this.notes,
    required this.stockBefore,
    required this.stockAfter,
    required this.movementValue,
    this.createdBy,
    required this.createdAt,
  });

  /// Convertit le JSON de l'API en Model
  factory StockMovementModel.fromJson(Map<String, dynamic> json) {
    return StockMovementModel(
      id: json['id'] as String,
      article: ArticleModel.fromJson(json['article'] as Map<String, dynamic>),
      stock: StockModel.fromJson(json['stock'] as Map<String, dynamic>),
      movementType: json['movement_type'] as String,
      reason: json['reason'] as String,
      quantity: _parseDouble(json['quantity']),
      unitCost: json['unit_cost'] != null ? _parseDouble(json['unit_cost']) : null,
      referenceDocument: json['reference_document'] as String?,
      notes: json['notes'] as String?,
      stockBefore: _parseDouble(json['stock_before']),
      stockAfter: _parseDouble(json['stock_after']),
      movementValue: _parseDouble(json['movement_value']),
      createdBy: json['created_by'] as String?,
      createdAt: json['created_at'] as String,
    );
  }

  /// Parse robuste d'un nombre en double
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  /// Convertit le Model en Entity
  StockMovementEntity toEntity() {
    return StockMovementEntity(
      id: id,
      article: article.toEntity(),
      stock: stock.toEntity(),
      movementType: MovementType.fromString(movementType),
      reason: MovementReason.fromString(reason),
      quantity: quantity,
      unitCost: unitCost,
      referenceDocument: referenceDocument,
      notes: notes,
      stockBefore: stockBefore,
      stockAfter: stockAfter,
      movementValue: movementValue,
      createdBy: createdBy,
      createdAt: DateTime.parse(createdAt),
    );
  }
}