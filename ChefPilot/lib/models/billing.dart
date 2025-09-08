import 'dart:convert';

class Pricing {
  final String featureId;
  final double standalonePricePerUser; // price when sold standalone
  final double
      parentTenantPricePerUser; // price when sold as part of parent tenant
  final int trialDays; // trial period in days
  final bool hasOverride; // whether a custom override exists
  final Map<String, dynamic>? override; // free-form override details
  final DateTime? effectiveAt;
  final String? serverId;
  final double? price;
  final String? priceType; // 'standalone' or 'parent'

  Pricing({
    required this.featureId,
    required this.standalonePricePerUser,
    required this.parentTenantPricePerUser,
    this.trialDays = 0,
    this.hasOverride = false,
    this.override,
    this.effectiveAt,
    this.serverId,
    this.price,
    this.priceType,
  });

  factory Pricing.fromJson(Map<String, dynamic> j) => Pricing(
        featureId: j['featureId'] ?? j['id'] ?? '',
        standalonePricePerUser: (j['standalonePricePerUser'] is num)
            ? (j['standalonePricePerUser'] as num).toDouble()
            : double.tryParse(
                    '${j['standalonePricePerUser'] ?? j['pricePerUserMonthly'] ?? 0.0}') ??
                0.0,
        parentTenantPricePerUser: (j['parentTenantPricePerUser'] is num)
            ? (j['parentTenantPricePerUser'] as num).toDouble()
            : double.tryParse(
                    '${j['parentTenantPricePerUser'] ?? j['pricePerUserMonthly'] ?? 0.0}') ??
                0.0,
        trialDays: (j['trialDays'] is num)
            ? (j['trialDays'] as num).toInt()
            : int.tryParse('${j['trialDays'] ?? 0}') ?? 0,
        hasOverride: j['override'] != null,
        override: (() {
          final o = j['override'];
          if (o == null) return null;
          if (o is Map<String, dynamic>)
            return o..putIfAbsent('fromServer', () => true);
          if (o is String) {
            try {
              final parsed = jsonDecode(o);
              if (parsed is Map<String, dynamic>)
                return parsed..putIfAbsent('fromServer', () => true);
              return {'value': parsed, 'fromServer': true};
            } catch (_) {
              return {'raw': o, 'fromServer': true};
            }
          }
          return null;
        })(),
        effectiveAt:
            j['effectiveAt'] != null ? DateTime.parse(j['effectiveAt']) : null,
        serverId: j['id'] != null ? '${j['id']}' : null,
        price: (j['price'] is num)
            ? (j['price'] as num).toDouble()
            : (j['price'] != null ? double.tryParse('${j['price']}') : null),
        priceType: j['priceType'] != null ? '${j['priceType']}' : null,
      );

  Map<String, dynamic> toJson() => {
        'featureId': featureId,
        'standalonePricePerUser': standalonePricePerUser,
        'parentTenantPricePerUser': parentTenantPricePerUser,
        'trialDays': trialDays,
        'override': override,
        'effectiveAt': effectiveAt?.toUtc().toIso8601String(),
        if (serverId != null) 'id': serverId,
        if (price != null) 'price': price,
        if (priceType != null) 'priceType': priceType,
      };
}
