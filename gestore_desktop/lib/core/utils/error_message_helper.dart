// ========================================
// lib/core/utils/error_message_helper.dart
// NOUVEAU FICHIER - Helper pour extraire les messages d'erreur
// ========================================

/// Helper pour extraire les messages d'erreur propres depuis les réponses API
class ErrorMessageHelper {
  /// Extraire un message d'erreur clair depuis une réponse Django REST Framework
  /// Retourne un message utilisateur friendly, sans détails techniques
  static String extractUserFriendlyMessage(dynamic responseData) {
    if (responseData == null) {
      return 'Une erreur est survenue. Veuillez réessayer.';
    }

    // Si c'est une chaîne, la retourner directement
    if (responseData is String) {
      return _cleanMessage(responseData);
    }

    // Si c'est un Map (objet JSON)
    if (responseData is Map) {
      // PRIORITÉ 1: non_field_errors (Django REST Framework)
      if (responseData.containsKey('non_field_errors')) {
        final errors = responseData['non_field_errors'];
        if (errors is List && errors.isNotEmpty) {
          return _cleanMessage(errors.first.toString());
        }
      }

      // PRIORITÉ 2: detail (Django standard)
      if (responseData.containsKey('detail')) {
        final detail = responseData['detail'];
        if (detail is String && detail.isNotEmpty) {
          return _cleanMessage(detail);
        }
      }

      // PRIORITÉ 3: message (format personnalisé)
      if (responseData.containsKey('message')) {
        final message = responseData['message'];
        if (message is String && message.isNotEmpty) {
          return _cleanMessage(message);
        }
      }

      // PRIORITÉ 4: error
      if (responseData.containsKey('error')) {
        final error = responseData['error'];
        if (error is String && error.isNotEmpty) {
          return _cleanMessage(error);
        }
      }

      // PRIORITÉ 5: Premier champ avec une erreur
      for (final entry in responseData.entries) {
        if (_isMetaOrTechnicalKey(entry.key)) continue;

        final value = entry.value;
        if (value is List && value.isNotEmpty) {
          return _cleanMessage(value.first.toString());
        } else if (value is String && value.isNotEmpty) {
          return _cleanMessage(value);
        }
      }
    }

    // Si c'est une liste
    if (responseData is List && responseData.isNotEmpty) {
      return _cleanMessage(responseData.first.toString());
    }

    return 'Une erreur est survenue. Veuillez réessayer.';
  }

  /// Vérifier si une clé est technique (à ignorer)
  static bool _isMetaOrTechnicalKey(String key) {
    const technicalKeys = [
      '_meta',
      'status',
      'status_code',
      'code',
      'timestamp',
      'path',
      'method',
    ];
    return technicalKeys.contains(key.toLowerCase());
  }

  /// Nettoyer un message d'erreur (enlever les détails techniques)
  static String _cleanMessage(String message) {
    String cleaned = message.trim();

    // Enlever les préfixes techniques Django
    final techPrefixes = [
      'ValidationError: ',
      'IntegrityError: ',
      'OperationalError: ',
      'Error: ',
    ];

    for (final prefix in techPrefixes) {
      if (cleaned.startsWith(prefix)) {
        cleaned = cleaned.substring(prefix.length);
      }
    }

    // Enlever les détails de champ si présents [champ]
    cleaned = cleaned.replaceAll(RegExp(r'\[.*?\]'), '').trim();

    // S'assurer que le message se termine par un point
    if (!cleaned.endsWith('.') &&
        !cleaned.endsWith('!') &&
        !cleaned.endsWith('?')) {
      cleaned = '$cleaned.';
    }

    // Capitaliser la première lettre
    if (cleaned.isNotEmpty) {
      cleaned = cleaned[0].toUpperCase() + cleaned.substring(1);
    }

    return cleaned;
  }

  /// Extraire les erreurs de champs
  static Map<String, List<String>>? extractFieldErrors(dynamic responseData) {
    if (responseData is! Map) return null;

    final errors = <String, List<String>>{};

    responseData.forEach((key, value) {
      // Ignorer les clés non-champ
      if (key == 'message' ||
          key == 'detail' ||
          key == 'error' ||
          key == 'non_field_errors' ||
          _isMetaOrTechnicalKey(key)) {
        return;
      }

      if (value is List) {
        errors[key] = value.map((e) => _cleanMessage(e.toString())).toList();
      } else if (value is String) {
        errors[key] = [_cleanMessage(value)];
      } else if (value is Map) {
        // Erreurs imbriquées
        final nestedErrors = <String>[];
        value.forEach((k, v) {
          if (v is List) {
            nestedErrors.addAll(
              v.map((e) => _cleanMessage(e.toString())),
            );
          } else if (v is String) {
            nestedErrors.add(_cleanMessage(v));
          }
        });
        if (nestedErrors.isNotEmpty) {
          errors[key] = nestedErrors;
        }
      }
    });

    return errors.isNotEmpty ? errors : null;
  }

  /// Transformer un message technique en message utilisateur
  static String getUserFriendlyErrorMessage(String technicalMessage) {
    final lowered = technicalMessage.toLowerCase();

    // Messages d'authentification
    if (lowered.contains('unauthorized') ||
        lowered.contains('401')) {
      return 'Identifiants incorrects.';
    }
    if (lowered.contains('forbidden') ||
        lowered.contains('403')) {
      return 'Vous n\'avez pas les permissions nécessaires.';
    }
    if (lowered.contains('not found') ||
        lowered.contains('404')) {
      return 'Ressource non trouvée.';
    }

    // Messages de connexion
    if (lowered.contains('network') ||
        lowered.contains('connection')) {
      return 'Erreur de connexion. Vérifiez votre connexion internet.';
    }
    if (lowered.contains('timeout')) {
      return 'La connexion a expiré. Veuillez réessayer.';
    }

    // Messages serveur
    if (lowered.contains('server') ||
        lowered.contains('500') ||
        lowered.contains('502') ||
        lowered.contains('503')) {
      return 'Erreur serveur. Veuillez réessayer plus tard.';
    }

    // Si le message est déjà clair, le retourner nettoyé
    return _cleanMessage(technicalMessage);
  }
}