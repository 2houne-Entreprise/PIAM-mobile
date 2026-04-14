import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class AuthService {
  final String baseUrl;
  String? _token;

  AuthService({required this.baseUrl});

  Future<User?> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      body: {'username': username, 'password': password},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _token = data['token'];
      return User.fromJson(data['user']);
    }
    return null;
  }

  String? get token => _token;
}
