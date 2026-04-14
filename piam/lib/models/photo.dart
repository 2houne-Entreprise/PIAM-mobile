class Photo {
  final int id;
  final int formId;
  final String imageUrl;

  Photo({required this.id, required this.formId, required this.imageUrl});

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'],
      formId: json['form_id'],
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'form_id': formId,
    'image_url': imageUrl,
  };
}
