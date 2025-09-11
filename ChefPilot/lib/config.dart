import 'dart:convert';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/services.dart' show rootBundle;

enum Environment { development, production }

class AppConfig {
  final Environment env;
  final String apiBase;

  const AppConfig._(this.env, this.apiBase);

  static const development =
      AppConfig._(Environment.development, 'http://127.0.0.1:3000');
  static const production =
      AppConfig._(Environment.production, 'https://api.example.com');

  static AppConfig current = kReleaseMode ? production : development;

  static void useProduction() => current = production;
  static void useDevelopment() => current = development;

  static Future<void> loadFromAsset(String path) async {
    try {
      final raw = await rootBundle.loadString(path);
      final parsed = jsonDecode(raw) as Map<String, dynamic>;
      final envStr =
          (parsed['environment'] ?? 'development').toString().toLowerCase();
      final api = parsed['apiBase']?.toString() ?? current.apiBase;
      current = envStr.startsWith('prod')
          ? AppConfig._(Environment.production, api)
          : AppConfig._(Environment.development, api);
    } catch (_) {
      // ignore and keep defaults
    }
  }
}

String apiBaseUrl() => AppConfig.current.apiBase;
