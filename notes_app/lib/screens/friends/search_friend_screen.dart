import 'package:flutter/material.dart';
import 'package:notes_app/models/friend.model.dart';
import 'package:notes_app/services/auth.service.dart';
import 'package:notes_app/services/friend.service.dart';

class SearchFriendScreen extends StatefulWidget {
  const SearchFriendScreen({super.key});

  @override
  State<SearchFriendScreen> createState() => _SearchFriendScreenState();
}

class _SearchFriendScreenState extends State<SearchFriendScreen> {
  final FriendService _friendService = FriendService();
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();

  List<UserFriendModel> _recommendations = [];
  List<UserFriendModel> _searchResults = [];
  bool _isLoadingRecommendations = true;
  bool _isSearching = false;
  bool _hasSearched = false;
  final Set<int> _pendingUserIds = {};

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecommendations() async {
    try {
      final token = await _authService.getToken();
      if (token == null) return;
      final recommendations = await _friendService.getRecommendations(token);
      if (!mounted) return;
      setState(() {
        _recommendations = recommendations;
        _isLoadingRecommendations = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingRecommendations = false);
    }
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final token = await _authService.getToken();
      if (token == null) return;
      final results = await _friendService.searchUsers(token, query);
      if (!mounted) return;
      setState(() {
        _searchResults = results;
        _hasSearched = true;
        _isSearching = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSearching = false);
    }
  }

  Future<void> _sendRequest(int receiverId) async {
    setState(() => _pendingUserIds.add(receiverId));
    try {
      final token = await _authService.getToken();
      if (token == null) return;
      await _friendService.sendFriendRequest(token, receiverId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Friend request sent!')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _pendingUserIds.remove(receiverId));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  Widget _buildAvatar(String? avatarUrl, String username) {
    if (avatarUrl != null) {
      return CircleAvatar(
        backgroundImage: NetworkImage(avatarUrl),
        radius: 20,
      );
    }
    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.grey.shade300,
      child: Text(
        username.isNotEmpty ? username[0].toUpperCase() : '?',
        style: const TextStyle(
          color: Colors.black54,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildUserTile(UserFriendModel user) {
    final isPending = _pendingUserIds.contains(user.id);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: _buildAvatar(user.avatarUrl, user.username),
      title: Text(
        user.username,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: user.major != null ? Text(user.major!) : null,
      trailing: isPending
          ? const Icon(Icons.check_circle, color: Colors.green)
          : IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => _sendRequest(user.id),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Search Friend',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Type name of friend',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: _search,
              onChanged: (value) {
                if (value.isEmpty) {
                  setState(() {
                    _searchResults = [];
                    _hasSearched = false;
                  });
                }
              },
            ),
            const SizedBox(height: 24),

            // Search Results atau Recommendations
            if (_isSearching)
              const Center(child: CircularProgressIndicator())
            else if (_hasSearched) ...[
              const Text(
                'Result',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (_searchResults.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No users found',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) =>
                      _buildUserTile(_searchResults[index]),
                ),
            ] else ...[
              const Text(
                'Recommendation',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (_isLoadingRecommendations)
                const Center(child: CircularProgressIndicator())
              else if (_recommendations.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No recommendations',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _recommendations.length,
                  itemBuilder: (context, index) =>
                      _buildUserTile(_recommendations[index]),
                ),
            ],
          ],
        ),
      ),
    );
  }
}