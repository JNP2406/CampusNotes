class CourseModel {
  final int id;
  final int userId;
  final int semesterId;
  final String name;
  final String? coverUrl;
  final DateTime createdAt;

  CourseModel({
    required this.id,
    required this.userId,
    required this.semesterId,
    required this.name,
    this.coverUrl,
    required this.createdAt,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'],
      userId: json['userId'],
      semesterId: json['semesterId'],
      name: json['name'],
      coverUrl: json['coverUrl'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'semesterId': semesterId,
      'name': name,
      'coverUrl': coverUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}