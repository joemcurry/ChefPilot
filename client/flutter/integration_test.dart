// Example integration test (Dart) - conceptual, run in Flutter integration or Dart VM with a configured test harness.
// This is illustrative; adapt to your test runner and environment.

import 'package:dio/dio.dart';

Future<void> main() async {
  final dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:3000'));
  // Login
  final r = await dio.post(
    '/api/auth/login',
    data: {'username': 'admin', 'password': 'password123'},
  );
  final token = r.data['token'];
  final refresh = r.data['refresh_token'];

  // Use token to create tenant
  dio.options.headers['Authorization'] = 'Bearer $token';
  final t = await dio.post('/api/tenants', data: {'name': 'it-test-tenant'});
  final tenantId = t.data['id'];

  // Create temperature log
  final log = await dio.post(
    '/api/temperature-logs',
    data: {
      'tenant_id': tenantId,
      'temperature': 40,
      'safe_min': 35,
      'safe_max': 45,
    },
  );
  print('Created log: ${log.data['id']}');

  // Simulate access token expiry by clearing header and attempting protected request -> requires refresh
  dio.options.headers.remove('Authorization');
  // Attempt to refresh
  final r2 = await dio.post(
    '/api/auth/refresh',
    data: {'refresh_token': refresh},
  );
  print('Refreshed token: ${r2.data['token']}');
}
