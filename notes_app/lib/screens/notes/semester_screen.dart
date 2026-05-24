import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:notes_app/models/course.model.dart';
import 'package:notes_app/models/semester.model.dart';
import 'package:notes_app/services/study.service.dart';

class SemesterScreen extends StatefulWidget {
  const SemesterScreen({super.key});

  @override
  State<SemesterScreen> createState() => _SemesterScreenState();
}

class _SemesterScreenState extends State<SemesterScreen> {
  final StudyService _studyService = StudyService();
  List<CourseModel> _courses = [];
  bool _isLoading = true;
  late SemesterModel semester;
  File? _coverImage;
  bool _isFirstLoad = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirstLoad) {
      _isFirstLoad = false;
      semester = ModalRoute.of(context)!.settings.arguments as SemesterModel;
      _coverImage = null;
      _loadSemesterAndCourses();
    }
  }

  Future<void> _loadSemesterAndCourses() async {
    if (!mounted) return;
    try {
      final semesters = await _studyService.getSemesters();
      final updated = semesters.firstWhere((s) => s.id == semester.id);
      final courses = await _studyService.getCourses(semester.id);
      if (!mounted) return;
      setState(() {
        semester = updated;
        _coverImage = null;
        _courses = courses;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickCover() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (!mounted) return;
    if (picked != null) {
      setState(() => _coverImage = File(picked.path));
      try {
        final url = await _studyService.uploadFile(_coverImage!);
        if (!mounted) return;
        final updated = await _studyService.updateSemester(semester.id, coverUrl: url);
        if (!mounted) return;
        setState(() => semester = updated);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cover updated!')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _editName() async {
    final nameController = TextEditingController(text: semester.name);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Semester Name'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Semester Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final updated = await _studyService.updateSemester(
                  semester.id,
                  name: nameController.text.trim(),
                );
                if (!mounted) return;
                setState(() => semester = updated);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _addCourse() async {
    await Navigator.pushNamed(context, '/create-course', arguments: semester);
    if (!mounted) return;
    _loadSemesterAndCourses();
  }

  Future<void> _deleteCourse(CourseModel course) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Course'),
        content: Text('Delete "${course.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _studyService.deleteCourse(course.id);
      await _loadSemesterAndCourses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          GestureDetector(
            onTap: _pickCover,
            child: Container(
              width: double.infinity,
              height: 180,
              color: Colors.grey.shade200,
              child: semester.coverUrl != null && _coverImage == null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          semester.coverUrl!,
                          key: ValueKey(semester.coverUrl),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image_outlined, size: 60, color: Colors.grey),
                        ),
                        Positioned(
                          top: 40,
                          left: 16,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.pop(context, true),
                          ),
                        ),
                        const Positioned(
                          bottom: 8,
                          right: 8,
                          child: Icon(Icons.edit_outlined, color: Colors.white),
                        ),
                      ],
                    )
                  : _coverImage != null
                      ? Stack(
                          children: [
                            Image.file(_coverImage!, width: double.infinity, height: 180, fit: BoxFit.cover),
                            Positioned(
                              top: 40,
                              left: 16,
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back, color: Colors.white),
                                onPressed: () => Navigator.pop(context, true),
                              ),
                            ),
                            const Positioned(
                              bottom: 8,
                              right: 8,
                              child: Icon(Icons.edit_outlined, color: Colors.white),
                            ),
                          ],
                        )
                      : Stack(
                          children: [
                            const Center(
                              child: Icon(Icons.image_outlined, size: 60, color: Colors.grey),
                            ),
                            Positioned(
                              top: 40,
                              left: 16,
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back, color: Colors.black),
                                onPressed: () => Navigator.pop(context, true),
                              ),
                            ),
                            const Positioned(
                              bottom: 8,
                              right: 8,
                              child: Icon(Icons.edit_outlined, color: Colors.grey),
                            ),
                          ],
                        ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Text(
                  semester.name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _editName,
                  child: const Icon(Icons.edit_outlined, size: 20, color: Colors.grey),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Stack(
                    children: [
                      GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _courses.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return GestureDetector(
                              onTap: _addCourse,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade400),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add, size: 40, color: Colors.black54),
                                    SizedBox(height: 8),
                                    Text(
                                      'Create Course',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.black54, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          final course = _courses[index - 1];
                          return GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/course', arguments: course),
                            onLongPress: () => _deleteCourse(course),
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
                                            key: ValueKey(course.coverUrl),
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) =>
                                                const Icon(Icons.folder_outlined, size: 48),
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
                                          const Icon(Icons.folder_outlined, size: 48),
                                          const SizedBox(height: 8),
                                          Text(
                                            course.name,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          );
                        },
                      ),
                      if (_courses.isEmpty)
                        const Center(
                          child: Text('No courses yet', style: TextStyle(color: Colors.grey)),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}