import 'package:flutter/material.dart';
import 'package:notes_app/models/friend.model.dart';
import 'package:notes_app/models/semester.model.dart';
import 'package:notes_app/services/auth.service.dart';
import 'package:notes_app/services/friend_notes.service.dart';

class FriendNotesScreen extends StatefulWidget {
  const FriendNotesScreen({super.key});

  @override
  State<FriendNotesScreen> createState() => _FriendNotesScreenState();
}

class _FriendNotesScreenState extends State<FriendNotesScreen> {
  final FriendNotesService _friendNotesService = FriendNotesService();
  final AuthService _authService = AuthService();

  List<SemesterModel> _semesters = [];
  bool _isLoading = true;
  late UserFriendModel _friend;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _friend = ModalRoute.of(context)!.settings.arguments as UserFriendModel;
    _loadSemesters();
  }

  Future<void> _loadSemesters() async {
    try {
      final token = await _authService.getToken();
      if (token == null) return;
      final semesters = await _friendNotesService.getFriendSemesters(token, _friend.id);
      if (!mounted) return;
      setState(() {
        _semesters = semesters;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _friend.username,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _semesters.isEmpty
              ? const Center(
                  child: Text(
                    'No semesters yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _semesters.length,
                  itemBuilder: (context, index) {
                    final semester = _semesters[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/friend-semester',
                          arguments: {
                            'friend': _friend,
                            'semester': semester,
                          },
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: semester.coverUrl != null
                              ? Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.network(
                                      semester.coverUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.article_outlined, size: 48),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        color: Colors.black54,
                                        padding: const EdgeInsets.all(8),
                                        child: Text(
                                          semester.name,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.article_outlined, size: 48),
                                    const SizedBox(height: 8),
                                    Text(
                                      semester.name,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}