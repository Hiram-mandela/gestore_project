// ========================================
// lib/features/inventory/data/models/article_model.dart
// Model pour le mapping JSON <-> Entity Article
// Correspond au ArticleListSerializer du backend
// ========================================

import '../../domain/entities/article_entity.dart';

/// Model pour le mapping des articles depuis/vers l'API
/// Version optimisée pour la liste (ArticleListSerializer)
class ArticleModel {
  final String id;
  final String name;
  final String code;
  final String articleType;
  final String? barcode;
  final String categoryName;
  final String categoryColor;
  final String? brandName;
  final String unitSymbol;
  final double purchasePrice;
  final double sellingPrice;
  final String? imageUrl;
  final double currentStock;
  final double availableStock;
  final bool isLowStock;
  final double marginPercent;
  final bool isSellable;
  final bool isActive;
  final String statusDisplay;
  final String createdAt;
  final String updatedAt;

  ArticleModel({
    required this.id,
    required this.name,
    required this.code,
    required this.articleType,
    this.barcode,
    required this.categoryName,
    required this.categoryColor,
    this.brandName,
    required this.unitSymbol,
    required this.purchasePrice,
    required this.sellingPrice,
    this.imageUrl,
    required this.currentStock,
    required this.availableStock,
    required this.isLowStock,
    required this.marginPercent,
    required this.isSellable,
    required this.isActive,
    required this.statusDisplay,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convertit le JSON de l'API en Model
  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      articleType: json['article_type'] as String,
      barcode: json['barcode'] as String?,
      categoryName: json['category_name'] as String,
      categoryColor: json['category_color'] as String? ?? '#000000',
      brandName: json['brand_name'] as String?,
      unitSymbol: json['unit_symbol'] as String,
      purchasePrice: (json['purchase_price'] as num).toDouble(),
      sellingPrice: (json['selling_price'] as num).toDouble(),
      imageUrl: json['image_url'] as String?,
      currentStock: (json['current_stock'] as num?)?.toDouble() ?? 0.0,
      availableStock: (json['available_stock'] as num?)?.toDouble() ?? 0.0,
      isLowStock: json['is_low_stock'] as bool? ?? false,
      marginPercent: (json['margin_percent'] as num?)?.toDouble() ?? 0.0,
      isSellable: json['is_sellable'] as bool? ?? true,
      isActive: json['is_active'] as bool? ?? true,
      statusDisplay: json['status_display'] as String? ?? 'Inactif',
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  /// Convertit le Model en JSON pour l'API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'article_type': articleType,
      'barcode': barcode,
      'category_name': categoryName,
      'category_color': categoryColor,
      'brand_name': brandName,
      'unit_symbol': unitSymbol,
      'purchase_price': purchasePrice,
      'selling_price': sellingPrice,
      'image_url': imageUrl,
      'current_stock': currentStock,
      'available_stock': availableStock,
      'is_low_stock': isLowStock,
      'margin_percent': marginPercent,
      'is_sellable': isSellable,
      'is_active': isActive,
      'status_display': statusDisplay,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Convertit le Model en Entity
  ArticleEntity toEntity() {
    return ArticleEntity(
      id: id,
      name: name,
      code: code,
      articleType: ArticleType.fromString(articleType),
      barcode: barcode,
      categoryName: categoryName,
      categoryColor: categoryColor,
      brandName: brandName,
      unitSymbol: unitSymbol,
      purchasePrice: purchasePrice,
      sellingPrice: sellingPrice,
      imageUrl: imageUrl,
      currentStock: currentStock,
      availableStock: availableStock,
      isLowStock: isLowStock,
      marginPercent: marginPercent,
      isSellable: isSellable,
      isActive: isActive,
      statusDisplay: statusDisplay,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }

  /// Crée un Model depuis une Entity
  factory ArticleModel.fromEntity(ArticleEntity entity) {
    return ArticleModel(
      id: entity.id,
      name: entity.name,
      code: entity.code,
      articleType: entity.articleType.value,
      barcode: entity.barcode,
      categoryName: entity.categoryName,
      categoryColor: entity.categoryColor,
      brandName: entity.brandName,
      unitSymbol: entity.unitSymbol,
      purchasePrice: entity.purchasePrice,
      sellingPrice: entity.sellingPrice,
      imageUrl: entity.imageUrl,
      currentStock: entity.currentStock,
      availableStock: entity.availableStock,
      isLowStock: entity.isLowStock,
      marginPercent: entity.marginPercent,
      isSellable: entity.isSellable,
      isActive: entity.isActive,
      statusDisplay: entity.statusDisplay,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
    );
  }
}