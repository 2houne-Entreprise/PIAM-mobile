class Operation {
  final int id;
  final String name;

  Operation({required this.id, required this.name});

  factory Operation.fromJson(Map<String, dynamic> json) {
    return Operation(id: json['id'], name: json['name']);
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
