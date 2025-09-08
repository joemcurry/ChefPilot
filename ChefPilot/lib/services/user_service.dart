import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class UserService {
  final AuthService auth;
  UserService(this.auth);

  Future<Map<String, dynamic>?> fetchUser(String id) async {
    final url =
        Uri.parse('${auth.baseUrl}/api/users/${Uri.encodeComponent(id)}');
    try {
      final resp = await http.get(url, headers: auth.headers());
      if (resp.statusCode == 200) {
        return jsonDecode(resp.body) as Map<String, dynamic>;
      }
    } catch (e) {
      if (kDebugMode) return null;
    }
    return null;
  }

  Future<bool> updateUser(String id, Map<String, dynamic> body) async {
    final url =
        Uri.parse('${auth.baseUrl}/api/users/${Uri.encodeComponent(id)}');
    try {
      final resp =
          await http.put(url, headers: auth.headers(), body: jsonEncode(body));
      return resp.statusCode == 200 || resp.statusCode == 204;
    } catch (e) {
      if (kDebugMode) return true;
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchAudit(String id,
      {int limit = 100}) async {
    final url = Uri.parse(
        '${auth.baseUrl}/api/users/${Uri.encodeComponent(id)}/audit?limit=$limit');
    try {
      final resp = await http.get(url, headers: auth.headers());
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as List<dynamic>;
        return data.map((e) => e as Map<String, dynamic>).toList();
      }
    } catch (e) {
      if (kDebugMode) return [];
    }
    return [];
  }
}
