// ========================================
// lib/features/inventory/data/models/stock_model.dart
// Model pour les stocks
// Basé sur: apps/inventory/models.py - Stock & apps/inventory/serializers.py - StockSerializer
// ========================================

import '../../domain/entities/stock_entity.dart';
import 'article_model.dart';
import 'location_model.dart';

class StockModel {
  final String id;
  final String articleId;
  final String locationId;
  final String? lotNumber;
  final DateTime? expiryDate;
  final double quantityOnHand;
  final double quantityReserved;
  final double quantityAvailable;
  final double unitCost;
  final bool isExpired;
  final int? daysUntilExpiry;
  final double stockValue;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;
  final bool needsSync;

  // Relations (optionnelles, chargées selon le contexte)
  final ArticleModel? article;
  final LocationModel? location;

  StockModel({
    required this.id,
    required this.articleId,
    required this.locationId,
    this.lotNumber,
    this.expiryDate,
    required this.quantityOnHand,
    required this.quantityReserved,
    required this.quantityAvailable,
    required this.unitCost,
    required this.isExpired,
    this.daysUntilExpiry,
    required this.stockValue,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = 'synced',
    this.needsSync = false,
    this.article,
    this.location,
  });

  /// Convertit le JSON de l'API en Model
  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
      id: json['id'] as String,
      articleId: json['article_id'] as String? ??
          (json['article'] is Map ? json['article']['id'] : ''),
      locationId: json['location_id'] as String? ??
          (json['location'] is Map ? json['location']['id'] : ''),
      lotNumber: json['lot_number'] as String?,
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'] as String)
          : null,
      quantityOnHand: _parseDouble(json['quantity_on_hand']),
      quantityReserved: _parseDouble(json['quantity_reserved']),
      quantityAvailable: _parseDouble(json['quantity_available']),
      unitCost: _parseDouble(json['unit_cost']),
      isExpired: json['is_expired'] as bool? ?? false,
      daysUntilExpiry: json['days_until_expiry'] as int?,
      stockValue: _parseDouble(json['stock_value']),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      syncStatus: json['sync_status'] as String? ?? 'synced',
      needsSync: json['needs_sync'] as bool? ?? false,
      article: json['article'] != null && json['article'] is Map
          ? ArticleModel.fromJson(json['article'] as Map<String, dynamic>)
          : null,
      location: json['location'] != null && json['location'] is Map
          ? LocationModel.fromJson(json['location'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Helper pour parser les valeurs numériques
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Convertit le Model en Entity
  StockEntity toEntity() {
    return StockEntity(
      id: id,
      articleId: articleId,
      locationId: locationId,
      lotNumber: lotNumber,
      expiryDate: expiryDate,
      quantityOnHand: quantityOnHand,
      quantityReserved: quantityReserved,
      quantityAvailable: quantityAvailable,
      unitCost: unitCost,
      isExpired: isExpired,
      daysUntilExpiry: daysUntilExpiry,
      stockValue: stockValue,
      createdAt: createdAt,
      updatedAt: updatedAt,
      article: article?.toEntity(),
      location: location?.toEntity(),
    );
  }

  /// Convertit le Model en JSON pour l'API
  Map<String, dynamic> toJson() {
    return {
      'article_id': articleId,
      'location_id': locationId,
      'lot_number': lotNumber,
      'expiry_date': expiryDate?.toIso8601String().split('T')[0],
      'quantity_on_hand': quantityOnHand,
      'quantity_reserved': quantityReserved,
      'unit_cost': unitCost,
    };
  }

  /// Crée une copie avec des champs modifiés
  StockModel copyWith({
    String? id,
    String? articleId,
    String? locationId,
    String? lotNumber,
    DateTime? expiryDate,
    double? quantityOnHand,
    double? quantityReserved,
    double? quantityAvailable,
    double? unitCost,
    bool? isExpired,
    int? daysUntilExpiry,
    double? stockValue,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
    bool? needsSync,
    ArticleModel? article,
    LocationModel? location,
  }) {
    return StockModel(
      id: id ?? this.id,
      articleId: articleId ?? this.articleId,
      locationId: locationId ?? this.locationId,
      lotNumber: lotNumber ?? this.lotNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      quantityOnHand: quantityOnHand ?? this.quantityOnHand,
      quantityReserved: quantityReserved ?? this.quantityReserved,
      quantityAvailable: quantityAvailable ?? this.quantityAvailable,
      unitCost: unitCost ?? this.unitCost,
      isExpired: isExpired ?? this.isExpired,
      daysUntilExpiry: daysUntilExpiry ?? this.daysUntilExpiry,
      stockValue: stockValue ?? this.stockValue,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      needsSync: needsSync ?? this.needsSync,
      article: article ?? this.article,
      location: location ?? this.location,
    );
  }
}