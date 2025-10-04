// ========================================
// lib/core/utils/jwt_helper.dart
// Helper pour gérer et vérifier les tokens JWT
// ========================================
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:logger/logger.dart';

class JwtHelper {
  final Logger _logger;

  JwtHelper(this._logger);

  /// Vérifie si un token est expiré
  /// Retourne true si expiré ou invalide
  bool isTokenExpired(String? token) {
    if (token == null || token.isEmpty) {
      return true;
    }

    try {
      return JwtDecoder.isExpired(token);
    } catch (e) {
      _logger.e('❌ Erreur décodage token: $e');
      return true; // Considéré comme expiré si impossible à décoder
    }
  }

  /// Vérifie si un token va expirer dans les N secondes
  /// Utile pour refresh proactif (ex: refresh 5 min avant expiration)
  bool willExpireSoon(String? token, {int bufferSeconds = 300}) {
    if (token == null || token.isEmpty) {
      return true;
    }

    try {
      final expirationDate = JwtDecoder.getExpirationDate(token);
      final now = DateTime.now();
      final timeUntilExpiry = expirationDate.difference(now);

      return timeUntilExpiry.inSeconds <= bufferSeconds;
    } catch (e) {
      _logger.e('❌ Erreur vérification expiration: $e');
      return true;
    }
  }

  /// Obtient la date d'expiration d'un token
  DateTime? getExpirationDate(String? token) {
    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      return JwtDecoder.getExpirationDate(token);
    } catch (e) {
      _logger.e('❌ Erreur récupération date expiration: $e');
      return null;
    }
  }

  /// Décode le payload d'un token
  Map<String, dynamic>? decodeToken(String? token) {
    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      return JwtDecoder.decode(token);
    } catch (e) {
      _logger.e('❌ Erreur décodage payload: $e');
      return null;
    }
  }

  /// Obtient le temps restant avant expiration (en secondes)
  int? getRemainingTime(String? token) {
    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      final remainingTime = JwtDecoder.getRemainingTime(token);
      return remainingTime.inSeconds;
    } catch (e) {
      _logger.e('❌ Erreur calcul temps restant: $e');
      return null;
    }
  }
}