class MessageModel {
  final String id;
  final String fromUserId;
  final String toUserId;
  final String postId;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final UserModel? fromUser;

  MessageModel({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.postId,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.fromUser,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      fromUserId: json['from_user_id'] as String,
      toUserId: json['to_user_id'] as String,
      postId: json['post_id'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['is_read'] as bool? ?? false,
      fromUser: json['from_user'] != null 
          ? UserModel.fromJson(json['from_user']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from_user_id': fromUserId,
      'to_user_id': toUserId,
      'post_id': postId,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'is_read': isRead,
    };
  }
}