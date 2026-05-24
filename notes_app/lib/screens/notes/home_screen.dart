import 'package:flutter/material.dart';
import 'package:notes_app/services/study.service.dart';
import 'package:notes_app/models/semester.model.dart';
import 'package:notes_app/services/friend.service.dart';
import 'package:notes_app/services/auth.service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StudyService _studyService = StudyService();
  final FriendService _friendService = FriendService();
  final AuthService _authService = AuthService();

  List<SemesterModel> _semesters = [];
  bool _isLoading = true;
  int _pendingRequestCount = 0;

  @override
  void initState() {
    super.initState();
    _loadSemesters();
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

  Future<void> _loadSemesters() async {
    try {
      final semesters = await _studyService.getSemesters();
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

  Future<void> _addSemester() async {
    final result = await Navigator.pushNamed(context, '/create-semester');
    if (result == true) {
      setState(() => _isLoading = true);
      await _loadSemesters();
    }
  }

  Future<void> _goToSemester(SemesterModel semester) async {
    await Navigator.pushNamed(context, '/semester', arguments: semester);
    if (!mounted) return;
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    setState(() => _isLoading = true);
    await _loadSemesters();
  }

  Future<void> _deleteSemester(SemesterModel semester) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Semester'),
        content: Text('Delete "${semester.name}"?'),
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
      await _studyService.deleteSemester(semester.id);
      setState(() => _isLoading = true);
      await _loadSemesters();
    }
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
          'Your Notes',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
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
                  itemCount: _semesters.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return GestureDetector(
                        onTap: _addSemester,
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
                                'Create Your own Notes',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.black54, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final semester = _semesters[index - 1];
                    return GestureDetector(
                      onTap: () => _goToSemester(semester),
                      onLongPress: () => _deleteSemester(semester),
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
                                      key: ValueKey(semester.coverUrl),
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
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    );
                  },
                ),
                if (_semesters.isEmpty)
                  const Center(
                    child: Text('No notes yet', style: TextStyle(color: Colors.grey)),
                  ),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
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
          if (index == 1) Navigator.pushNamed(context, '/friends');
          if (index == 2) Navigator.pushNamed(context, '/profile');
        },
      ),
    );
  }
}