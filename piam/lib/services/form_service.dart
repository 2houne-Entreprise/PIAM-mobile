import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/form.dart';

class FormService {
  final String baseUrl;
  final String token;

  FormService({required this.baseUrl, required this.token});

  Future<List<FormModel>> getForms() async {
    final response = await http.get(
      Uri.parse('$baseUrl/forms'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => FormModel.fromJson(e)).toList();
    }
    throw Exception('Failed to load forms');
  }

  Future<FormModel> createForm(Map<String, dynamic> formData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/forms'),
      headers: {'Authorization': 'Bearer $token'},
      body: formData,
    );
    if (response.statusCode == 201) {
      return FormModel.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to create form');
  }

  Future<FormModel> updateForm(int id, Map<String, dynamic> formData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/forms/$id'),
      headers: {'Authorization': 'Bearer $token'},
      body: formData,
    );
    if (response.statusCode == 200) {
      return FormModel.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to update form');
  }

  // Charger un formulaire par ID
  Future<FormModel> getForm(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/forms/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return FormModel.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to load form');
  }
}
