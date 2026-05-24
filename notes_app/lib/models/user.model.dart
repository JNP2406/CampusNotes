class UserModel {
  final int id;
  final String username;
  final String email;
  final String? binusian;
  final String? major;
  final String? regionCampus;
  final String? avatarUrl;
  final String? coverUrl; // tambah ini

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.binusian,
    this.major,
    this.regionCampus,
    this.avatarUrl,
    this.coverUrl, // tambah ini
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      binusian: json['binusian'],
      major: json['major'],
      regionCampus: json['regionCampus'],
      avatarUrl: json['avatarUrl'],
      coverUrl: json['coverUrl'], // tambah ini
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'binusian': binusian,
      'major': major,
      'regionCampus': regionCampus,
      'avatarUrl': avatarUrl,
      'coverUrl': coverUrl, // tambah ini
    };
  }
}