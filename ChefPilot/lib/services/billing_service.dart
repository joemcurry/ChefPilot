import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/billing.dart';
import 'auth_service.dart';

class BillingService {
  final AuthService auth;
  BillingService(this.auth);

  Future<List<Pricing>> fetchCurrentPricing() async {
    final url = Uri.parse('${auth.baseUrl}/api/billing/current');
    try {
      final resp = await http.get(url, headers: auth.headers());
      if (resp.statusCode == 200) {
        final list = jsonDecode(resp.body) as List<dynamic>;
        return list
            .map((e) => Pricing.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) {
        return [
          Pricing(
            featureId: 'default',
            standalonePricePerUser: 9.99,
            parentTenantPricePerUser: 7.99,
            trialDays: 14,
          )
        ];
      }
    }
    return [];
  }

  Future<List<Pricing>> fetchFuturePricing() async {
    final url = Uri.parse('${auth.baseUrl}/api/billing/future');
    try {
      final resp = await http.get(url, headers: auth.headers());
      if (resp.statusCode == 200) {
        final list = jsonDecode(resp.body) as List<dynamic>;
        return list
            .map((e) => Pricing.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) {
        return [
          Pricing(
            featureId: 'promo',
            standalonePricePerUser: 7.5,
            parentTenantPricePerUser: 5.5,
            trialDays: 7,
            effectiveAt: DateTime.now().add(const Duration(days: 30)),
          )
        ];
      }
    }
    return [];
  }

  Future<bool> schedulePriceUpdate(Pricing p) async {
    final url = Uri.parse('${auth.baseUrl}/api/billing/schedule');
    try {
      final resp = await http.post(url,
          headers: auth.headers(), body: jsonEncode(p.toJson()));
      return resp.statusCode == 200 || resp.statusCode == 201;
    } catch (e) {
      if (kDebugMode) return true;
      return false;
    }
  }

  Future<bool> updateSchedule(String id, Pricing p) async {
    final url =
        Uri.parse('${auth.baseUrl}/api/billing/${Uri.encodeComponent(id)}');
    final body = {
      'featureId': p.featureId,
      'standalonePricePerUser': p.standalonePricePerUser,
      'parentTenantPricePerUser': p.parentTenantPricePerUser,
      'trialDays': p.trialDays,
      'override': p.override,
      'effectiveAt': p.effectiveAt?.toUtc().toIso8601String(),
    };
    try {
      final resp =
          await http.put(url, headers: auth.headers(), body: jsonEncode(body));
      return resp.statusCode == 200 ||
          resp.statusCode == 204 ||
          resp.statusCode == 201;
    } catch (e) {
      if (kDebugMode) return true;
      return false;
    }
  }

  // Fetch all tenant-specific overrides
  Future<List<Pricing>> fetchOverrides() async {
    final url = Uri.parse('${auth.baseUrl}/api/pricing-overrides');
    try {
      final resp = await http.get(url, headers: auth.headers());
      if (resp.statusCode == 200) {
        final list = jsonDecode(resp.body) as List<dynamic>;
        return list
            .map((e) => Pricing.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) return [];
    }
    return [];
  }

  Future<String?> createOverride(String tenantId, Pricing p) async {
    final url = Uri.parse('${auth.baseUrl}/api/pricing-overrides');
    final body = {
      'tenantId': tenantId,
      'featureId': p.featureId,
      'standalonePricePerUser': p.standalonePricePerUser,
      'parentTenantPricePerUser': p.parentTenantPricePerUser,
      'trialDays': p.trialDays,
      'override': p.override,
      'effectiveAt': p.effectiveAt?.toUtc().toIso8601String(),
      'price': p.price,
      'priceType': p.priceType,
    };
    try {
      final resp =
          await http.post(url, headers: auth.headers(), body: jsonEncode(body));
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final j = jsonDecode(resp.body) as Map<String, dynamic>;
        return j['id'] as String?;
      }
    } catch (e) {
      if (kDebugMode) return 'mock-id';
    }
    return null;
  }

  Future<bool> deleteOverride(String id) async {
    final url = Uri.parse(
        '${auth.baseUrl}/api/pricing-overrides/${Uri.encodeComponent(id)}');
    try {
      final resp = await http.delete(url, headers: auth.headers());
      return resp.statusCode == 200 || resp.statusCode == 204;
    } catch (e) {
      if (kDebugMode) return true;
    }
    return false;
  }

  Future<bool> updateOverride(String id, Pricing p) async {
    final url = Uri.parse(
        '${auth.baseUrl}/api/pricing-overrides/${Uri.encodeComponent(id)}');
    final body = {
      'featureId': p.featureId,
      'standalonePricePerUser': p.standalonePricePerUser,
      'parentTenantPricePerUser': p.parentTenantPricePerUser,
      'trialDays': p.trialDays,
      'override': p.override,
      'effectiveAt': p.effectiveAt?.toUtc().toIso8601String(),
      'price': p.price,
      'priceType': p.priceType,
    };
    try {
      final resp =
          await http.put(url, headers: auth.headers(), body: jsonEncode(body));
      return resp.statusCode == 200 || resp.statusCode == 204;
    } catch (e) {
      if (kDebugMode) return true;
    }
    return false;
  }
}
