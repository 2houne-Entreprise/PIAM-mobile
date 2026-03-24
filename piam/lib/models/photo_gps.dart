class PhotoGPS {
  final int? id;
  final int projectId;
  final String path;
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime takenAt;

  PhotoGPS({
    this.id,
    required this.projectId,
    required this.path,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    DateTime? takenAt,
  }) : takenAt = takenAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id,
    'projectId': projectId,
    'path': path,
    'latitude': latitude,
    'longitude': longitude,
    'accuracy': accuracy,
    'takenAt': takenAt.toIso8601String(),
  };

  factory PhotoGPS.fromMap(Map<String, dynamic> map) => PhotoGPS(
    id: map['id'] as int?,
    projectId: map['projectId'] as int,
    path: map['path'] as String,
    latitude: map['latitude'] as double,
    longitude: map['longitude'] as double,
    accuracy: map['accuracy'] as double,
    takenAt: DateTime.parse(map['takenAt'] as String),
  );
}
