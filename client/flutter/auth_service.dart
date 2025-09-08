// Minimal Flutter AuthService (Dart) - conceptual example
// Requires: dio, flutter_secure_storage, jwt_decoder

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  final Dio dio;
  final FlutterSecureStorage secureStorage;
  String? accessToken;
  String? username;
  String? role;
  String? id;

  AuthService(this.dio) : secureStorage = FlutterSecureStorage();

  Future<void> login(String username, String password) async {
    final res = await dio.post(
      '/api/auth/login',
      data: {'username': username, 'password': password},
    );
    accessToken = res.data['token'];
    final refresh = res.data['refresh_token'];
    await secureStorage.write(key: 'refresh_token', value: refresh);
    final decoded = JwtDecoder.decode(accessToken!);
    this.username = decoded['username'];
    this.role = decoded['role'];
    this.id = decoded['id'];
  }

  Future<void> logout() async {
    final refresh = await secureStorage.read(key: 'refresh_token');
    if (refresh != null) {
      await dio.post('/api/auth/logout', data: {'refresh_token': refresh});
    }
    accessToken = null;
    await secureStorage.delete(key: 'refresh_token');
  }

  Future<String?> getRefresh() async =>
      await secureStorage.read(key: 'refresh_token');

  Future<void> saveRefresh(String token) async =>
      await secureStorage.write(key: 'refresh_token', value: token);

  Future<bool> refreshAccess() async {
    final refresh = await getRefresh();
    if (refresh == null) return false;
    try {
      final r = await dio.post(
        '/api/auth/refresh',
        data: {'refresh_token': refresh},
      );
      accessToken = r.data['token'];
      return true;
    } catch (e) {
      return false;
    }
  }
}
