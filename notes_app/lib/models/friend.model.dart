class FriendRequestModel {
  final int id;
  final int senderId;
  final int receiverId;
  final String status;
  final DateTime createdAt;
  final UserFriendModel? sender;
  final UserFriendModel? receiver;

  FriendRequestModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.createdAt,
    this.sender,
    this.receiver,
  });

  factory FriendRequestModel.fromJson(Map<String, dynamic> json) {
    return FriendRequestModel(
      id: json['id'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      sender: json['sender'] != null ? UserFriendModel.fromJson(json['sender']) : null,
      receiver: json['receiver'] != null ? UserFriendModel.fromJson(json['receiver']) : null,
    );
  }
}

class FriendModel {
  final int id;
  final int userId;
  final int friendId;
  final DateTime createdAt;
  final UserFriendModel friend;

  FriendModel({
    required this.id,
    required this.userId,
    required this.friendId,
    required this.createdAt,
    required this.friend,
  });

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    return FriendModel(
      id: json['id'],
      userId: json['userId'],
      friendId: json['friendId'],
      createdAt: DateTime.parse(json['createdAt']),
      friend: UserFriendModel.fromJson(json['friend']),
    );
  }
}

class UserFriendModel {
  final int id;
  final String username;
  final String email;
  final String? avatarUrl;
  final String? binusian;
  final String? major;

  UserFriendModel({
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl,
    this.binusian,
    this.major,
  });

  factory UserFriendModel.fromJson(Map<String, dynamic> json) {
    return UserFriendModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      avatarUrl: json['avatarUrl'],
      binusian: json['binusian'],
      major: json['major'],
    );
  }
}

class FriendshipStatusModel {
  final String status;
  final int? requestId;

  FriendshipStatusModel({
    required this.status,
    this.requestId,
  });

  factory FriendshipStatusModel.fromJson(Map<String, dynamic> json) {
    return FriendshipStatusModel(
      status: json['status'],
      requestId: json['requestId'],
    );
  }
}