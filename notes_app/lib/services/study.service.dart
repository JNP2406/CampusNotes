import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:notes_app/config/api_config.dart';
import 'package:notes_app/models/course.model.dart';
import 'package:notes_app/models/file.model.dart';
import 'package:notes_app/models/semester.model.dart';
import 'package:notes_app/services/auth.service.dart';

class StudyService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // =========================
  // SEMESTERS
  // =========================

  Future<List<SemesterModel>> getSemesters() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.studyBaseUrl}/semesters'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => SemesterModel.fromJson(e)).toList();
    }
    throw Exception('Failed to get semesters');
  }

  Future<SemesterModel> createSemester(String name, {String? coverUrl}) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.studyBaseUrl}/semesters'),
      headers: await _getHeaders(),
      body: jsonEncode({'name': name, 'coverUrl': coverUrl}),
    );
    if (response.statusCode == 201) {
      return SemesterModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create semester');
  }

  Future<SemesterModel> updateSemester(int id, {String? name, String? coverUrl}) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.studyBaseUrl}/semesters/$id'),
      headers: await _getHeaders(),
      body: jsonEncode({
        if (name != null) 'name': name,
        if (coverUrl != null) 'coverUrl': coverUrl,
      }),
    );
    if (response.statusCode == 200) {
      return SemesterModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to update semester');
  }

  Future<void> deleteSemester(int id) async {
    await http.delete(
      Uri.parse('${ApiConfig.studyBaseUrl}/semesters/$id'),
      headers: await _getHeaders(),
    );
  }

  // =========================
  // COURSES
  // =========================

  Future<List<CourseModel>> getCourses(int semesterId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.studyBaseUrl}/courses?semesterId=$semesterId'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => CourseModel.fromJson(e)).toList();
    }
    throw Exception('Failed to get courses');
  }

  Future<CourseModel> createCourse(String name, int semesterId, {String? coverUrl}) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.studyBaseUrl}/courses'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'name': name,
        'semesterId': semesterId,
        'coverUrl': coverUrl,
      }),
    );
    if (response.statusCode == 201) {
      return CourseModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create course');
  }

  Future<CourseModel> updateCourse(int id, {String? name, String? coverUrl}) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.studyBaseUrl}/courses/$id'),
      headers: await _getHeaders(),
      body: jsonEncode({
        if (name != null) 'name': name,
        if (coverUrl != null) 'coverUrl': coverUrl,
      }),
    );
    if (response.statusCode == 200) {
      return CourseModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to update course');
  }

  Future<void> deleteCourse(int id) async {
    await http.delete(
      Uri.parse('${ApiConfig.studyBaseUrl}/courses/$id'),
      headers: await _getHeaders(),
    );
  }

  // =========================
  // FILES
  // =========================

  Future<List<FileModel>> getFiles(int courseId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.studyBaseUrl}/files?courseId=$courseId'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => FileModel.fromJson(e)).toList();
    }
    throw Exception('Failed to get files');
  }

  Future<FileModel> createFile({
    required String title,
    required int courseId,
    required String fileUrl,
    String? fileType,
    bool isShared = false,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.studyBaseUrl}/files'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'title': title,
        'courseId': courseId,
        'fileUrl': fileUrl,
        'fileType': fileType,
        'isShared': isShared,
      }),
    );
    if (response.statusCode == 201) {
      return FileModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create file');
  }

  Future<void> deleteFile(int id) async {
    await http.delete(
      Uri.parse('${ApiConfig.studyBaseUrl}/files/$id'),
      headers: await _getHeaders(),
    );
  }

  // =========================
  // UPLOAD FILE
  // =========================

  Future<String> uploadFile(File file) async {
    try {
      final token = await _authService.getToken();

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.uploadBaseUrl}/upload'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      request.files.add(
        await http.MultipartFile.fromPath('file', file.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Upload status: ${response.statusCode}');
      print('Upload body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (data['url'] != null) {
          return '${ApiConfig.staticBaseUrl}${data['url']}';
        }

        if (data['fileUrl'] != null) {
          return data['fileUrl'];
        }

        throw Exception('No file URL returned from server');
      }

      throw Exception('Upload failed: ${response.statusCode}');
    } catch (e) {
      print('Upload error: $e');
      throw Exception('Failed to upload file');
    }
  }
}