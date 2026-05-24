import 'package:flutter/material.dart';
import 'package:notes_app/models/friend.model.dart';
import 'package:notes_app/services/auth.service.dart';
import 'package:notes_app/services/friend.service.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final FriendService _friendService = FriendService();
  final AuthService _authService = AuthService();

  List<FriendModel> _friends = [];
  List<FriendRequestModel> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final token = await _authService.getToken();
      if (token == null) return;

      final friends = await _friendService.getFriends(token);
      final requests = await _friendService.getIncomingRequests(token);

      if (!mounted) return;
      setState(() {
        _friends = friends;
        _requests = requests;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _acceptRequest(int requestId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return;
      await _friendService.acceptRequest(token, requestId);
      await _loadData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to accept request: $e')),
      );
    }
  }

  Future<void> _rejectRequest(int requestId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return;
      await _friendService.rejectRequest(token, requestId);
      await _loadData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reject request: $e')),
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
        username[0].toUpperCase(),
        style: const TextStyle(
          color: Colors.black54,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Friends Notes',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Friends List
                    const Text(
                      'Friends Notes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (_friends.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            'No friends added yet',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _friends.length,
                        itemBuilder: (context, index) {
                          final friend = _friends[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: _buildAvatar(
                              friend.friend.avatarUrl,
                              friend.friend.username,
                            ),
                            title: Text(
                              friend.friend.username,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/friend-notes',
                                arguments: friend.friend,
                              );
                            },
                          );
                        },
                      ),

                    const Divider(height: 32),

                    // Friend Requests
                    const Text(
                      'Friend Request',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (_requests.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            'No friend request yet',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _requests.length,
                        itemBuilder: (context, index) {
                          final request = _requests[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: _buildAvatar(
                              request.sender?.avatarUrl,
                              request.sender?.username ?? '?',
                            ),
                            title: Text(
                              request.sender?.username ?? 'Unknown',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.green,
                                  ),
                                  onPressed: () => _acceptRequest(request.id),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.cancel_outlined,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _rejectRequest(request.id),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/search-friend');
          await _loadData();
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white60,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.article_outlined, size: 32),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: _requests.isNotEmpty,
              backgroundColor: Colors.red,
              child: const Icon(Icons.people_outline, size: 32),
            ),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, size: 32),
            label: '',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          }
          if (index == 2) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
      ),
    );
  }
}