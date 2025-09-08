class Tenant {
  final String id;
  final String name;

  Tenant({required this.id, required this.name});

  factory Tenant.fromJson(Map<String, dynamic> j) => Tenant(
        id: j['id']?.toString() ?? '',
        name: j['name'] ?? j['displayName'] ?? 'Tenant',
      );
}
