class FileModel {
  final int id;
  final int userId;
  final int courseId;
  final String title;
  final String fileUrl;
  final String? fileType;
  final bool isShared;
  final DateTime createdAt;

  FileModel({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.title,
    required this.fileUrl,
    this.fileType,
    required this.isShared,
    required this.createdAt,
  });

  factory FileModel.fromJson(Map<String, dynamic> json) {
    return FileModel(
      id: json['id'],
      userId: json['userId'],
      courseId: json['courseId'],
      title: json['title'],
      fileUrl: json['fileUrl'],
      fileType: json['fileType'],
      isShared: json['isShared'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'courseId': courseId,
      'title': title,
      'fileUrl': fileUrl,
      'fileType': fileType,
      'isShared': isShared,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}