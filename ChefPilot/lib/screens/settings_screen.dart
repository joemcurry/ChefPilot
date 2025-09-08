import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../services/billing_service.dart';
import '../models/billing.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Pricing> current = [];
  List<Pricing> currentAggregated = [];
  List<Pricing> future = []; // still used as storage for server-scheduled items
  List<Pricing> custom = [];
  List<Map<String, String>> tenants = [];
  bool loading = true;

  // (legacy) Manage form controllers removed; dialogs create their own controllers

  // expansion state tracking (unused) -- removed to clean analyzer warning
  // inline editors per item
  final Map<String, TextEditingController> _nameControllers = {};
  final Map<String, TextEditingController> _standaloneControllers = {};
  final Map<String, TextEditingController> _parentControllers = {};
  final Map<String, TextEditingController> _trialControllers = {};
  // inline delete confirmation state

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
    _loadTenants();
    _loadOverrides();
    // sample custom entries
    custom = [
      Pricing(
          featureId: 'Fall 2025',
          standalonePricePerUser: 8.99,
          parentTenantPricePerUser: 6.99,
          trialDays: 14,
          effectiveAt: DateTime.parse('2025-09-01T00:00:00Z')),
      Pricing(
          featureId: 'Winter 2025',
          standalonePricePerUser: 10.99,
          parentTenantPricePerUser: 8.99,
          trialDays: 7,
          effectiveAt: DateTime.parse('2025-12-01T00:00:00Z')),
    ];
  }

  @override
  void dispose() {
    // Dispose any inline controllers we created
    for (final c in _nameControllers.values) {
      c.dispose();
    }
    for (final c in _standaloneControllers.values) {
      c.dispose();
    }
    for (final c in _parentControllers.values) {
      c.dispose();
    }
    for (final c in _trialControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final auth = Provider.of<AuthService>(context, listen: false);
    final billing = BillingService(auth);
    current = await billing.fetchCurrentPricing();
    future = await billing.fetchFuturePricing();
    // Build aggregated current view: two items (Standalone, Parent)
    currentAggregated = [];
    if (current.isNotEmpty) {
      // Use the first current entry as baseline
      final base = current.first;
      String? standaloneServerId;
      String? parentServerId;
      for (final c in current) {
        if (standaloneServerId == null &&
            (c.priceType == 'standalone' || c.standalonePricePerUser > 0))
          standaloneServerId = c.serverId;
        if (parentServerId == null &&
            (c.priceType == 'parent' || c.parentTenantPricePerUser > 0))
          parentServerId = c.serverId;
        if (standaloneServerId != null && parentServerId != null) break;
      }
      currentAggregated.add(Pricing(
        featureId: 'Standalone',
        standalonePricePerUser: base.standalonePricePerUser,
        parentTenantPricePerUser: base.parentTenantPricePerUser,
        trialDays: base.trialDays,
        hasOverride: false,
        override: null,
        effectiveAt: base.effectiveAt,
        serverId: standaloneServerId,
        price: base.price ?? base.standalonePricePerUser,
        priceType: 'standalone',
      ));
      currentAggregated.add(Pricing(
        featureId: 'Parent',
        standalonePricePerUser: base.standalonePricePerUser,
        parentTenantPricePerUser: base.parentTenantPricePerUser,
        trialDays: base.trialDays,
        hasOverride: false,
        override: null,
        effectiveAt: base.effectiveAt,
        serverId: parentServerId,
        price: base.price ?? base.parentTenantPricePerUser,
        priceType: 'parent',
      ));
    }
    setState(() => loading = false);
  }

  Future<void> _loadTenants() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    try {
      final url = Uri.parse('${auth.baseUrl}/api/tenants');
      final resp = await http.get(url, headers: auth.headers());
      if (resp.statusCode == 200) {
        final list = (resp.body.isNotEmpty)
            ? (List<Map<String, dynamic>>.from(jsonDecode(resp.body)))
            : [];
        tenants = list
            .map((e) => {
                  'id': '${e['id'] ?? e['name']}',
                  'name': '${e['name'] ?? e['id'] ?? 'Tenant'}',
                  'type': '${e['type'] ?? ''}'
                })
            .toList();
      }
    } catch (_) {
      tenants = [
        {'id': 't-acme', 'name': 'Acme Corporation'},
        {'id': 't-beta', 'name': 'Beta Logistics'},
        {'id': 't-gamma', 'name': 'Gamma Retail'},
      ];
    }
    if (mounted) setState(() {});
  }

  String _priceTypeForTenantId(String? tenantId) {
    if (tenantId == null) return 'standalone';
    final t = tenants.firstWhere((e) => e['id'] == tenantId,
        orElse: () => {'type': ''});
    final type = (t['type'] ?? '').toString().toLowerCase();
    // treat ParentClient (or parent) as parent pricing
    if (type.contains('parent')) return 'parent';
    return 'standalone';
  }

  Future<void> _loadOverrides() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final billing = BillingService(auth);
    final list = await billing.fetchOverrides();
    // store server overrides in the custom list (merge with existing samples)
    setState(() {
      // prefer server list if present
      if (list.isNotEmpty) {
        custom = list;
      }
    });
  }

  // Helpers: dialogs for add / update / delete actions
  Future<void> _showAddCustomDialog() async {
    final nameController = TextEditingController();
    final priceController = TextEditingController(text: '9.99');
    final trialController = TextEditingController(text: '14');
    Map<String, String>? selectedTenant;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setSt) {
          return AlertDialog(
            title: const Text('Add custom pricing (requires tenant)'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<Map<String, String>>(
                  initialValue: selectedTenant,
                  items: tenants
                      .map((t) =>
                          DropdownMenuItem(value: t, child: Text(t['name']!)))
                      .toList(),
                  hint: const Text('Select tenant'),
                  onChanged: (v) => setSt(() => selectedTenant = v),
                ),
                const SizedBox(height: 8),
                TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Pricing name')),
                const SizedBox(height: 8),
                TextField(
                    controller: priceController,
                    decoration: InputDecoration(labelText: 'Price'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true)),
                TextField(
                    controller: trialController,
                    decoration: InputDecoration(labelText: 'Trial days')),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  if (selectedTenant == null ||
                      nameController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Tenant and name required')));
                    return;
                  }
                  final parsedPrice =
                      double.tryParse(priceController.text) ?? 0.0;
                  final tenantType =
                      _priceTypeForTenantId(selectedTenant!['id']);
                  final p = Pricing(
                    featureId: nameController.text.trim(),
                    standalonePricePerUser:
                        tenantType == 'standalone' ? parsedPrice : 0.0,
                    parentTenantPricePerUser:
                        tenantType == 'parent' ? parsedPrice : 0.0,
                    trialDays: int.tryParse(trialController.text) ?? 0,
                    hasOverride: true,
                    override: {'tenantId': selectedTenant!['id']},
                    effectiveAt: DateTime.now(),
                    price: parsedPrice,
                    priceType: tenantType,
                  );
                  final auth = Provider.of<AuthService>(context, listen: false);
                  final billing = BillingService(auth);
                  final id =
                      await billing.createOverride(selectedTenant!['id']!, p);
                  if (id != null) {
                    // attach server id and reload from server
                    await _loadOverrides();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('Created')));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to create')));
                  }
                  Navigator.of(context).pop();
                },
                child: const Text('Create'),
              ),
            ],
          );
        });
      },
    );
  }

  Future<void> _showUpdateDialog(Pricing p, {bool isCustom = false}) async {
    final nameController = TextEditingController(text: p.featureId);
    final priceController = TextEditingController(
        text: p.price?.toString() ?? p.standalonePricePerUser.toString());
    String priceTypeValue = p.priceType ?? 'standalone';
    final trialController = TextEditingController(text: p.trialDays.toString());

    await showDialog<void>(
      context: context,
      builder: (context) {
        // Use StatefulBuilder so the dropdown can update local state
        return StatefulBuilder(builder: (context, setSt) {
          return AlertDialog(
            title: const Text('Update pricing'),
            content: SizedBox(
              width: 540,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Name')),
                  const SizedBox(height: 8),
                  TextField(
                      controller: priceController,
                      decoration: InputDecoration(labelText: 'Price'),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true)),
                  const SizedBox(height: 8),
                  // For custom overrides, the tenant determines priceType; hide selector
                  const SizedBox(height: 8),
                  TextField(
                      controller: trialController,
                      decoration: InputDecoration(labelText: 'Trial days'),
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: false)),
                ],
              ),
            ),
            actions: [
              // Delete on the left as a warm red outlined button
              OutlinedButton(
                onPressed: () async {
                  if (!isCustom) {
                    Navigator.of(context).pop();
                    return;
                  }
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Confirm delete'),
                      content: const Text('Delete this custom pricing?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Cancel')),
                        TextButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text('Delete',
                                style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  );
                  if (confirm != true) return;
                  if (p.serverId != null) {
                    final auth =
                        Provider.of<AuthService>(context, listen: false);
                    final billing = BillingService(auth);
                    final ok = await billing.deleteOverride(p.serverId!);
                    if (ok) {
                      await _loadOverrides();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Deleted')));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to delete')));
                    }
                  } else {
                    final idx = custom.indexWhere((c) =>
                        c.featureId == p.featureId &&
                        c.effectiveAt == p.effectiveAt);
                    if (idx != -1) setState(() => custom.removeAt(idx));
                  }
                  Navigator.of(context).pop();
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.deepOrange),
                  foregroundColor: Colors.deepOrange,
                ),
                child: const Text('Delete'),
              ),
              // Spacer to push update to the right
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  // prepare standalone/parent values from price/priceType
                  final parsedPrice = double.tryParse(priceController.text);
                  double newStandalone = p.standalonePricePerUser;
                  double newParent = p.parentTenantPricePerUser;
                  if (parsedPrice != null) {
                    // Determine priceType for custom overrides using the override.tenantId if present
                    String effectivePriceType = priceTypeValue;
                    if (isCustom) {
                      final tenantId = p.override != null &&
                              p.override is Map<String, dynamic>
                          ? (p.override as Map<String, dynamic>)['tenantId']
                              as String?
                          : null;
                      effectivePriceType = _priceTypeForTenantId(tenantId);
                    }
                    if (effectivePriceType == 'standalone') {
                      newStandalone = parsedPrice;
                    } else {
                      newParent = parsedPrice;
                    }
                    priceTypeValue = effectivePriceType;
                  }

                  final updated = Pricing(
                    featureId: nameController.text.trim(),
                    standalonePricePerUser: newStandalone,
                    parentTenantPricePerUser: newParent,
                    trialDays: int.tryParse(trialController.text) ?? 0,
                    hasOverride: p.hasOverride,
                    override: p.override,
                    effectiveAt: isCustom
                        ? p.effectiveAt
                        : (p.effectiveAt ?? DateTime.now()),
                    price: parsedPrice,
                    priceType: priceTypeValue,
                  );
                  if (isCustom) {
                    final auth =
                        Provider.of<AuthService>(context, listen: false);
                    final billing = BillingService(auth);
                    if (p.serverId != null) {
                      final ok =
                          await billing.updateOverride(p.serverId!, updated);
                      if (ok) {
                        await _loadOverrides();
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Updated')));
                      } else {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to update')));
                      }
                    } else {
                      final tenantId = p.override != null &&
                              p.override is Map<String, dynamic>
                          ? (p.override as Map<String, dynamic>)['tenantId']
                          : null;
                      if (tenantId != null) {
                        final newId =
                            await billing.createOverride('$tenantId', updated);
                        if (newId != null) {
                          await _loadOverrides();
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Saved to server')));
                        } else {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Failed to save')));
                        }
                      } else {
                        final idx = custom.indexWhere((c) =>
                            c.featureId == p.featureId &&
                            c.effectiveAt == p.effectiveAt);
                        if (idx != -1) setState(() => custom[idx] = updated);
                      }
                    }
                  } else {
                    final auth =
                        Provider.of<AuthService>(context, listen: false);
                    final billing = BillingService(auth);
                    bool ok = false;
                    if (p.serverId != null) {
                      ok = await billing.updateSchedule(p.serverId!, updated);
                    } else {
                      ok = await billing.schedulePriceUpdate(updated);
                    }
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(ok
                            ? (p.serverId != null ? 'Updated' : 'Scheduled')
                            : 'Failed')));
                    if (ok) await _load();
                  }
                  Navigator.of(context).pop();
                },
                // Use default button styling for Update
                child: const Text('Update'),
              ),
            ],
          );
        });
      },
    );
  }

  // deletion is handled inline in the expanded UI

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        bottom: TabBar(controller: _tabController, tabs: const [
          Tab(text: 'Current Pricing'),
          Tab(text: 'Custom Pricing'),
        ]),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Current pricing list - compact cards
                ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  itemCount: currentAggregated.isNotEmpty
                      ? currentAggregated.length
                      : current.length,
                  itemBuilder: (context, i) {
                    final p = currentAggregated.isNotEmpty
                        ? currentAggregated[i]
                        : current[i];
                    return Card(
                      elevation: 1,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: InkWell(
                        onTap: () => _showUpdateDialog(p, isCustom: false),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p.featureId,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 4),
                                    Text(
                                        '${p.priceType ?? 'standalone'} • ${p.trialDays}d',
                                        style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 12)),
                                    if (p.effectiveAt != null)
                                      Text(
                                          'Effective: ${p.effectiveAt!.toLocal().toIso8601String()}',
                                          style: const TextStyle(
                                              color: Colors.black45,
                                              fontSize: 11)),
                                  ],
                                ),
                              ),
                              Chip(
                                  label: Text(
                                      '\$${(p.price ?? p.standalonePricePerUser).toStringAsFixed(2)}')),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Custom pricing tab with add button and tenant-required flow
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Custom Pricing',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600)),
                          ElevatedButton.icon(
                            onPressed: () => _showAddCustomDialog(),
                            icon: const Icon(Icons.add),
                            label: const Text('Add'),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: custom.length,
                        itemBuilder: (context, i) {
                          final p = custom[i];
                          // final expanded = _expanded[key] ?? false;
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: InkWell(
                              onTap: () => _showUpdateDialog(p, isCustom: true),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(p.featureId,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600)),
                                        Chip(
                                            label: Text(
                                                '\$${(p.price ?? p.standalonePricePerUser).toStringAsFixed(2)}')),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                        '${p.priceType ?? 'standalone'} • ${p.trialDays}d',
                                        style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 12)),
                                    if (p.effectiveAt != null)
                                      Text(
                                          'Effective: ${p.effectiveAt!.toLocal().toIso8601String()}',
                                          style: const TextStyle(
                                              color: Colors.black45,
                                              fontSize: 11)),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ],
            ),
    );
  }
}
