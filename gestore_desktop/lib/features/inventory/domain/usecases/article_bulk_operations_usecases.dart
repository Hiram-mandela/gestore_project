// ========================================
// lib/features/inventory/domain/usecases/article_bulk_operations_usecases.dart
// Use Cases pour les opérations en masse sur les articles
// ========================================

import 'package:logger/logger.dart';
import '../repositories/inventory_repository.dart';

// ==================== BULK UPDATE ARTICLES ====================

class BulkUpdateArticlesParams {
  final List<String> articleIds;
  final String action; // 'activate', 'deactivate', 'delete', 'update_category', 'update_supplier'
  final Map<String, dynamic>? data; // Pour category_id, supplier_id, etc.

  const BulkUpdateArticlesParams({
    required this.articleIds,
    required this.action,
    this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'ids': articleIds,
      'action': action,
      if (data != null) 'data': data,
    };
  }
}

class BulkUpdateArticlesUseCase {
  final InventoryRepository repository;
  final Logger logger;

  BulkUpdateArticlesUseCase({
    required this.repository,
    required this.logger,
  });

  Future<(Map<String, dynamic>?, String?)> call(
      BulkUpdateArticlesParams params,
      ) async {
    logger.d('🎯 UseCase: BulkUpdateArticles - ${params.articleIds.length} articles');

    if (params.articleIds.isEmpty) {
      logger.e('❌ UseCase: Liste d\'articles vide');
      return (null, 'Au moins un article doit être sélectionné');
    }

    final validActions = [
      'activate',
      'deactivate',
      'delete',
      'update_category',
      'update_supplier'
    ];

    if (!validActions.contains(params.action)) {
      logger.e('❌ UseCase: Action invalide: ${params.action}');
      return (null, 'Action invalide');
    }

    // Validation spécifique selon l'action
    if (params.action == 'update_category' && params.data?['category_id'] == null) {
      return (null, 'ID de catégorie requis');
    }

    if (params.action == 'update_supplier' && params.data?['supplier_id'] == null) {
      return (null, 'ID de fournisseur requis');
    }

    return await repository.bulkUpdateArticles(params);
  }
}

// ==================== DUPLICATE ARTICLE ====================

class DuplicateArticleParams {
  final String articleId;
  final bool copyImages;
  final bool copyBarcodes;
  final String? newName;
  final String? newCode;

  const DuplicateArticleParams({
    required this.articleId,
    this.copyImages = false,
    this.copyBarcodes = false,
    this.newName,
    this.newCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'copy_images': copyImages,
      'copy_barcodes': copyBarcodes,
      if (newName != null) 'name': newName,
      if (newCode != null) 'code': newCode,
    };
  }
}

class DuplicateArticleUseCase {
  final InventoryRepository repository;
  final Logger logger;

  DuplicateArticleUseCase({
    required this.repository,
    required this.logger,
  });

  Future<(Map<String, dynamic>?, String?)> call(
      DuplicateArticleParams params,
      ) async {
    logger.d('🎯 UseCase: DuplicateArticle - ${params.articleId}');

    if (params.articleId.isEmpty) {
      logger.e('❌ UseCase: ID article vide');
      return (null, 'ID de l\'article requis');
    }

    return await repository.duplicateArticle(params);
  }
}

// ==================== IMPORT ARTICLES CSV ====================

class ImportArticlesCSVParams {
  final String filePath;

  const ImportArticlesCSVParams({required this.filePath});
}

class ImportArticlesCSVUseCase {
  final InventoryRepository repository;
  final Logger logger;

  ImportArticlesCSVUseCase({
    required this.repository,
    required this.logger,
  });

  Future<(Map<String, dynamic>?, String?)> call(
      ImportArticlesCSVParams params,
      ) async {
    logger.d('🎯 UseCase: ImportArticlesCSV - ${params.filePath}');

    if (params.filePath.isEmpty) {
      logger.e('❌ UseCase: Chemin fichier vide');
      return (null, 'Fichier CSV requis');
    }

    // Vérifier que le fichier existe et est un CSV
    if (!params.filePath.toLowerCase().endsWith('.csv')) {
      logger.e('❌ UseCase: Format fichier invalide');
      return (null, 'Le fichier doit être au format CSV');
    }

    return await repository.importArticlesCSV(params.filePath);
  }
}

// ==================== EXPORT ARTICLES CSV ====================

class ExportArticlesCSVParams {
  final String? categoryId;
  final String? brandId;
  final bool? isActive;
  final bool? isLowStock;

  const ExportArticlesCSVParams({
    this.categoryId,
    this.brandId,
    this.isActive,
    this.isLowStock,
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    if (categoryId != null) params['category'] = categoryId;
    if (brandId != null) params['brand'] = brandId;
    if (isActive != null) params['is_active'] = isActive;
    if (isLowStock != null) params['is_low_stock'] = isLowStock;
    return params;
  }
}

class ExportArticlesCSVUseCase {
  final InventoryRepository repository;
  final Logger logger;

  ExportArticlesCSVUseCase({
    required this.repository,
    required this.logger,
  });

  Future<(String?, String?)> call(ExportArticlesCSVParams params) async {
    logger.d('🎯 UseCase: ExportArticlesCSV');

    return await repository.exportArticlesCSV(params);
  }
}