// ========================================
// auth_local_datasource.dart
// ========================================
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/storage_keys.dart';
import '../models/user_model.dart';

/// Interface du datasource local
abstract class AuthLocalDataSource {
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> clearTokens();

  Future<void> saveUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearUser();

  Future<void> setAuthStatus(bool isAuthenticated);
  Future<bool> getAuthStatus();
}

/// Implémentation du datasource local
@LazySingleton(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl(this.secureStorage, this.sharedPreferences);

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      secureStorage.write(key: StorageKeys.accessToken, value: accessToken),
      secureStorage.write(key: StorageKeys.refreshToken, value: refreshToken),
    ]);
  }

  @override
  Future<String?> getAccessToken() async {
    return await secureStorage.read(key: StorageKeys.accessToken);
  }

  @override
  Future<String?> getRefreshToken() async {
    return await secureStorage.read(key: StorageKeys.refreshToken);
  }

  @override
  Future<void> clearTokens() async {
    await Future.wait([
      secureStorage.delete(key: StorageKeys.accessToken),
      secureStorage.delete(key: StorageKeys.refreshToken),
    ]);
  }

  @override
  Future<void> saveUser(UserModel user) async {
    final userJson = jsonEncode(user.toJson());
    await Future.wait([
      sharedPreferences.setString(StorageKeys.userId, user.id),
      sharedPreferences.setString(StorageKeys.userEmail, user.email),
      sharedPreferences.setString(StorageKeys.userFullName, user.fullName),
      sharedPreferences.setString('cached_user', userJson),
      if (user.roleModel != null)
        sharedPreferences.setString(
          StorageKeys.userRole,
          user.roleModel!.roleType,
        ),
    ]);
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final userJson = sharedPreferences.getString('cached_user');
    if (userJson != null) {
      try {
        return UserModel.fromJson(jsonDecode(userJson));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  @override
  Future<void> clearUser() async {
    await Future.wait([
      sharedPreferences.remove(StorageKeys.userId),
      sharedPreferences.remove(StorageKeys.userEmail),
      sharedPreferences.remove(StorageKeys.userFullName),
      sharedPreferences.remove(StorageKeys.userRole),
      sharedPreferences.remove('cached_user'),
    ]);
  }

  @override
  Future<void> setAuthStatus(bool isAuthenticated) async {
    await sharedPreferences.setBool(
      StorageKeys.isAuthenticated,
      isAuthenticated,
    );
  }

  @override
  Future<bool> getAuthStatus() async {
    return sharedPreferences.getBool(StorageKeys.isAuthenticated) ?? false;
  }
}
