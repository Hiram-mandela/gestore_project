// ========================================
// lib/features/inventory/domain/entities/stock_entity.dart
// Entity pour les stocks
// ========================================

import 'package:equatable/equatable.dart';
import 'article_entity.dart';
import 'location_entity.dart';

/// Entity représentant un stock d'article dans un emplacement
class StockEntity extends Equatable {
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

  // Relations
  final ArticleEntity? article;
  final LocationEntity? location;

  const StockEntity({
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
    this.article,
    this.location,
  });

  /// Indique si le stock est épuisé
  bool get isOutOfStock => quantityOnHand <= 0;

  /// Indique si le stock est disponible
  bool get hasAvailableStock => quantityAvailable > 0;

  /// Indique si le stock a une date de péremption
  bool get hasExpiryDate => expiryDate != null;

  /// Indique si le stock a un numéro de lot
  bool get hasLotNumber => lotNumber != null && lotNumber!.isNotEmpty;

  /// Indique si le stock expire bientôt (dans les 30 jours)
  bool get isExpiringSoon {
    if (daysUntilExpiry == null) return false;
    return daysUntilExpiry! >= 0 && daysUntilExpiry! <= 30;
  }

  /// Statut de péremption lisible
  String get expiryStatus {
    if (isExpired) return 'Périmé';
    if (isExpiringSoon) return 'Péremption proche';
    if (hasExpiryDate) return 'Valide';
    return 'Pas de date de péremption';
  }

  /// Pourcentage de stock réservé
  double get reservedPercentage {
    if (quantityOnHand <= 0) return 0;
    return (quantityReserved / quantityOnHand) * 100;
  }

  /// Pourcentage de stock disponible
  double get availablePercentage {
    if (quantityOnHand <= 0) return 0;
    return (quantityAvailable / quantityOnHand) * 100;
  }

  @override
  List<Object?> get props => [
    id,
    articleId,
    locationId,
    lotNumber,
    expiryDate,
    quantityOnHand,
    quantityReserved,
    quantityAvailable,
    unitCost,
    isExpired,
    daysUntilExpiry,
    stockValue,
    createdAt,
    updatedAt,
    article,
    location,
  ];

  /// Crée une copie avec des champs modifiés
  StockEntity copyWith({
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
    ArticleEntity? article,
    LocationEntity? location,
  }) {
    return StockEntity(
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
      article: article ?? this.article,
      location: location ?? this.location,
    );
  }
}