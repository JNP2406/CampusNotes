import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:notes_app/models/course.model.dart';
import 'package:notes_app/models/file.model.dart';
import 'package:notes_app/services/study.service.dart';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class CourseScreen extends StatefulWidget {
  const CourseScreen({super.key});

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  final StudyService _studyService = StudyService();
  List<FileModel> _files = [];
  bool _isLoading = true;
  late CourseModel course;
  File? _coverImage;
  bool _isFirstLoad = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirstLoad) {
      _isFirstLoad = false;
      course = ModalRoute.of(context)!.settings.arguments as CourseModel;
      _loadCourseAndFiles();
    }
  }

  Future<void> _loadCourseAndFiles() async {
    if (!mounted) return;
    try {
      final courses = await _studyService.getCourses(course.semesterId);
      final updated = courses.firstWhere((c) => c.id == course.id);
      final files = await _studyService.getFiles(course.id);
      if (!mounted) return;
      setState(() {
        course = updated;
        _coverImage = null;
        _files = files;
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
        final updated = await _studyService.updateCourse(course.id, coverUrl: url);
        if (!mounted) return;
        setState(() => course = updated);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cover updated!')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload cover')),
        );
      }
    }
  }

  Future<void> _editName() async {
    final nameController = TextEditingController(text: course.name);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Course Name'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Course Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final updated = await _studyService.updateCourse(
                  course.id,
                  name: nameController.text.trim(),
                );
                if (!mounted) return;
                setState(() => course = updated);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _addFile() async {
    try {
      final result = await fp.FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: fp.FileType.any,
      );
      if (result != null && result.files.isNotEmpty) {
        final pickedFile = result.files.first;
        final file = File(pickedFile.path!);
        final url = await _studyService.uploadFile(file);
        await _studyService.createFile(
          title: pickedFile.name,
          courseId: course.id,
          fileUrl: url,
          fileType: pickedFile.extension,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File uploaded!')),
        );
        await _loadCourseAndFiles();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload: $e')),
      );
    }
  }

  Future<void> _openFile(String url, String fileName) async {
    try {
      final response = await http.get(Uri.parse(url));
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      await OpenFilex.open(filePath);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to open file: $e')),
      );
    }
  }

  Future<void> _deleteFile(FileModel file) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File'),
        content: Text('Delete "${file.title}"?'),
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
      await _studyService.deleteFile(file.id);
      await _loadCourseAndFiles();
    }
  }

  IconData _getFileIcon(String? fileType) {
    switch (fileType?.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
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
              child: course.coverUrl != null && _coverImage == null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          course.coverUrl!,
                          key: ValueKey(course.coverUrl),
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
                  course.name,
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
                : _files.isEmpty
                    ? const Center(
                        child: Text('No files yet', style: TextStyle(color: Colors.grey)),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _files.length,
                        itemBuilder: (context, index) {
                          final file = _files[index];
                          return GestureDetector(
                            onTap: () => _openFile(file.fileUrl, file.title),
                            onLongPress: () => _deleteFile(file),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _getFileIcon(file.fileType),
                                    color: Colors.black,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          file.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          file.fileType?.toLowerCase() ?? 'file',
                                          style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addFile,
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}