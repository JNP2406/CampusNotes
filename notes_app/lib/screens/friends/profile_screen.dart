import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:notes_app/providers/auth.provider.dart';
import 'package:notes_app/services/auth.service.dart';
import 'package:notes_app/services/friend.service.dart';
import 'package:notes_app/services/study.service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final FriendService _friendService = FriendService();
  final StudyService _studyService = StudyService();
  bool _isLoading = false;
  int _pendingRequestCount = 0;

  @override
  void initState() {
    super.initState();
    _loadPendingRequests();
  }

  Future<void> _loadPendingRequests() async {
    try {
      final token = await _authService.getToken();
      if (token == null) return;
      final requests = await _friendService.getIncomingRequests(token);
      if (!mounted) return;
      setState(() => _pendingRequestCount = requests.length);
    } catch (e) {}
  }

  Future<void> _pickAvatar(AuthProvider auth) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() => _isLoading = true);
    try {
      final token = await _authService.getToken();
      if (token == null) return;
      final url = await _studyService.uploadFile(File(picked.path));
      final updated = await _authService.updateProfile(token, avatarUrl: url);
      await auth.updateUser(updated);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload avatar: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickCover(AuthProvider auth) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() => _isLoading = true);
    try {
      final token = await _authService.getToken();
      if (token == null) return;
      final url = await _studyService.uploadFile(File(picked.path));
      final updated = await _authService.updateProfile(token, coverUrl: url);
      await auth.updateUser(updated);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload cover: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _editProfile(BuildContext context, AuthProvider auth) async {
    final user = auth.user;
    if (user == null) return;

    final usernameController = TextEditingController(text: user.username);
    final binusianController = TextEditingController(text: user.binusian ?? '');
    final majorController = TextEditingController(text: user.major ?? '');
    final regionController = TextEditingController(text: user.regionCampus ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: binusianController,
                decoration: const InputDecoration(labelText: 'Binusian'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: majorController,
                decoration: const InputDecoration(labelText: 'Major'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: regionController,
                decoration: const InputDecoration(labelText: 'Region Campus'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              try {
                final token = await _authService.getToken();
                if (token == null) return;
                final updated = await _authService.updateProfile(
                  token,
                  username: usernameController.text.trim(),
                  binusian: binusianController.text.trim(),
                  major: majorController.text.trim(),
                  regionCampus: regionController.text.trim(),
                );
                await auth.updateUser(updated);
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to update: $e')),
                );
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  label,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    return Scaffold(
      backgroundColor: Colors.white,
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    // Cover area
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Cover image
                        GestureDetector(
                          onTap: () => _pickCover(auth),
                          child: Container(
                            width: double.infinity,
                            height: 160,
                            color: Colors.grey.shade200,
                            child: user.coverUrl != null
                                ? Image.network(
                                    user.coverUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => const Center(
                                      child: Icon(
                                        Icons.image_outlined,
                                        size: 60,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                : const Center(
                                    child: Icon(
                                      Icons.image_outlined,
                                      size: 60,
                                      color: Colors.grey,
                                    ),
                                  ),
                          ),
                        ),

                        // Edit cover button
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => _pickCover(auth),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.edit_outlined,
                                size: 18,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),

                        // Avatar
                        Positioned(
                          bottom: -50,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: GestureDetector(
                              onTap: () => _pickAvatar(auth),
                              child: user.avatarUrl != null
                                  ? CircleAvatar(
                                      radius: 50,
                                      backgroundImage:
                                          NetworkImage(user.avatarUrl!),
                                    )
                                  : CircleAvatar(
                                      radius: 50,
                                      backgroundColor: Colors.grey.shade300,
                                      child: Text(
                                        user.username.isNotEmpty
                                            ? user.username[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                          fontSize: 40,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 60),

                    // Username + edit button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          user.username,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _editProfile(context, auth),
                          child: const Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),

                    // Info rows
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          const Divider(height: 1),
                          _buildInfoRow('Binusian', user.binusian),
                          _buildInfoRow('Major', user.major),
                          _buildInfoRow('Region Campus', user.regionCampus),
                        ],
                      ),
                    ),

                    const Spacer(),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () async {
                            await auth.logout();
                            if (!mounted) return;
                            Navigator.pushReplacementNamed(
                                context, '/register');
                          },
                          child: const Text(
                            'Log Out',
                            style:
                                TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
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
              isLabelVisible: _pendingRequestCount > 0,
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
          if (index == 0) Navigator.pushReplacementNamed(context, '/home');
          if (index == 1) Navigator.pushReplacementNamed(context, '/friends');
        },
      ),
    );
  }
}