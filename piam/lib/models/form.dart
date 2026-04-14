enum FormStatus { brouillon, enCours, valide }

class FormModel {
  final int id;
  final int userId;
  final int operationId;
  final int locationId;
  final FormStatus status;
  final DateTime dateCreation;
  final DateTime dateModification;

  FormModel({
    required this.id,
    required this.userId,
    required this.operationId,
    required this.locationId,
    required this.status,
    required this.dateCreation,
    required this.dateModification,
  });

  factory FormModel.fromJson(Map<String, dynamic> json) {
    return FormModel(
      id: json['id'],
      userId: json['user_id'],
      operationId: json['operation_id'],
      locationId: json['location_id'],
      status: _statusFromString(json['status']),
      dateCreation: DateTime.parse(json['date_creation']),
      dateModification: DateTime.parse(json['date_modification']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'operation_id': operationId,
    'location_id': locationId,
    'status': _statusToString(status),
    'date_creation': dateCreation.toIso8601String(),
    'date_modification': dateModification.toIso8601String(),
  };

  static FormStatus _statusFromString(String status) {
    switch (status) {
      case 'brouillon':
        return FormStatus.brouillon;
      case 'en_cours':
        return FormStatus.enCours;
      case 'valide':
        return FormStatus.valide;
      default:
        return FormStatus.brouillon;
    }
  }

  static String _statusToString(FormStatus status) {
    switch (status) {
      case FormStatus.brouillon:
        return 'brouillon';
      case FormStatus.enCours:
        return 'en_cours';
      case FormStatus.valide:
        return 'valide';
    }
  }
}
