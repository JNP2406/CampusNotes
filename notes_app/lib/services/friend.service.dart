import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/friend.model.dart';

class FriendService {
  final String _base = ApiConfig.authBaseUrl;

  Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  // Get list teman
  Future<List<FriendModel>> getFriends(String token) async {
    final response = await http.get(
      Uri.parse('$_base/friends'),
      headers: _headers(token),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => FriendModel.fromJson(e)).toList();
    }
    throw Exception('Failed to get friends');
  }

  // Get incoming friend requests
  Future<List<FriendRequestModel>> getIncomingRequests(String token) async {
    final response = await http.get(
      Uri.parse('$_base/friends/requests'),
      headers: _headers(token),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => FriendRequestModel.fromJson(e)).toList();
    }
    throw Exception('Failed to get requests');
  }

  // Kirim friend request
  Future<void> sendFriendRequest(String token, int receiverId) async {
    final response = await http.post(
      Uri.parse('$_base/friends/request'),
      headers: _headers(token),
      body: jsonEncode({'receiverId': receiverId}),
    );
    if (response.statusCode != 201) {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Failed to send request');
    }
  }

  // Accept friend request
  Future<void> acceptRequest(String token, int requestId) async {
    final response = await http.patch(
      Uri.parse('$_base/friends/request/$requestId/accept'),
      headers: _headers(token),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to accept request');
    }
  }

  // Reject friend request
  Future<void> rejectRequest(String token, int requestId) async {
    final response = await http.delete(
      Uri.parse('$_base/friends/request/$requestId/reject'),
      headers: _headers(token),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to reject request');
    }
  }

  // Search user
  Future<List<UserFriendModel>> searchUsers(String token, String query) async {
    final response = await http.get(
      Uri.parse('$_base/friends/search?query=$query'),
      headers: _headers(token),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => UserFriendModel.fromJson(e)).toList();
    }
    throw Exception('Failed to search users');
  }

  // Get rekomendasi teman
  Future<List<UserFriendModel>> getRecommendations(String token) async {
    final response = await http.get(
      Uri.parse('$_base/friends/recommendations'),
      headers: _headers(token),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => UserFriendModel.fromJson(e)).toList();
    }
    throw Exception('Failed to get recommendations');
  }

  // Cek status pertemanan
  Future<FriendshipStatusModel> getFriendshipStatus(String token, int targetUserId) async {
    final response = await http.get(
      Uri.parse('$_base/friends/status/$targetUserId'),
      headers: _headers(token),
    );
    if (response.statusCode == 200) {
      return FriendshipStatusModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to get friendship status');
  }

  // Unfriend
  Future<void> unfriend(String token, int friendId) async {
    final response = await http.delete(
      Uri.parse('$_base/friends/$friendId'),
      headers: _headers(token),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to unfriend');
    }
  }
}