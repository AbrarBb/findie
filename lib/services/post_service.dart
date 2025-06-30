import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_config.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';

class PostService {
  final SupabaseClient _client = SupabaseConfig.client;

  // Get all posts with filters
  Future<List<PostModel>> getPosts({
    bool? isFound,
    String? category,
    String? building,
    String? searchQuery,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      var query = _client
          .from('posts')
          .select('''
            *,
            user:users(*)
          ''')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      // Apply filters
      if (isFound != null) {
        query = query.eq('is_found', isFound);
      }
      
      if (category != null && category.isNotEmpty) {
        query = query.eq('category', category);
      }
      
      if (building != null && building.isNotEmpty) {
        query = query.eq('building', building);
      }

      // Search in title, description, and OCR text
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or(
          'title.ilike.%$searchQuery%,'
          'description.ilike.%$searchQuery%,'
          'ocr_text.ilike.%$searchQuery%'
        );
      }

      final response = await query;
      return (response as List)
          .map((json) => PostModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting posts: $e');
      return [];
    }
  }

  // Get post by ID
  Future<PostModel?> getPostById(String id) async {
    try {
      final response = await _client
          .from('posts')
          .select('''
            *,
            user:users(*)
          ''')
          .eq('id', id)
          .single();

      return PostModel.fromJson(response);
    } catch (e) {
      print('Error getting post: $e');
      return null;
    }
  }

  // Create new post
  Future<PostModel?> createPost({
    required String title,
    required String description,
    required String category,
    required String building,
    required List<String> imageUrls,
    required bool isFound,
    String? ocrText,
    List<String> tags = const [],
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final expiresAt = DateTime.now().add(const Duration(days: 14));

      final response = await _client.from('posts').insert({
        'user_id': user.id,
        'title': title,
        'description': description,
        'category': category,
        'building': building,
        'image_urls': imageUrls,
        'ocr_text': ocrText,
        'is_found': isFound,
        'expires_at': expiresAt.toIso8601String(),
        'tags': tags,
      }).select('''
        *,
        user:users(*)
      ''').single();

      return PostModel.fromJson(response);
    } catch (e) {
      print('Error creating post: $e');
      return null;
    }
  }

  // Update post
  Future<PostModel?> updatePost({
    required String id,
    String? title,
    String? description,
    String? category,
    String? building,
    List<String>? imageUrls,
    String? ocrText,
    List<String>? tags,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (title != null) updates['title'] = title;
      if (description != null) updates['description'] = description;
      if (category != null) updates['category'] = category;
      if (building != null) updates['building'] = building;
      if (imageUrls != null) updates['image_urls'] = imageUrls;
      if (ocrText != null) updates['ocr_text'] = ocrText;
      if (tags != null) updates['tags'] = tags;

      if (updates.isEmpty) return null;

      final response = await _client
          .from('posts')
          .update(updates)
          .eq('id', id)
          .select('''
            *,
            user:users(*)
          ''')
          .single();

      return PostModel.fromJson(response);
    } catch (e) {
      print('Error updating post: $e');
      return null;
    }
  }

  // Delete post
  Future<bool> deletePost(String id) async {
    try {
      await _client.from('posts').delete().eq('id', id);
      return true;
    } catch (e) {
      print('Error deleting post: $e');
      return false;
    }
  }

  // Get user's posts
  Future<List<PostModel>> getUserPosts(String userId) async {
    try {
      final response = await _client
          .from('posts')
          .select('''
            *,
            user:users(*)
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => PostModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting user posts: $e');
      return [];
    }
  }

  // Extend post expiry
  Future<bool> extendPostExpiry(String id, {int days = 7}) async {
    try {
      final post = await getPostById(id);
      if (post == null) return false;

      final newExpiryDate = post.expiresAt.add(Duration(days: days));

      await _client
          .from('posts')
          .update({'expires_at': newExpiryDate.toIso8601String()})
          .eq('id', id);

      return true;
    } catch (e) {
      print('Error extending post expiry: $e');
      return false;
    }
  }

  // Search posts with full-text search
  Future<List<PostModel>> searchPosts(String query) async {
    try {
      final response = await _client
          .from('posts')
          .select('''
            *,
            user:users(*)
          ''')
          .textSearch('title,description,ocr_text', query)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => PostModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error searching posts: $e');
      return [];
    }
  }
}

// Provider for PostService
final postServiceProvider = Provider<PostService>((ref) => PostService());

// Provider for posts
final postsProvider = FutureProvider.family<List<PostModel>, Map<String, dynamic>>((ref, filters) async {
  final postService = ref.watch(postServiceProvider);
  return await postService.getPosts(
    isFound: filters['isFound'] as bool?,
    category: filters['category'] as String?,
    building: filters['building'] as String?,
    searchQuery: filters['searchQuery'] as String?,
  );
});

// Provider for user posts
final userPostsProvider = FutureProvider.family<List<PostModel>, String>((ref, userId) async {
  final postService = ref.watch(postServiceProvider);
  return await postService.getUserPosts(userId);
});