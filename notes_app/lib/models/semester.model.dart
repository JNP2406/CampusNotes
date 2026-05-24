class SemesterModel {
  final int id;
  final int userId;
  final String name;
  final String? coverUrl;
  final DateTime createdAt;

  SemesterModel({
    required this.id,
    required this.userId,
    required this.name,
    this.coverUrl,
    required this.createdAt,
  });

  factory SemesterModel.fromJson(Map<String, dynamic> json) {
    return SemesterModel(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      coverUrl: json['coverUrl'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'coverUrl': coverUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}