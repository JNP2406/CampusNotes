import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/user.model.dart';

class AuthService {
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    String? binusian,
    String? major,
    String? regionCampus,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.authBaseUrl}/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'binusian': binusian,
        'major': major,
        'regionCampus': regionCampus,
      }),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      await _saveToken(data['access_token']);
      return data;
    }
    throw Exception(data['message'] ?? 'Register failed');
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.authBaseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      await _saveToken(data['access_token']);
      return data;
    }
    throw Exception(data['message'] ?? 'Login failed');
  }

  Future<UserModel> getMe(String token) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.authBaseUrl}/users/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to get user');
  }

  Future<UserModel> updateProfile(String token, {
    String? username,
    String? binusian,
    String? major,
    String? regionCampus,
    String? avatarUrl,
    String? coverUrl,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.authBaseUrl}/users/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        if (username != null) 'username': username,
        if (binusian != null) 'binusian': binusian,
        if (major != null) 'major': major,
        if (regionCampus != null) 'regionCampus': regionCampus,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        if (coverUrl != null) 'coverUrl': coverUrl,
      }),
    );
    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to update profile');
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}