class Feature {
  String id;
  String name;
  String description;
  bool enabled;

  Feature(
      {required this.id,
      required this.name,
      this.description = '',
      this.enabled = false});

  factory Feature.fromJson(Map<String, dynamic> json) => Feature(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] ?? '',
        enabled: (json['enabled'] ?? 0) == 1 || json['enabled'] == true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'enabled': enabled ? 1 : 0,
      };
}
