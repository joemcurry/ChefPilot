import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config.dart';

class AuthService extends ChangeNotifier {
  String? _token;
  String? get token => _token;
  String? _currentUserId;
  String? get currentUserId => _currentUserId;
  void setCurrentUserId(String id) {
    _currentUserId = id;
    notifyListeners();
  }

  final String baseUrl = apiBaseUrl();

  Future<bool> login(String username, String password) async {
    final uri = Uri.parse('$baseUrl/api/auth/login');
    try {
      final resp = await http.post(uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'username': username, 'password': password}));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        _token = data['token'] ?? 'mock-token';
        // if API returns a user id, store it; otherwise keep existing
        _currentUserId = data['userId'] ?? _currentUserId;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      // API unreachable — use mock success for development
      if (kDebugMode) {
        _token = 'mock-token';
        _currentUserId = 'owner-1';
        notifyListeners();
        return true;
      }
      return false;
    }
  }

  Map<String, String> headers() {
    final h = {'Content-Type': 'application/json'};
    if (_token != null) h['Authorization'] = 'Bearer $_token';
    return h;
  }

  /// Clear authentication state (logout)
  void logout() {
    _token = null;
    notifyListeners();
  }
}
