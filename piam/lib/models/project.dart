class Project {
  final int? id;
  final String name;
  final String company;
  final String wilaya;
  final DateTime createdAt;

  Project({
    this.id,
    required this.name,
    required this.company,
    required this.wilaya,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'company': company,
    'wilaya': wilaya,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Project.fromMap(Map<String, dynamic> map) => Project(
    id: map['id'] as int?,
    name: map['name'] as String,
    company: map['company'] as String,
    wilaya: map['wilaya'] as String,
    createdAt: DateTime.parse(map['createdAt'] as String),
  );
}
