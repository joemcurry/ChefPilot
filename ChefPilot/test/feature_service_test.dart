import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:chefpilot/services/feature_service.dart';
import 'package:chefpilot/models/feature.dart';

void main() {
  test('FeatureService.list parses features', () async {
    final mockClient = MockClient((req) async {
      return http.Response(
          json.encode([
            {'id': 'f1', 'name': 'Alpha', 'description': 'A', 'enabled': 1},
            {'id': 'f2', 'name': 'Beta', 'description': 'B', 'enabled': 0}
          ]),
          200);
    });

    final svc = FeatureService(client: mockClient);
    final list = await svc.list();
    expect(list, isA<List<Feature>>());
    expect(list.length, 2);
    expect(list.first.name, 'Alpha');
  });
}
