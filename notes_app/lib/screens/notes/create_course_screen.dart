import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:notes_app/models/semester.model.dart';
import 'package:notes_app/services/study.service.dart';

class CreateCourseScreen extends StatefulWidget {
  const CreateCourseScreen({super.key});

  @override
  State<CreateCourseScreen> createState() =>
      _CreateCourseScreenState();
}

class _CreateCourseScreenState
    extends State<CreateCourseScreen> {
  final StudyService _studyService =
      StudyService();

  final _nameController =
      TextEditingController();

  bool _isLoading = false;

  File? _coverImage;

  late SemesterModel semester;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    semester =
        ModalRoute.of(context)!
            .settings
            .arguments as SemesterModel;
  }

  @override
  void dispose() {
    _nameController.dispose();

    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    final picked = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (picked != null) {
      setState(() {
        _coverImage = File(picked.path);
      });
    }
  }

  Future<void> _createCourse() async {
    if (_nameController.text
        .trim()
        .isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text('Please enter course name'),
        ),
      );

      return;
    }

    setState(() => _isLoading = true);

    try {
      String? coverUrl;

      // Upload cover first
      if (_coverImage != null) {
        coverUrl =
            await _studyService.uploadFile(
          _coverImage!,
        );
      }

      // Create course
      final course =
          await _studyService.createCourse(
        _nameController.text.trim(),
        semester.id,
        coverUrl: coverUrl,
      );

      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        '/course',
        arguments: course,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Failed to create course: $e',
          ),
        ),
      );

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
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () =>
              Navigator.pop(context),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            const SizedBox(height: 24),

            const Text(
              'Course Notes',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _nameController,

              decoration: InputDecoration(
                hintText:
                    'Biology, Physics, etc',

                hintStyle: const TextStyle(
                  color: Colors.grey,
                ),

                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    24,
                  ),

                  borderSide: BorderSide(
                    color:
                        Colors.grey.shade300,
                  ),
                ),

                enabledBorder:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    24,
                  ),

                  borderSide: BorderSide(
                    color:
                        Colors.grey.shade300,
                  ),
                ),

                contentPadding:
                    const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Upload Cover For This Course',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 8),

            GestureDetector(
              onTap: _pickImage,

              child: Container(
                width: double.infinity,
                height: 120,

                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),

                  image: _coverImage != null
                      ? DecorationImage(
                          image: FileImage(
                            _coverImage!,
                          ),

                          fit: BoxFit.cover,
                        )
                      : null,
                ),

                child: _coverImage == null
                    ? const Column(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,

                        children: [
                          Icon(
                            Icons.upload,
                            size: 36,
                            color:
                                Colors.black54,
                          ),

                          SizedBox(height: 8),

                          Text(
                            'Upload Cover',
                            style: TextStyle(
                              color:
                                  Colors.black54,
                            ),
                          ),
                        ],
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.black,

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      8,
                    ),
                  ),

                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                ),

                onPressed:
                    _isLoading
                        ? null
                        : _createCourse,

                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        'Create Course',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}