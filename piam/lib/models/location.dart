class Location {
  final int id;
  final String wilaya;
  final String moughataa;
  final String commune;
  final String localite;
  final double latitude;
  final double longitude;

  Location({
    required this.id,
    required this.wilaya,
    required this.moughataa,
    required this.commune,
    required this.localite,
    required this.latitude,
    required this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      wilaya: json['wilaya'],
      moughataa: json['moughataa'],
      commune: json['commune'],
      localite: json['localite'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'wilaya': wilaya,
    'moughataa': moughataa,
    'commune': commune,
    'localite': localite,
    'latitude': latitude,
    'longitude': longitude,
  };
}
