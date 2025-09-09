import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/feature.dart';

class FeatureService {
  final String baseUrl;
  FeatureService({this.baseUrl = 'http://127.0.0.1:3000/api/features'});

  Future<List<Feature>> list() async {
    final resp = await http.get(Uri.parse(baseUrl));
    if (resp.statusCode != 200) throw Exception('Failed to load features');
    final List decoded = json.decode(resp.body) as List;
    return decoded.map((e) => Feature.fromJson(e)).toList();
  }

  Future<Feature> create(String name, String description, bool enabled) async {
    final resp = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'description': description,
        'enabled': enabled ? 1 : 0,
      }),
    );
    if (resp.statusCode != 200 && resp.statusCode != 201)
      throw Exception('Failed to create feature');
    final decoded = json.decode(resp.body) as Map<String, dynamic>;
    // server returns { id: '...' }
    final id = decoded['id'] as String;
    return Feature(
      id: id,
      name: name,
      description: description,
      enabled: enabled,
    );
  }

  Future<void> update(Feature feature) async {
    final resp = await http.put(
      Uri.parse('$baseUrl/${feature.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(feature.toJson()),
    );
    if (resp.statusCode != 200) throw Exception('Failed to update feature');
  }

  Future<void> delete(String id) async {
    final resp = await http.delete(Uri.parse('$baseUrl/$id'));
    if (resp.statusCode != 200) throw Exception('Failed to delete feature');
  }
}
