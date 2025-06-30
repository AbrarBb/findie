class PostModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String category;
  final String building;
  final List<String> imageUrls;
  final String? ocrText;
  final bool isFound;
  final DateTime createdAt;
  final DateTime expiresAt;
  final List<String> tags;
  final Map<String, dynamic>? metadata;
  final UserModel? user;

  PostModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.building,
    required this.imageUrls,
    this.ocrText,
    required this.isFound,
    required this.createdAt,
    required this.expiresAt,
    this.tags = const [],
    this.metadata,
    this.user,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      building: json['building'] as String,
      imageUrls: List<String>.from(json['image_urls'] ?? []),
      ocrText: json['ocr_text'] as String?,
      isFound: json['is_found'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String),
      tags: List<String>.from(json['tags'] ?? []),
      metadata: json['metadata'] as Map<String, dynamic>?,
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'category': category,
      'building': building,
      'image_urls': imageUrls,
      'ocr_text': ocrText,
      'is_found': isFound,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'tags': tags,
      'metadata': metadata,
    };
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}