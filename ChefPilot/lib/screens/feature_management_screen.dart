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
  String? _selectedTenantId;
  String? _selectedFeatureId;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthService>(context, listen: false);
    _service = widget.service ?? FeatureService(auth: auth);
    _tabController = TabController(length: 2, vsync: this);
    _load();
    _loadTenants();
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

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await _service.list();
      setState(() => _features = list);
    } catch (e) {
      // ignore for now
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
      appBar: AppBar(title: const Text('Feature Management')),
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
                      child: ListView.builder(
                        itemCount: _features.length + 1,
                        itemBuilder: (ctx, idx) {
                          if (idx == 0) {
                            return ListTile(
                              title: const Text('Features'),
                              trailing: ElevatedButton.icon(
                                onPressed: () => _showEditDialog(),
                                icon: const Icon(Icons.add),
                                label: const Text('Add'),
                              ),
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
                    // Custom Feature tab
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  initialValue: _selectedTenantId,
                                  hint: const Text('Select tenant'),
                                  items: _tenants
                                      .map((t) => DropdownMenuItem(
                                          value: t['id'],
                                          child: Text(t['name']!)))
                                      .toList(),
                                  onChanged: (v) =>
                                      setState(() => _selectedTenantId = v),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  initialValue: _selectedFeatureId,
                                  hint: const Text('Select feature'),
                                  items: _features
                                      .map((f) => DropdownMenuItem(
                                          value: f.id, child: Text(f.name)))
                                      .toList(),
                                  onChanged: (v) =>
                                      setState(() => _selectedFeatureId = v),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  // open a dialog to create a custom apply
                                  String? tenant = _selectedTenantId;
                                  String? featureId = _selectedFeatureId;
                                  bool custom = true;
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
                                                  DropdownButtonFormField<
                                                      String>(
                                                    initialValue: featureId,
                                                    hint: const Text(
                                                        'Select feature'),
                                                    items: _features
                                                        .map((f) =>
                                                            DropdownMenuItem(
                                                                value: f.id,
                                                                child: Text(
                                                                    f.name)))
                                                        .toList(),
                                                    onChanged: (v) => setSt(
                                                        () => featureId = v),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  CheckboxListTile(
                                                    value: custom,
                                                    title: const Text(
                                                        'Apply as custom (not visible to all)'),
                                                    onChanged: (v) => setSt(
                                                        () =>
                                                            custom = v ?? true),
                                                    controlAffinity:
                                                        ListTileControlAffinity
                                                            .leading,
                                                  )
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
                                                  onPressed: (tenant != null &&
                                                          featureId != null)
                                                      ? () async {
                                                          final messenger =
                                                              ScaffoldMessenger
                                                                  .of(context);
                                                          final dialogNavigator =
                                                              Navigator.of(ctx);
                                                          try {
                                                            // For now the backend API doesn't accept a "custom" flag, so we reuse the same apply endpoint.
                                                            await _service
                                                                .applyToTenant(
                                                                    tenant!,
                                                                    featureId!);
                                                            messenger.showSnackBar(
                                                                const SnackBar(
                                                                    content: Text(
                                                                        'Custom feature applied')));
                                                            dialogNavigator
                                                                .pop(true);
                                                          } catch (e) {
                                                            messenger.showSnackBar(
                                                                const SnackBar(
                                                                    content: Text(
                                                                        'Failed to apply')));
                                                          }
                                                        }
                                                      : null,
                                                  child: const Text('Apply'))
                                            ],
                                          );
                                        });
                                      });
                                  if (res == true) await _load();
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Add Custom'),
                              )
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: (_selectedTenantId != null &&
                                        _selectedFeatureId != null)
                                    ? () async {
                                        final messenger =
                                            ScaffoldMessenger.of(context);
                                        try {
                                          await _service.applyToTenant(
                                              _selectedTenantId!,
                                              _selectedFeatureId!);
                                          messenger.showSnackBar(const SnackBar(
                                              content:
                                                  Text('Feature applied')));
                                        } catch (e) {
                                          messenger.showSnackBar(const SnackBar(
                                              content:
                                                  Text('Failed to apply')));
                                        }
                                      }
                                    : null,
                                child: const Text('Apply'),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: (_selectedTenantId != null &&
                                        _selectedFeatureId != null)
                                    ? () async {
                                        final messenger =
                                            ScaffoldMessenger.of(context);
                                        try {
                                          await _service.removeFromTenant(
                                              _selectedTenantId!,
                                              _selectedFeatureId!);
                                          messenger.showSnackBar(const SnackBar(
                                              content:
                                                  Text('Feature removed')));
                                        } catch (e) {
                                          messenger.showSnackBar(const SnackBar(
                                              content:
                                                  Text('Failed to remove')));
                                        }
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent),
                                child: const Text('Remove'),
                              ),
                            ],
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
}
