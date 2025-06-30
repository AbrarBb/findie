import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../core/supabase_config.dart';

class StorageService {
  final SupabaseClient _client = SupabaseConfig.client;
  final _uuid = const Uuid();

  // Upload image to Supabase Storage
  Future<String?> uploadImage({
    required File file,
    required String bucket,
    String? folder,
  }) async {
    try {
      final fileName = '${_uuid.v4()}.jpg';
      final path = folder != null ? '$folder/$fileName' : fileName;

      await _client.storage.from(bucket).upload(path, file);

      final url = _client.storage.from(bucket).getPublicUrl(path);
      return url;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Upload multiple images
  Future<List<String>> uploadImages({
    required List<File> files,
    required String bucket,
    String? folder,
  }) async {
    final urls = <String>[];

    for (final file in files) {
      final url = await uploadImage(
        file: file,
        bucket: bucket,
        folder: folder,
      );
      if (url != null) {
        urls.add(url);
      }
    }

    return urls;
  }

  // Delete image from storage
  Future<bool> deleteImage({
    required String bucket,
    required String path,
  }) async {
    try {
      await _client.storage.from(bucket).remove([path]);
      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  // Get image URL
  String getImageUrl({
    required String bucket,
    required String path,
  }) {
    return _client.storage.from(bucket).getPublicUrl(path);
  }
}

// Provider for StorageService
final storageServiceProvider = Provider<StorageService>((ref) => StorageService());