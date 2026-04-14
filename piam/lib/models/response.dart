class ResponseModel {
  final int id;
  final int formId;
  final String question;
  final String reponse;

  ResponseModel({
    required this.id,
    required this.formId,
    required this.question,
    required this.reponse,
  });

  factory ResponseModel.fromJson(Map<String, dynamic> json) {
    return ResponseModel(
      id: json['id'],
      formId: json['form_id'],
      question: json['question'],
      reponse: json['reponse'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'form_id': formId,
    'question': question,
    'reponse': reponse,
  };
}
