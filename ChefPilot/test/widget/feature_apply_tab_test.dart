import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:chefpilot/screens/feature_management_screen.dart';
import 'package:chefpilot/services/feature_service.dart';
import 'package:chefpilot/services/auth_service.dart';
import 'package:chefpilot/models/feature.dart';
import 'package:http/http.dart' as http;

class FakeFeatureService extends FeatureService {
  final List<Feature> _features;
  FakeFeatureService(this._features) : super(client: http.Client(), auth: null);

  @override
  Future<List<Feature>> list() async => _features;

  @override
  Future<void> applyToTenant(String tenantId, String featureId) async {}

  @override
  Future<void> removeFromTenant(String tenantId, String featureId) async {}

  @override
  Future<Feature> create(String name, String description, bool enabled) async =>
      Feature(
          id: 'new', name: name, description: description, enabled: enabled);

  @override
  Future<void> delete(String id) async {}

  @override
  Future<List<Map<String, dynamic>>> listForTenant(String tenantId) async => [];

  @override
  Future<void> update(Feature feature) async {}

  // other methods keep default behavior by forwarding to super
}

class FakeAuth extends AuthService {
  FakeAuth() : super();
  @override
  Map<String, String> headers() => {'authorization': 'Bearer test-token'};
}

void main() {
  testWidgets('Apply tab shows dropdowns and buttons',
      (WidgetTester tester) async {
    final fakeFeatures = [
      Feature(id: 'f1', name: 'Alpha', description: '', enabled: true)
    ];
    final svc = FakeFeatureService(fakeFeatures);
    final auth = FakeAuth();

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthService>.value(
        value: auth,
        child: MaterialApp(
          home: FeatureManagementScreen(service: svc),
        ),
      ),
    );

    // Wait for async loads
    await tester.pumpAndSettle();

    // switch to Apply to Tenant tab
    expect(find.text('Apply to Tenant'), findsOneWidget);
    await tester.tap(find.text('Apply to Tenant'));
    await tester.pumpAndSettle();

    expect(find.text('Select tenant'), findsOneWidget);
    expect(find.text('Select feature'), findsOneWidget);
    expect(find.text('Apply'), findsOneWidget);
    expect(find.text('Remove'), findsOneWidget);
  });
}
