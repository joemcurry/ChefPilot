import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../models/feature.dart';
import '../config.dart';

class FeatureService {
  final String baseUrl;
  final http.Client client;
  final AuthService? auth;
  FeatureService({String? baseUrl, http.Client? client, this.auth})
      : baseUrl = baseUrl ?? '${apiBaseUrl()}/api/features',
        client = client ?? http.Client();

  Map<String, String> _headers([Map<String, String>? extra]) {
    final h = <String, String>{'Content-Type': 'application/json'};
    if (auth != null) h.addAll(auth!.headers());
    if (extra != null) h.addAll(extra);
    return h;
  }

  Future<List<Feature>> list() async {
    final resp = await client.get(Uri.parse(baseUrl), headers: _headers());
    if (resp.statusCode != 200) {
      final body = resp.body;
      throw Exception('status:${resp.statusCode} body:$body');
    }
    try {
      final List decoded = json.decode(resp.body) as List;
      return decoded.map((e) => Feature.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to parse features: $e body:${resp.body}');
    }
  }

  Future<Feature> create(String name, String description, bool enabled) async {
    final resp = await client.post(Uri.parse(baseUrl),
        headers: _headers(),
        body: json.encode({
          'name': name,
          'description': description,
          'enabled': enabled ? 1 : 0
        }));
    if (resp.statusCode != 200 && resp.statusCode != 201) {
      throw Exception('Failed to create feature');
    }
    final decoded = json.decode(resp.body);
    if (decoded is Map<String, dynamic> &&
        decoded.containsKey('id') &&
        decoded.containsKey('name')) {
      return Feature.fromJson(Map<String, dynamic>.from(decoded));
    }
    // fallback: server returned only id
    final id = (decoded is Map && decoded['id'] != null)
        ? decoded['id'] as String
        : DateTime.now().millisecondsSinceEpoch.toString();
    return Feature(
        id: id, name: name, description: description, enabled: enabled);
  }

  Future<void> update(Feature feature) async {
    final resp = await client.put(Uri.parse('$baseUrl/${feature.id}'),
        headers: _headers(), body: json.encode(feature.toJson()));
    if (resp.statusCode != 200) throw Exception('Failed to update feature');
  }

  Future<void> delete(String id) async {
    final resp =
        await client.delete(Uri.parse('$baseUrl/$id'), headers: _headers());
    if (resp.statusCode != 200) throw Exception('Failed to delete feature');
  }

  // Tenant-feature mappings
  Future<List<Map<String, dynamic>>> listForTenant(String tenantId) async {
    final url =
        baseUrl.replaceFirst('/features', '/tenant-features/tenant/$tenantId');
    final resp = await client.get(Uri.parse(url), headers: _headers());
    if (resp.statusCode != 200) {
      throw Exception('Failed to list tenant features');
    }
    final decoded = json.decode(resp.body) as List;
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<void> applyToTenant(String tenantId, String featureId) async {
    final url = baseUrl.replaceFirst('/features', '/tenant-features');
    // include development sudo header so local dev UI can perform tenant actions
    final resp = await client.post(Uri.parse(url),
        headers: _headers({'x-dev-sudo': '1'}),
        body: json.encode({'tenant_id': tenantId, 'feature_id': featureId}));
    if (resp.statusCode != 200) {
      final body = resp.body;
      throw Exception('status:$resp.statusCode body:$body');
    }
  }

  Future<void> removeFromTenant(String tenantId, String featureId) async {
    final url = baseUrl.replaceFirst(
        '/features', '/tenant-features/$tenantId/$featureId');
    final resp = await client.delete(Uri.parse(url),
        headers: _headers({'x-dev-sudo': '1'}));
    if (resp.statusCode != 200) {
      final body = resp.body;
      throw Exception('status:$resp.statusCode body:$body');
    }
  }
}
