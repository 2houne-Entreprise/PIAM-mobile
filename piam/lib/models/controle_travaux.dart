enum StatusControle { completed, inProgress, notCompleted }

class ControleTravaux {
  final int? id;
  final int projectId;
  final String section;
  final StatusControle status;
  final DateTime checkedAt;

  ControleTravaux({
    this.id,
    required this.projectId,
    required this.section,
    required this.status,
    DateTime? checkedAt,
  }) : checkedAt = checkedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id,
    'projectId': projectId,
    'section': section,
    'status': status.index,
    'checkedAt': checkedAt.toIso8601String(),
  };

  factory ControleTravaux.fromMap(Map<String, dynamic> map) => ControleTravaux(
    id: map['id'] as int?,
    projectId: map['projectId'] as int,
    section: map['section'] as String,
    status: StatusControle.values[map['status'] as int],
    checkedAt: DateTime.parse(map['checkedAt'] as String),
  );
}
