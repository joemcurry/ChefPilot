import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/tenant.dart';
import 'package:http/http.dart' as http;

class AppOwnerDashboard extends StatefulWidget {
  const AppOwnerDashboard({super.key});

  @override
  State<AppOwnerDashboard> createState() => _AppOwnerDashboardState();
}

class _AppOwnerDashboardState extends State<AppOwnerDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Tenant> tenants = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadTenants();
  }

  Future<void> _loadTenants() async {
    setState(() {
      loading = true;
      error = null;
    });
    final auth = Provider.of<AuthService>(context, listen: false);
    final url = Uri.parse('${auth.baseUrl}/api/tenants');
    try {
      final resp = await http.get(url, headers: auth.headers());
      if (resp.statusCode == 200) {
        final list = jsonDecode(resp.body) as List<dynamic>;
        tenants = list
            .map((e) => Tenant.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        error = 'Server returned ${resp.statusCode}';
      }
    } catch (e) {
      if (kDebugMode) {
        // Provide mock tenants in development if API not reachable
        tenants = [
          Tenant(id: 't-1', name: 'Mock Tenant One'),
          Tenant(id: 't-2', name: 'Mock Tenant Two'),
        ];
      } else {
        error = e.toString();
      }
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final displayName = auth.token != null ? 'App Owner' : 'Guest';
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('AppOwner Dashboard'),
        actions: [
          // Settings icon that opens an end drawer
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
          // Username with profile/logout popup
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: PopupMenuButton<String>(
              tooltip: 'User menu',
              child: Row(
                children: [
                  const Icon(Icons.person),
                  const SizedBox(width: 6),
                  Text(displayName),
                  const SizedBox(width: 6),
                ],
              ),
              onSelected: (v) async {
                if (v == 'profile') {
                  final auth = Provider.of<AuthService>(context, listen: false);
                  final uid = auth.currentUserId ?? 'owner-1';
                  if (!mounted) return;
                  Navigator.of(context).pushNamed('/profile/$uid');
                } else if (v == 'logout') {
                  // Capture navigator before awaiting the dialog to avoid using context after an async gap
                  final nav = Navigator.of(context);
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: const Text('Confirm Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.of(c).pop(false),
                            child: const Text('Cancel')),
                        TextButton(
                            onPressed: () => Navigator.of(c).pop(true),
                            child: const Text('Logout')),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    auth.logout();
                    if (!mounted) {
                      return;
                    }
                    nav.pushReplacementNamed('/');
                  }
                }
              },
              itemBuilder: (ctx) => const [
                PopupMenuItem(value: 'profile', child: Text('Profile')),
                PopupMenuItem(value: 'logout', child: Text('Logout')),
              ],
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Settings',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ListTile(
                leading: const Icon(Icons.receipt_long),
                title: const Text('Billing'),
                subtitle: const Text('Manage pricing and schedules'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed('/settings');
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_backup_restore),
                title: const Text('Feature Management'),
                subtitle: const Text('Manage feature flags and rollout plans'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed('/feature-management');
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About'),
                onTap: () => showAboutDialog(
                    context: context, applicationName: 'ChefPilot'),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? Center(child: Text('Error: $error'))
                : ListView.builder(
                    itemCount: tenants.length,
                    itemBuilder: (context, i) {
                      final t = tenants[i];
                      return Card(
                        child: ListTile(
                          title: Text(t.name),
                          subtitle: Text('ID: ${t.id}'),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadTenants,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
