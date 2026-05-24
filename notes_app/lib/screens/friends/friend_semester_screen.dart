import 'package:flutter/material.dart';
import 'package:notes_app/models/friend.model.dart';
import 'package:notes_app/models/semester.model.dart';
import 'package:notes_app/models/course.model.dart';
import 'package:notes_app/services/auth.service.dart';
import 'package:notes_app/services/friend_notes.service.dart';

class FriendSemesterScreen extends StatefulWidget {
  const FriendSemesterScreen({super.key});

  @override
  State<FriendSemesterScreen> createState() => _FriendSemesterScreenState();
}

class _FriendSemesterScreenState extends State<FriendSemesterScreen> {
  final FriendNotesService _friendNotesService = FriendNotesService();
  final AuthService _authService = AuthService();

  List<CourseModel> _courses = [];
  bool _isLoading = true;
  late UserFriendModel _friend;
  late SemesterModel _semester;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _friend = args['friend'] as UserFriendModel;
    _semester = args['semester'] as SemesterModel;
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    try {
      final token = await _authService.getToken();
      if (token == null) return;
      final courses = await _friendNotesService.getFriendCourses(
        token,
        _friend.id,
        _semester.id,
      );
      if (!mounted) return;
      setState(() {
        _courses = courses;
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
          _semester.name,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _courses.isEmpty
              ? const Center(
                  child: Text(
                    'No course yet',
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
                  itemCount: _courses.length,
                  itemBuilder: (context, index) {
                    final course = _courses[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/friend-course',
                          arguments: {
                            'friend': _friend,
                            'course': course,
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
                          child: course.coverUrl != null
                              ? Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.network(
                                      course.coverUrl!,
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
                                          course.name,
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
                                      course.name,
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