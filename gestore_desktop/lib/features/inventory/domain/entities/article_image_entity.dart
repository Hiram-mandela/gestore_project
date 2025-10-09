// ========================================
// lib/features/inventory/domain/entities/article_image_entity.dart
// Entity pour les images d'article
// ========================================

import 'package:equatable/equatable.dart';

class ArticleImageEntity extends Equatable {
  final String id;
  final String imageUrl;
  final String altText;
  final String caption;
  final bool isPrimary;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ArticleImageEntity({
    required this.id,
    required this.imageUrl,
    this.altText = '',
    this.caption = '',
    this.isPrimary = false,
    this.order = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    imageUrl,
    altText,
    caption,
    isPrimary,
    order,
    createdAt,
    updatedAt,
  ];
}