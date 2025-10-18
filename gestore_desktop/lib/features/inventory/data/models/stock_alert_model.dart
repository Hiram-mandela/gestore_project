// ========================================
// lib/features/inventory/data/models/stock_alert_model.dart
// Model pour les alertes de stock - Synchronisé avec backend Django
// ========================================

import '../../domain/entities/stock_alert_entity.dart';
import 'article_model.dart';
import 'stock_model.dart';

class StockAlertModel {
  final String id;
  final String articleId;
  final String? stockId;
  final String alertType;
  final String alertLevel;
  final String message;
  final bool isAcknowledged;
  final String? acknowledgedBy;
  final DateTime? acknowledgedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations optionnelles
  final ArticleModel? article;
  final StockModel? stock;

  StockAlertModel({
    required this.id,
    required this.articleId,
    this.stockId,
    required this.alertType,
    required this.alertLevel,
    required this.message,
    required this.isAcknowledged,
    this.acknowledgedBy,
    this.acknowledgedAt,
    required this.createdAt,
    required this.updatedAt,
    this.article,
    this.stock,
  });

  /// Conversion depuis JSON (backend Django)
  factory StockAlertModel.fromJson(Map<String, dynamic> json) {
    return StockAlertModel(
      id: json['id'] ?? '',
      articleId: json['article_id'] ?? '',
      stockId: json['stock_id'],
      alertType: json['alert_type'] ?? 'low_stock',
      alertLevel: json['alert_level'] ?? 'warning',
      message: json['message'] ?? '',
      isAcknowledged: json['is_acknowledged'] ?? false,
      acknowledgedBy: json['acknowledged_by'],
      acknowledgedAt: json['acknowledged_at'] != null
          ? DateTime.parse(json['acknowledged_at'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      article: json['article'] != null
          ? ArticleModel.fromJson(json['article'])
          : null,
      stock: json['stock'] != null
          ? StockModel.fromJson(json['stock'])
          : null,
    );
  }

  /// Conversion vers JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'article_id': articleId,
      if (stockId != null) 'stock_id': stockId,
      'alert_type': alertType,
      'alert_level': alertLevel,
      'message': message,
      'is_acknowledged': isAcknowledged,
      if (acknowledgedBy != null) 'acknowledged_by': acknowledgedBy,
      if (acknowledgedAt != null)
        'acknowledged_at': acknowledgedAt!.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Conversion vers Entity
  StockAlertEntity toEntity() {
    return StockAlertEntity(
      id: id,
      articleId: articleId,
      stockId: stockId,
      alertType: AlertType.fromString(alertType),
      alertLevel: AlertLevel.fromString(alertLevel),
      message: message,
      isAcknowledged: isAcknowledged,
      acknowledgedBy: acknowledgedBy,
      acknowledgedAt: acknowledgedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      article: article?.toEntity(),
      stock: stock?.toEntity(),
    );
  }

  /// Création depuis Entity
  factory StockAlertModel.fromEntity(StockAlertEntity entity) {
    return StockAlertModel(
      id: entity.id,
      articleId: entity.articleId,
      stockId: entity.stockId,
      alertType: entity.alertType.value,
      alertLevel: entity.alertLevel.value,
      message: entity.message,
      isAcknowledged: entity.isAcknowledged,
      acknowledgedBy: entity.acknowledgedBy,
      acknowledgedAt: entity.acknowledgedAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      article: entity.article != null
          ? ArticleModel.fromEntity(entity.article!)
          : null,
      stock: entity.stock != null
          ? StockModel.fromEntity(entity.stock!)
          : null,
    );
  }

  StockAlertModel copyWith({
    String? id,
    String? articleId,
    String? stockId,
    String? alertType,
    String? alertLevel,
    String? message,
    bool? isAcknowledged,
    String? acknowledgedBy,
    DateTime? acknowledgedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    ArticleModel? article,
    StockModel? stock,
  }) {
    return StockAlertModel(
      id: id ?? this.id,
      articleId: articleId ?? this.articleId,
      stockId: stockId ?? this.stockId,
      alertType: alertType ?? this.alertType,
      alertLevel: alertLevel ?? this.alertLevel,
      message: message ?? this.message,
      isAcknowledged: isAcknowledged ?? this.isAcknowledged,
      acknowledgedBy: acknowledgedBy ?? this.acknowledgedBy,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      article: article ?? this.article,
      stock: stock ?? this.stock,
    );
  }
}