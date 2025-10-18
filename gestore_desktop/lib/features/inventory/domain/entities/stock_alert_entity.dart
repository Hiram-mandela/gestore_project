// ========================================
// lib/features/inventory/domain/entities/stock_alert_entity.dart
// Entity pour les alertes de stock avec enums
// ========================================

import 'package:equatable/equatable.dart';
import 'article_entity.dart';
import 'stock_entity.dart';

/// Types d'alertes de stock (synchronisé avec backend Django)
enum AlertType {
  lowStock('low_stock', 'Stock bas'),
  outOfStock('out_of_stock', 'Rupture de stock'),
  expirySoon('expiry_soon', 'Péremption proche'),
  expired('expired', 'Périmé'),
  overstock('overstock', 'Surstock');

  final String value;
  final String label;

  const AlertType(this.value, this.label);

  static AlertType fromString(String value) {
    return AlertType.values.firstWhere(
          (type) => type.value == value,
      orElse: () => AlertType.lowStock,
    );
  }
}

/// Niveaux d'alerte (synchronisé avec backend Django)
enum AlertLevel {
  info('info', 'Information', 0),
  warning('warning', 'Avertissement', 1),
  critical('critical', 'Critique', 2);

  final String value;
  final String label;
  final int severity;

  const AlertLevel(this.value, this.label, this.severity);

  static AlertLevel fromString(String value) {
    return AlertLevel.values.firstWhere(
          (level) => level.value == value,
      orElse: () => AlertLevel.warning,
    );
  }
}

class StockAlertEntity extends Equatable {
  final String id;
  final String articleId;
  final String? stockId;
  final AlertType alertType;
  final AlertLevel alertLevel;
  final String message;
  final bool isAcknowledged;
  final String? acknowledgedBy;
  final DateTime? acknowledgedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations
  final ArticleEntity? article;
  final StockEntity? stock;

  const StockAlertEntity({
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

  @override
  List<Object?> get props => [
    id,
    articleId,
    stockId,
    alertType,
    alertLevel,
    message,
    isAcknowledged,
    acknowledgedBy,
    acknowledgedAt,
    createdAt,
    updatedAt,
  ];

  /// Vérifie si l'alerte est récente (moins de 24h)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inHours < 24;
  }

  /// Vérifie si l'alerte nécessite une action urgente
  bool get requiresUrgentAction {
    return alertLevel == AlertLevel.critical && !isAcknowledged;
  }

  /// Retourne la couleur associée au niveau d'alerte
  String get levelColor {
    switch (alertLevel) {
      case AlertLevel.info:
        return '#2196F3'; // Bleu
      case AlertLevel.warning:
        return '#FF9800'; // Orange
      case AlertLevel.critical:
        return '#F44336'; // Rouge
    }
  }

  /// Retourne l'icône associée au type d'alerte
  String get typeIcon {
    switch (alertType) {
      case AlertType.lowStock:
        return 'trending_down';
      case AlertType.outOfStock:
        return 'remove_shopping_cart';
      case AlertType.expirySoon:
        return 'schedule';
      case AlertType.expired:
        return 'dangerous';
      case AlertType.overstock:
        return 'trending_up';
    }
  }

  /// Durée depuis la création
  Duration get age => DateTime.now().difference(createdAt);

  /// Durée depuis l'acquittement
  Duration? get timeSinceAcknowledgement {
    if (acknowledgedAt == null) return null;
    return DateTime.now().difference(acknowledgedAt!);
  }

  StockAlertEntity copyWith({
    String? id,
    String? articleId,
    String? stockId,
    AlertType? alertType,
    AlertLevel? alertLevel,
    String? message,
    bool? isAcknowledged,
    String? acknowledgedBy,
    DateTime? acknowledgedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    ArticleEntity? article,
    StockEntity? stock,
  }) {
    return StockAlertEntity(
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