import 'dart:convert';
import 'package:http/http.dart' as http;

class DashboardService {
  final String baseUrl;
  final String token;

  DashboardService({required this.baseUrl, required this.token});

  Future<Map<String, int>> getStats() async {
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard-stats'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      Map<String, int> stats = {};
      for (var item in data) {
        stats[item['status']] = item['count'];
      }
      return stats;
    }
    throw Exception('Failed to load dashboard stats');
  }
}
