// ========================================
// lib/features/settings/data/datasources/settings_local_datasource.dart
// DataSource pour le stockage local des paramètres
// ========================================

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/network/connection_mode.dart';
import '../models/connection_config_model.dart';

/// Interface du datasource local
abstract class SettingsLocalDataSource {
  /// Obtenir la configuration actuelle
  Future<ConnectionConfig?> getCurrentConnectionConfig();

  /// Sauvegarder la configuration actuelle
  Future<void> saveConnectionConfig(ConnectionConfig config);

  /// Obtenir l'historique des connexions
  Future<List<ConnectionConfig>> getConnectionHistory();

  /// Ajouter une connexion à l'historique
  Future<void> addToConnectionHistory(ConnectionConfig config);

  /// Supprimer une connexion de l'historique
  Future<void> removeFromConnectionHistory(int index);

  /// Effacer l'historique
  Future<void> clearConnectionHistory();

  /// Obtenir le mode de connexion actuel
  Future<ConnectionMode?> getCurrentConnectionMode();

  /// Marquer la dernière validation
  Future<void> markConnectionValidated();

  /// Obtenir la date de dernière validation
  Future<DateTime?> getLastValidationDate();
}

/// Implémentation du datasource local
class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final SharedPreferences sharedPreferences;

  SettingsLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<ConnectionConfig?> getCurrentConnectionConfig() async {
    final configJson = sharedPreferences.getString(StorageKeys.connectionConfig);

    if (configJson == null) {
      return null;
    }

    try {
      final json = jsonDecode(configJson) as Map<String, dynamic>;
      return ConnectionConfigModel.fromJson(json);
    } catch (e) {
      // Si erreur de parsing, retourner null
      return null;
    }
  }

  @override
  Future<void> saveConnectionConfig(ConnectionConfig config) async {
    final json = ConnectionConfigModel.toJson(config);
    final jsonString = jsonEncode(json);

    await sharedPreferences.setString(StorageKeys.connectionConfig, jsonString);
    await sharedPreferences.setString(
      StorageKeys.connectionMode,
      config.mode.toStorageString(),
    );
    await sharedPreferences.setString(StorageKeys.serverUrl, config.serverUrl);

    if (config.port != null) {
      await sharedPreferences.setInt(StorageKeys.serverPort, config.port!);
    }

    await sharedPreferences.setBool(StorageKeys.useHttps, config.useHttps);
  }

  @override
  Future<List<ConnectionConfig>> getConnectionHistory() async {
    final historyJson = sharedPreferences.getString(StorageKeys.connectionHistory);

    if (historyJson == null) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(historyJson);
      return ConnectionConfigModel.listFromJson(jsonList);
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> addToConnectionHistory(ConnectionConfig config) async {
    final history = await getConnectionHistory();

    // Vérifier si la config existe déjà
    history.removeWhere((c) =>
    c.serverUrl == config.serverUrl &&
        c.port == config.port &&
        c.mode == config.mode);

    // Ajouter en début de liste
    history.insert(0, config);

    // Limiter à 10 configurations récentes
    if (history.length > 10) {
      history.removeRange(10, history.length);
    }

    final jsonList = ConnectionConfigModel.listToJson(history);
    final jsonString = jsonEncode(jsonList);

    await sharedPreferences.setString(StorageKeys.connectionHistory, jsonString);
  }

  @override
  Future<void> removeFromConnectionHistory(int index) async {
    final history = await getConnectionHistory();

    if (index >= 0 && index < history.length) {
      history.removeAt(index);

      final jsonList = ConnectionConfigModel.listToJson(history);
      final jsonString = jsonEncode(jsonList);

      await sharedPreferences.setString(StorageKeys.connectionHistory, jsonString);
    }
  }

  @override
  Future<void> clearConnectionHistory() async {
    await sharedPreferences.remove(StorageKeys.connectionHistory);
  }

  @override
  Future<ConnectionMode?> getCurrentConnectionMode() async {
    final modeString = sharedPreferences.getString(StorageKeys.connectionMode);

    if (modeString == null) {
      return null;
    }

    return ConnectionModeExtension.fromString(modeString);
  }

  @override
  Future<void> markConnectionValidated() async {
    final now = DateTime.now().toIso8601String();
    await sharedPreferences.setString(
      StorageKeys.lastConnectionValidation,
      now,
    );
    await sharedPreferences.setBool(StorageKeys.lastConnectionStatus, true);
  }

  @override
  Future<DateTime?> getLastValidationDate() async {
    final dateString = sharedPreferences.getString(
      StorageKeys.lastConnectionValidation,
    );

    if (dateString == null) {
      return null;
    }

    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }
}