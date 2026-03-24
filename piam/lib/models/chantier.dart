class Chantier {
  final int? id;
  final int projectId;
  final String description;
  final DateTime updatedAt;

  Chantier({
    this.id,
    required this.projectId,
    required this.description,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id,
    'projectId': projectId,
    'description': description,
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Chantier.fromMap(Map<String, dynamic> map) => Chantier(
    id: map['id'] as int?,
    projectId: map['projectId'] as int,
    description: map['description'] as String,
    updatedAt: DateTime.parse(map['updatedAt'] as String),
  );
}
