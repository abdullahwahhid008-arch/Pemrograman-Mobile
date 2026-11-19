
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class HealthService {
  static const String _keyApiUrl = 'api_base_url';

  // Mengambil alamat API yang tersimpan
  Future<String> getApiUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyApiUrl) ??
        ApiConfig.defaultBaseUrl;
  }

  // Menyimpan alamat API
  Future<void> saveApiUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyApiUrl, url);
  }

  // Memeriksa koneksi API dan database
  Future<Map<String, dynamic>> checkHealth() async {
    final baseUrl = await getApiUrl();

    try {
      final response = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(ApiConfig.batasWaktu);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'api': true,
          'database': data['database'] == 'connected',
          'status': data['status'],
          'mysql_version': data['mysql_version'],
          'waktu_server': data['waktu_server'],
          'detail': null,
        };
      }

      if (response.statusCode == 503) {
        return {
          'api': true,
          'database': false,
          'status': data['status'],
          'mysql_version': null,
          'waktu_server': data['waktu_server'],
          'detail': data['detail'],
        };
      }

      return {
        'api': true,
        'database': false,
        'status': 'error',
        'mysql_version': null,
        'waktu_server': null,
        'detail': 'HTTP ${response.statusCode}',
      };
    } catch (error) {
      return {
        'api': false,
        'database': false,
        'status': 'error',
        'mysql_version': null,
        'waktu_server': null,
        'detail': error.toString(),
      };
    }
  }
}
