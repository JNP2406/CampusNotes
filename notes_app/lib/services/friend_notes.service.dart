import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/semester.model.dart';
import '../models/course.model.dart';
import '../models/file.model.dart';

class FriendNotesService {
  final String _base = ApiConfig.studyBaseUrl;

  Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  // Lihat semester milik teman
  Future<List<SemesterModel>> getFriendSemesters(String token, int friendId) async {
    final response = await http.get(
      Uri.parse('$_base/semesters/friend/$friendId'),
      headers: _headers(token),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => SemesterModel.fromJson(e)).toList();
    }
    throw Exception('Failed to get friend semesters');
  }

  // Lihat courses milik teman
  Future<List<CourseModel>> getFriendCourses(String token, int friendId, int semesterId) async {
    final response = await http.get(
      Uri.parse('$_base/courses/friend/$friendId?semesterId=$semesterId'),
      headers: _headers(token),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => CourseModel.fromJson(e)).toList();
    }
    throw Exception('Failed to get friend courses');
  }

  // Lihat files milik teman
  Future<List<FileModel>> getFriendFiles(String token, int friendId, int courseId) async {
    final response = await http.get(
      Uri.parse('$_base/files/friend/$friendId?courseId=$courseId'),
      headers: _headers(token),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => FileModel.fromJson(e)).toList();
    }
    throw Exception('Failed to get friend files');
  }
}