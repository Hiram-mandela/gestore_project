// ========================================
// lib/core/utils/image_compression_helper.dart
// Utilitaire pour compresser les images avant envoi
// Utilise flutter_image_compress
// ========================================

import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Helper pour la compression d'images
class ImageCompressionHelper {
  /// Compression par défaut : 1280px max, qualité 85%
  static const int defaultMaxWidth = 1280;
  static const int defaultMaxHeight = 1280;
  static const int defaultQuality = 85;

  /// Compresse une image avec les paramètres par défaut
  ///
  /// [imagePath] : Chemin du fichier image original
  /// [maxWidth] : Largeur maximale (défaut: 1280px)
  /// [maxHeight] : Hauteur maximale (défaut: 1280px)
  /// [quality] : Qualité de compression 0-100 (défaut: 85)
  ///
  /// Retourne le chemin du fichier compressé ou null en cas d'erreur
  static Future<String?> compressImage({
    required String imagePath,
    int? maxWidth,
    int? maxHeight,
    int? quality,
  }) async {
    try {
      // Vérifier que le fichier existe
      final file = File(imagePath);
      if (!await file.exists()) {
        return null;
      }

      // Obtenir le répertoire temporaire
      final tempDir = await getTemporaryDirectory();

      // Générer un nom unique pour le fichier compressé
      final fileName = path.basename(imagePath);
      final nameWithoutExtension = path.basenameWithoutExtension(fileName);
      final extension = path.extension(fileName);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final compressedFileName = '${nameWithoutExtension}_compressed_$timestamp$extension';
      final targetPath = path.join(tempDir.path, compressedFileName);

      // Compresser l'image
      final result = await FlutterImageCompress.compressAndGetFile(
        imagePath,
        targetPath,
        minWidth: maxWidth ?? defaultMaxWidth,
        minHeight: maxHeight ?? defaultMaxHeight,
        quality: quality ?? defaultQuality,
        format: _getCompressFormat(extension),
      );

      if (result == null) {
        return null;
      }

      return result.path;
    } catch (e) {
      return null;
    }
  }

  /// Compresse plusieurs images en parallèle
  ///
  /// Retourne une Map avec les chemins originaux en clés et les chemins compressés en valeurs
  static Future<Map<String, String?>> compressMultipleImages({
    required List<String> imagePaths,
    int? maxWidth,
    int? maxHeight,
    int? quality,
  }) async {
    final results = <String, String?>{};

    // Compression en parallèle
    final futures = imagePaths.map((imagePath) async {
      final compressedPath = await compressImage(
        imagePath: imagePath,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        quality: quality,
      );
      return MapEntry(imagePath, compressedPath);
    });

    final entries = await Future.wait(futures);
    results.addEntries(entries);

    return results;
  }

  /// Obtient la taille d'une image en octets
  static Future<int?> getImageSize(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        return null;
      }
      return await file.length();
    } catch (e) {
      return null;
    }
  }

  /// Obtient la taille d'une image en mégaoctets
  static Future<double?> getImageSizeInMB(String imagePath) async {
    final size = await getImageSize(imagePath);
    if (size == null) return null;
    return size / (1024 * 1024);
  }

  /// Calcule le taux de compression
  ///
  /// Retourne un pourcentage (0-100) de réduction de taille
  static Future<double?> getCompressionRatio({
    required String originalPath,
    required String compressedPath,
  }) async {
    try {
      final originalSize = await getImageSize(originalPath);
      final compressedSize = await getImageSize(compressedPath);

      if (originalSize == null || compressedSize == null || originalSize == 0) {
        return null;
      }

      final reduction = ((originalSize - compressedSize) / originalSize) * 100;
      return reduction;
    } catch (e) {
      return null;
    }
  }

  /// Détermine le format de compression selon l'extension
  static CompressFormat _getCompressFormat(String extension) {
    switch (extension.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return CompressFormat.jpeg;
      case '.png':
        return CompressFormat.png;
      case '.webp':
        return CompressFormat.webp;
      case '.heic':
        return CompressFormat.heic;
      default:
        return CompressFormat.jpeg; // Par défaut
    }
  }

  /// Vérifie si une image nécessite une compression
  ///
  /// [imagePath] : Chemin du fichier image
  /// [maxSizeMB] : Taille maximale en MB (défaut: 2MB)
  ///
  /// Retourne true si l'image dépasse la taille maximale
  static Future<bool> shouldCompress({
    required String imagePath,
    double maxSizeMB = 2.0,
  }) async {
    final sizeInMB = await getImageSizeInMB(imagePath);
    if (sizeInMB == null) return false;
    return sizeInMB > maxSizeMB;
  }

  /// Compresse une image seulement si nécessaire
  ///
  /// Retourne le chemin de l'image compressée, ou le chemin original si compression non nécessaire
  static Future<String> compressIfNeeded({
    required String imagePath,
    double maxSizeMB = 2.0,
    int? maxWidth,
    int? maxHeight,
    int? quality,
  }) async {
    final needsCompression = await shouldCompress(
      imagePath: imagePath,
      maxSizeMB: maxSizeMB,
    );

    if (!needsCompression) {
      return imagePath; // Retourner le chemin original
    }

    final compressedPath = await compressImage(
      imagePath: imagePath,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      quality: quality,
    );

    return compressedPath ?? imagePath; // Retourner le compressé ou l'original en cas d'erreur
  }

  /// Nettoie les fichiers temporaires de compression
  static Future<void> cleanupTempFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final files = tempDir.listSync();

      for (final file in files) {
        if (file is File) {
          final fileName = path.basename(file.path);
          // Supprimer uniquement les fichiers créés par cette classe
          if (fileName.contains('_compressed_')) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      // Ignorer les erreurs de nettoyage
    }
  }
}

/// Extension pour simplifier l'utilisation
extension ImageFileCompression on File {
  /// Compresse ce fichier image
  Future<File?> compress({
    int? maxWidth,
    int? maxHeight,
    int? quality,
  }) async {
    final compressedPath = await ImageCompressionHelper.compressImage(
      imagePath: this.path,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      quality: quality,
    );

    if (compressedPath == null) return null;
    return File(compressedPath);
  }

  /// Obtient la taille du fichier en MB
  Future<double?> getSizeInMB() async {
    return await ImageCompressionHelper.getImageSizeInMB(this.path);
  }

  /// Vérifie si ce fichier nécessite une compression
  Future<bool> shouldCompress({double maxSizeMB = 2.0}) async {
    return await ImageCompressionHelper.shouldCompress(
      imagePath: this.path,
      maxSizeMB: maxSizeMB,
    );
  }
}