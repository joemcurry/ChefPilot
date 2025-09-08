import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  List<Map<String, String>> _users = [];
  String? _selectedUser;
  bool _usersLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _usersLoading = true;
    });
    try {
      final uri = Uri.parse('http://127.0.0.1:3000/api/users');
      print('[LoginScreen] fetching users from: $uri');
      final resp = await http.get(uri).timeout(const Duration(seconds: 5));
      print('[LoginScreen] users response status: ${resp.statusCode}');
      print('[LoginScreen] users response body: ${resp.body}');
      if (resp.statusCode == 200) {
        final list = jsonDecode(resp.body) as List<dynamic>;
        _users = list.map((e) {
          final id = e['id']?.toString() ?? '';
          final username = e['username']?.toString() ?? '';
          String password = 'ownerpass';
          if (username == 'admin') password = 'password123';
          if (username == 'testuser') password = 'testpass';
          return {'id': id, 'username': username, 'password': password};
        }).toList();
      } else {
        // non-200: use local fallback but avoid alarming the user
        print(
            '[LoginScreen] users fetch returned ${resp.statusCode}, using fallback');
        _users = [
          {'id': 'owner-1', 'username': 'admin', 'password': 'password123'},
          {'id': 'test-1', 'username': 'testuser', 'password': 'testpass'},
          {'id': 'owner-2', 'username': 'owner', 'password': 'ownerpass'},
        ];
      }
    } catch (err) {
      // Log error and use fallback users. Don't present a blocking error to the user.
      print('[LoginScreen] users fetch error: $err');
      _users = [
        {'id': 'owner-1', 'username': 'admin', 'password': 'password123'},
        {'id': 'test-1', 'username': 'testuser', 'password': 'testpass'},
        {'id': 'owner-2', 'username': 'owner', 'password': 'ownerpass'},
      ];
      _error = null;
    } finally {
      setState(() {
        _usersLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final auth = Provider.of<AuthService>(context, listen: false);
    final ok = await auth.login(_userCtrl.text.trim(), _passCtrl.text.trim());
    // If a user was selected from the dropdown, set the currentUserId for the session
    try {
      final found = _users.firstWhere(
          (x) => x['username'] == _userCtrl.text.trim(),
          orElse: () => {});
      if (found.isNotEmpty) {
        auth.setCurrentUserId(found['id'] ?? '');
      }
    } catch (_) {}
    setState(() => _loading = false);
    if (ok) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/appowner');
    } else {
      setState(() => _error = 'Login failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ChefPilot — Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedUser,
              items: _users
                  .map((u) => DropdownMenuItem(
                      value: u['username'], child: Text(u['username'] ?? '')))
                  .toList(),
              decoration: InputDecoration(labelText: 'Select user'),
              onChanged: (v) {
                try {
                  setState(() {
                    _selectedUser = v;
                    if (_users.isNotEmpty && v != null) {
                      final found = _users.firstWhere((x) => x['username'] == v,
                          orElse: () => {'username': '', 'password': ''});
                      _userCtrl.text = found['username'] ?? '';
                      _passCtrl.text = found['password'] ?? '';
                    }
                  });
                } catch (e) {
                  // guard against unexpected runtime errors while selecting
                  print('[LoginScreen] selection error: $e');
                }
              },
            ),
            if (_usersLoading)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: LinearProgressIndicator(),
              ),
            const SizedBox(height: 12),
            // Keep username editable even when selected from dropdown
            TextField(
              controller: _userCtrl,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passCtrl,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Login'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
