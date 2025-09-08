import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../utils/phone_formatter.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  const ProfileScreen({required this.userId, super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool loading = true;
  Map<String, dynamic>? user;
  List<Map<String, dynamic>> _audit = [];
  bool _auditOpen = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _firstController;
  late TextEditingController _lastController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _dobController;
  String? _lastLogin;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _firstController = TextEditingController();
    _lastController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _dobController = TextEditingController();
    _load();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _firstController.dispose();
    _lastController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final auth = Provider.of<AuthService>(context, listen: false);
    final svc = UserService(auth);
    final u = await svc.fetchUser(widget.userId);
    if (u != null) {
      user = u;
      _usernameController.text = u['username'] ?? '';
      _emailController.text = u['email'] ?? '';
      _firstController.text = u['first_name'] ?? '';
      _lastController.text = u['last_name'] ?? '';
      _phoneController.text = u['phone'] ?? '';
      _addressController.text = u['address'] ?? '';
      // server stores DOB as YYYY-MM-DD; display as MM/DD/YYYY
      final rawDob = u['dob'];
      if (rawDob != null && rawDob is String && rawDob.isNotEmpty) {
        try {
          final dt = DateTime.parse(rawDob);
          _dobController.text =
              '${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}/${dt.year}';
        } catch (e) {
          _dobController.text = rawDob;
        }
      } else {
        _dobController.text = '';
      }
      _lastLogin = u['last_login'];
    }
    final audits = await svc.fetchAudit(widget.userId, limit: 50);
    _audit = audits;
    if (mounted) setState(() => loading = false);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = Provider.of<AuthService>(context, listen: false);
    final svc = UserService(auth);
    // strip non-digit characters from phone before sending
    final phoneDigits = _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    // convert displayed MM/DD/YYYY to YYYY-MM-DD for server
    String dobForServer = '';
    if (_dobController.text.trim().isNotEmpty) {
      try {
        final parts = _dobController.text.split('/');
        final m = int.parse(parts[0]);
        final d = int.parse(parts[1]);
        final y = int.parse(parts[2]);
        final dt = DateTime(y, m, d);
        dobForServer =
            '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      } catch (_) {
        dobForServer = _dobController.text.trim();
      }
    }

    final ok = await svc.updateUser(widget.userId, {
      'username': _usernameController.text.trim(),
      'email': _emailController.text.trim(),
      'first_name': _firstController.text.trim(),
      'last_name': _lastController.text.trim(),
      'phone': phoneDigits,
      'address': _addressController.text.trim(),
      'dob': dobForServer,
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? 'Saved' : 'Failed to save'),
        duration: const Duration(seconds: 2)));
    if (ok) Navigator.of(context).pop();
  }

  Future<void> _pickDate() async {
    // Try to parse existing DOB (MM/DD/YYYY or YYYY-MM-DD) or default to 25 years ago
    DateTime initial;
    try {
      if (_dobController.text.contains('/')) {
        final parts = _dobController.text.split('/');
        final m = int.parse(parts[0]);
        final d = int.parse(parts[1]);
        final y = int.parse(parts[2]);
        initial = DateTime(y, m, d);
      } else if (_dobController.text.contains('-')) {
        initial = DateTime.parse(_dobController.text);
      } else {
        initial = DateTime.now().subtract(const Duration(days: 365 * 25));
      }
    } catch (_) {
      initial = DateTime.now().subtract(const Duration(days: 365 * 25));
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final formatted =
          '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
      if (mounted) setState(() => _dobController.text = formatted);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(labelText: 'Username'),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(labelText: 'Email'),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _firstController,
                              decoration:
                                  InputDecoration(labelText: 'First name'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _lastController,
                              decoration:
                                  InputDecoration(labelText: 'Last name'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(labelText: 'Phone'),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return null;
                          final digits = v.replaceAll(RegExp(r'[^0-9]'), '');
                          return digits.length == 10
                              ? null
                              : 'Enter a 10-digit phone number';
                        },
                        keyboardType: TextInputType.phone,
                        inputFormatters: [PhoneInputFormatter()],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(labelText: 'Address'),
                        keyboardType: TextInputType.multiline,
                        minLines: 3,
                        maxLines: 6,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _dobController,
                        decoration: InputDecoration(
                          labelText: 'Date of birth (MM/DD/YYYY)',
                          suffixIcon: SizedBox(
                            width: 96,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.calendar_today),
                                  onPressed: _pickDate,
                                  tooltip: 'Pick a date',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    if (mounted)
                                      setState(() => _dobController.text = '');
                                  },
                                  tooltip: 'Clear date',
                                ),
                              ],
                            ),
                          ),
                        ),
                        readOnly: true,
                        onTap: _pickDate,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return null; // optional
                          // (this space intentionally left blank)
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      if (_lastLogin != null) ...[
                        Text('Last login: ${_lastLogin!}',
                            style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 12),
                      ],
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel')),
                          const SizedBox(width: 12),
                          ElevatedButton(
                              onPressed: _save, child: const Text('Save')),
                        ],
                      ),
                      // Audit panel
                      if (_audit.isNotEmpty) ...[
                        const Divider(),
                        ListTile(
                          title: const Text('Change history'),
                          trailing: IconButton(
                            icon: Icon(_auditOpen
                                ? Icons.expand_less
                                : Icons.expand_more),
                            onPressed: () =>
                                setState(() => _auditOpen = !_auditOpen),
                          ),
                        ),
                        if (_auditOpen)
                          Container(
                            height: 200,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 0.0),
                            child: ListView.builder(
                              itemCount: _audit.length,
                              itemBuilder: (context, idx) {
                                final a = _audit[idx];
                                final when =
                                    a['created_at'] ?? a['createdAt'] ?? '';
                                final by = a['changed_by'] ??
                                    a['changedBy'] ??
                                    'system';
                                final changes = a['changes'] ?? {}; // map
                                final fields = (changes is Map)
                                    ? (changes.keys.join(', '))
                                    : '';
                                return ListTile(
                                  title: Text('$when — $by'),
                                  subtitle: Text(
                                      fields.isEmpty ? 'modified' : fields),
                                  dense: true,
                                );
                              },
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
