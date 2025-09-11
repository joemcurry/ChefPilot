import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/feature.dart';
import '../services/feature_service.dart';

class FeatureManagementScreen extends StatefulWidget {
  final FeatureService? service;
  const FeatureManagementScreen({super.key, this.service});

  @override
  State<FeatureManagementScreen> createState() =>
      _FeatureManagementScreenState();
}

class _FeatureManagementScreenState extends State<FeatureManagementScreen>
    with SingleTickerProviderStateMixin {
  late final FeatureService _service;
  late TabController _tabController;
  List<Feature> _features = [];
  bool _loading = true;
  List<Map<String, String>> _tenants = [];
  String? _selectedTenantForCustom;
  List<Map<String, dynamic>> _appliedFeatures = [];
  List<Map<String, String>> _tenantsWithCustom = [];
  // tenant/feature selection is handled locally in dialogs now

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthService>(context, listen: false);
    _service = widget.service ?? FeatureService(auth: auth);
    _tabController = TabController(length: 2, vsync: this);
    _load();
    _loadTenants();
    _tabController.addListener(() {
      if (_tabController.index == 1) {
        // when Custom Feature tab selected, ensure we have tenants and applied features loaded
        if (_tenantsWithCustom.isEmpty) {
          _loadTenants();
        } else if (_selectedTenantForCustom != null) {
          _loadAppliedForTenant(_selectedTenantForCustom!);
        } else if (_tenantsWithCustom.isNotEmpty) {
          _selectedTenantForCustom = _tenantsWithCustom.first['id'];
          _loadAppliedForTenant(_selectedTenantForCustom!);
        }
      }
    });
  }

  Future<void> _loadTenants() async {
    try {
      // fetch tenants via API path with auth headers
      final tenantsUrl =
          Uri.parse(_service.baseUrl.replaceFirst('/features', '/tenants'));
      final auth = Provider.of<AuthService>(context, listen: false);
      final r = await _service.client.get(tenantsUrl, headers: auth.headers());
      if (r.statusCode == 200) {
        final list = (r.body.isNotEmpty) ? (json.decode(r.body) as List) : [];
        if (!mounted) {
          return;
        }
        setState(() {
          _tenants = list
              .map((e) =>
                  {'id': '${e['id']}', 'name': '${e['name'] ?? e['id']}'})
              .toList()
              .cast<Map<String, String>>();
        });
        // determine tenants that currently have custom features
        _tenantsWithCustom = [];
        for (final t in _tenants) {
          try {
            final listForT = await _service.listForTenant(t['id']!);
            if (listForT.isNotEmpty) {
              _tenantsWithCustom.add(t);
            }
          } catch (_) {}
        }
        if (mounted) setState(() {});
        // after tenantsWithCustom loaded, pick a default and load applied features
        if (_tenantsWithCustom.isNotEmpty && _selectedTenantForCustom == null) {
          _selectedTenantForCustom = _tenantsWithCustom.first['id'];
          await _loadAppliedForTenant(_selectedTenantForCustom!);
        }
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _tenants = [
          {'id': 't-acme', 'name': 'Acme Corporation'},
          {'id': 't-beta', 'name': 'Beta Logistics'}
        ];
      });
    }
  }

  Future<void> _loadAppliedForTenant(String tenantId) async {
    try {
      final list = await _service.listForTenant(tenantId);
      if (!mounted) return;
      setState(() => _appliedFeatures = list);
    } catch (e) {
      debugPrint('[FeatureManagement] failed to load applied features: $e');
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(SnackBar(
          content: Text('Failed to load applied features: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade700));
    }
  }

  // _showEditAppliedDialog removed: applied feature items are now non-interactive and use delete icon

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await _service.list();
      setState(() => _features = list);
      debugPrint('[FeatureManagement] loaded ${list.length} features');
    } catch (e) {
      debugPrint('[FeatureManagement] load error: $e');
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(SnackBar(
          content: Text('Failed to load features: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade700));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _showEditDialog([Feature? f]) async {
    final nameCtrl = TextEditingController(text: f?.name ?? '');
    final descCtrl = TextEditingController(text: f?.description ?? '');
    bool enabled = f?.enabled ?? false;
    final result = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          return StatefulBuilder(builder: (ctx2, setSt) {
            return AlertDialog(
              title: Text(f == null ? 'Create Feature' : 'Edit Feature'),
              content: SizedBox(
                width: 640,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(labelText: 'Name')),
                    const SizedBox(height: 8),
                    TextField(
                        controller: descCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Description')),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      title: const Text(
                          'Available to tenants (tenants can enable/disable)'),
                      value: enabled,
                      onChanged: (v) => setSt(() => enabled = v ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('Cancel')),
                if (f != null)
                  OutlinedButton(
                    onPressed: () async {
                      // capture UI bindings
                      final messenger = ScaffoldMessenger.of(context);
                      final dialogNavigator = Navigator.of(ctx);

                      final confirm = await showDialog<bool>(
                          context: ctx,
                          builder: (c) => AlertDialog(
                                title: const Text('Delete feature'),
                                content: Text('Delete "${f.name}"?'),
                                actions: [
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.of(c).pop(false),
                                      child: const Text('Cancel')),
                                  ElevatedButton(
                                      onPressed: () =>
                                          Navigator.of(c).pop(true),
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.redAccent),
                                      child: const Text('Delete'))
                                ],
                              ));
                      if (confirm == true) {
                        try {
                          await _service.delete(f.id);
                          messenger.showSnackBar(SnackBar(
                              content: const Text('Feature deleted'),
                              backgroundColor: Colors.red.shade700,
                              behavior: SnackBarBehavior.floating));
                          dialogNavigator.pop(true);
                        } catch (e) {
                          messenger.showSnackBar(
                              const SnackBar(content: Text('Delete failed')));
                        }
                      }
                    },
                    child: const Text('Delete'),
                  ),
                ElevatedButton(
                    onPressed: () async {
                      // Capture UI bindings before any await to avoid using BuildContext
                      final messenger = ScaffoldMessenger.of(context);
                      final dialogNavigator = Navigator.of(ctx);

                      final name = nameCtrl.text.trim();
                      final desc = descCtrl.text.trim();
                      if (name.isEmpty) {
                        messenger.showSnackBar(
                            const SnackBar(content: Text('Name is required')));
                        return;
                      }
                      try {
                        if (f == null) {
                          final created =
                              await _service.create(name, desc, enabled);
                          if (created.id.isNotEmpty) {
                            messenger.showSnackBar(SnackBar(
                                content: const Text('Feature created'),
                                backgroundColor: Colors.green.shade700,
                                behavior: SnackBarBehavior.floating));
                          }
                        } else {
                          final updated = Feature(
                              id: f.id,
                              name: name,
                              description: desc,
                              enabled: enabled);
                          await _service.update(updated);
                          messenger.showSnackBar(SnackBar(
                              content: const Text('Feature updated'),
                              backgroundColor: Colors.blue.shade700,
                              behavior: SnackBarBehavior.floating));
                        }
                        dialogNavigator.pop(true);
                      } catch (e) {
                        messenger.showSnackBar(
                            const SnackBar(content: Text('Save failed')));
                      }
                    },
                    child: const Text('Save'))
              ],
            );
          });
        });
    if (result == true) await _load();
  }

  // _confirmDelete removed — deletion is handled inside the edit dialog now.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feature Management'), actions: [
        IconButton(
          tooltip: 'Refresh features',
          icon: const Icon(Icons.refresh),
          onPressed: _load,
        )
      ]),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TabBar(controller: _tabController, tabs: const [
                  Tab(text: 'Features'),
                  Tab(text: 'Custom Feature')
                ]),
                Expanded(
                  child: TabBarView(controller: _tabController, children: [
                    RefreshIndicator(
                      onRefresh: _load,
                      child: _features.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                ListTile(
                                  title: const Text('Features'),
                                  trailing: ElevatedButton.icon(
                                    onPressed: () => _showEditDialog(),
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add'),
                                  ),
                                ),
                                const SizedBox(height: 40),
                                Center(
                                  child: Text('No features found',
                                      style: TextStyle(
                                          color: Colors.grey.shade600)),
                                )
                              ],
                            )
                          : ListView.builder(
                              itemCount: _features.length + 1,
                              itemBuilder: (ctx, idx) {
                                if (idx == 0) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ListTile(
                                        title: const Text('Features'),
                                        trailing: ElevatedButton.icon(
                                          onPressed: () => _showEditDialog(),
                                          icon: const Icon(Icons.add),
                                          label: const Text('Add'),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 8),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }
                                final f = _features[idx - 1];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  child: ListTile(
                                    title: Text(f.name),
                                    subtitle: Text(f.description),
                                    leading: Switch(
                                      value: f.enabled,
                                      onChanged: (v) async {
                                        final updated = Feature(
                                            id: f.id,
                                            name: f.name,
                                            description: f.description,
                                            enabled: v);
                                        await _service.update(updated);
                                        await _load();
                                      },
                                    ),
                                    onTap: () => _showEditDialog(f),
                                  ),
                                );
                              },
                            ),
                    ),
                    // Custom Feature tab: tenant selector, Add Custom, and applied features list
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Tenant selector
                              if (_tenantsWithCustom.isNotEmpty)
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    initialValue: _selectedTenantForCustom,
                                    hint: const Text('Select tenant'),
                                    dropdownColor:
                                        Theme.of(context).canvasColor,
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      border: InputBorder.none,
                                    ),
                                    items: _tenantsWithCustom
                                        .map((t) => DropdownMenuItem(
                                            value: t['id'],
                                            child: Text(t['name']!)))
                                        .toList(),
                                    onChanged: (v) async {
                                      if (v == null) return;
                                      // remove focus so pressed/hover background is cleared
                                      FocusScope.of(context).unfocus();
                                      setState(
                                          () => _selectedTenantForCustom = v);
                                      await _loadAppliedForTenant(v);
                                    },
                                  ),
                                )
                              else
                                const Expanded(
                                    child: Text(
                                        'No tenants with custom features')),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  // open a dialog to create a custom apply
                                  String? tenant;
                                  String? featureId;
                                  final res = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) {
                                        return StatefulBuilder(
                                            builder: (ctx2, setSt) {
                                          return AlertDialog(
                                            title: const Text(
                                                'Apply custom feature'),
                                            content: SizedBox(
                                              width: 560,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  // tenant selector (required)
                                                  DropdownButtonFormField<
                                                      String>(
                                                    initialValue: tenant,
                                                    hint: const Text(
                                                        'Select tenant'),
                                                    items: _tenants
                                                        .map((t) =>
                                                            DropdownMenuItem(
                                                                value: t['id'],
                                                                child: Text(t[
                                                                    'name']!)))
                                                        .toList(),
                                                    onChanged: (v) =>
                                                        setSt(() => tenant = v),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  // feature selector: only include features not visible to all tenants
                                                  DropdownButtonFormField<
                                                      String>(
                                                    initialValue: featureId,
                                                    hint: const Text(
                                                        'Select feature'),
                                                    items: _features
                                                        .where(
                                                            (f) => !f.enabled)
                                                        .map((f) =>
                                                            DropdownMenuItem(
                                                                value: f.id,
                                                                child: Text(
                                                                    f.name)))
                                                        .toList(),
                                                    onChanged: (v) => setSt(
                                                        () => featureId = v),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(ctx)
                                                          .pop(false),
                                                  child: const Text('Cancel')),
                                              ElevatedButton(
                                                  onPressed:
                                                      (tenant != null &&
                                                              featureId != null)
                                                          ? () async {
                                                              try {
                                                                await _service
                                                                    .applyToTenant(
                                                                        tenant!,
                                                                        featureId!);
                                                                if (!mounted)
                                                                  return;
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(const SnackBar(
                                                                        content:
                                                                            Text('Custom feature applied')));
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(true);
                                                              } catch (e) {
                                                                final msg = e
                                                                    .toString();
                                                                String display =
                                                                    msg;
                                                                // server errors are thrown as 'status:<code> body:<body>'
                                                                final bodyIndex =
                                                                    msg.indexOf(
                                                                        ' body:');
                                                                if (bodyIndex !=
                                                                    -1) {
                                                                  display = msg
                                                                      .substring(
                                                                          bodyIndex +
                                                                              6);
                                                                }
                                                                if (!mounted)
                                                                  return;
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(SnackBar(
                                                                        content:
                                                                            Text('Failed to apply: $display')));
                                                              }
                                                            }
                                                          : null,
                                                  child: const Text('Apply'))
                                            ],
                                          );
                                        });
                                      });
                                  if (res == true) {
                                    // Recompute tenants and applied features so the UI picks up any newly-added tenant
                                    await _loadTenants();
                                    // If the dialog selected a tenant, prefer that tenant for showing applied features
                                    if (tenant != null) {
                                      setState(() =>
                                          _selectedTenantForCustom = tenant);
                                      await _loadAppliedForTenant(tenant!);
                                    } else if (_selectedTenantForCustom !=
                                        null) {
                                      await _loadAppliedForTenant(
                                          _selectedTenantForCustom!);
                                    }
                                    // refresh global features list
                                    await _load();
                                  }
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Add Custom'),
                              )
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Applied features list for selected tenant
                          Expanded(
                            child: _selectedTenantForCustom == null
                                ? Center(
                                    child: Text(
                                        'Select a tenant to view custom features'))
                                : _appliedFeatures.isEmpty
                                    ? Center(
                                        child: Text(
                                            'No custom features applied for selected tenant.'),
                                      )
                                    : ListView.builder(
                                        itemCount: _appliedFeatures.length,
                                        itemBuilder: (ctx, idx) {
                                          final af = _appliedFeatures[idx];
                                          return Card(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 6),
                                            child: ListTile(
                                              title: Text(af['name'] ??
                                                  af['feature_name'] ??
                                                  'Unnamed'),
                                              subtitle: Text(af['note'] ??
                                                  af['description'] ??
                                                  ''),
                                              trailing: IconButton(
                                                icon: const Icon(Icons.delete,
                                                    color: Colors.redAccent),
                                                onPressed: () async {
                                                  final featureId =
                                                      af['feature_id'] ??
                                                          af['id'];
                                                  final tenantId =
                                                      _selectedTenantForCustom;
                                                  if (featureId == null ||
                                                      tenantId == null) return;
                                                  final confirm =
                                                      await showDialog<bool>(
                                                          context: context,
                                                          builder:
                                                              (c) =>
                                                                  AlertDialog(
                                                                    title: const Text(
                                                                        'Confirm delete'),
                                                                    content:
                                                                        const Text(
                                                                            'Are you sure you wish to delete?'),
                                                                    actions: [
                                                                      TextButton(
                                                                          onPressed: () => Navigator.of(c).pop(
                                                                              false),
                                                                          child:
                                                                              const Text('Cancel')),
                                                                      ElevatedButton(
                                                                          style: ElevatedButton.styleFrom(
                                                                              backgroundColor: Colors
                                                                                  .redAccent),
                                                                          onPressed: () => Navigator.of(c).pop(
                                                                              true),
                                                                          child:
                                                                              const Text('Delete'))
                                                                    ],
                                                                  ));
                                                  if (confirm != true) return;
                                                  try {
                                                    await _service
                                                        .removeFromTenant(
                                                            tenantId,
                                                            '$featureId');
                                                    if (!mounted) return;
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                            const SnackBar(
                                                                content: Text(
                                                                    'Removed')));
                                                  } catch (e) {
                                                    if (!mounted) return;
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                            content: Text(
                                                                'Remove failed: ${e.toString()}')));
                                                  }
                                                  await _loadAppliedForTenant(
                                                      tenantId);
                                                },
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                          )
                        ],
                      ),
                    )
                  ]),
                )
              ],
            ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
