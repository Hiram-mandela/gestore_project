// ========================================
// lib/features/inventory/data/models/article_image_model.dart
// Model pour les images d'article
// ========================================

import '../../domain/entities/article_image_entity.dart';

class ArticleImageModel {
  final String id;
  final String image;
  final String imageUrl;
  final String altText;
  final String caption;
  final bool isPrimary;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;

  ArticleImageModel({
    required this.id,
    required this.image,
    required this.imageUrl,
    this.altText = '',
    this.caption = '',
    this.isPrimary = false,
    this.order = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convertit le JSON de l'API en Model
  factory ArticleImageModel.fromJson(Map<String, dynamic> json) {
    return ArticleImageModel(
      id: json['id'] as String,
      image: json['image'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      altText: json['alt_text'] as String? ?? '',
      caption: json['caption'] as String? ?? '',
      isPrimary: json['is_primary'] as bool? ?? false,
      order: json['order'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convertit le Model en Entity
  ArticleImageEntity toEntity() {
    return ArticleImageEntity(
      id: id,
      imageUrl: imageUrl,
      altText: altText,
      caption: caption,
      isPrimary: isPrimary,
      order: order,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Convertit le Model en JSON pour l'API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'alt_text': altText,
      'caption': caption,
      'is_primary': isPrimary,
      'order': order,
    };
  }
}