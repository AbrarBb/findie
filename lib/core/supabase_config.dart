import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class SupabaseConfig {
  static late String _supabaseUrl;
  static late String _supabaseAnonKey;
  
  static Future<void> initialize() async {
    try {
      // Load environment variables from env.json
      final String envString = await rootBundle.loadString('env.json');
      final Map<String, dynamic> env = json.decode(envString);
      
      _supabaseUrl = env['SUPABASE_URL'] ?? 'https://dummy.supabase.co';
      _supabaseAnonKey = env['SUPABASE_ANON_KEY'] ?? 'dummykey.updateyourkkey.here';
      
      await Supabase.initialize(
        url: _supabaseUrl,
        anonKey: _supabaseAnonKey,
        debug: true,
      );
    } catch (e) {
      print('Error initializing Supabase: $e');
      // Fallback to dummy values for development
      await Supabase.initialize(
        url: 'https://dummy.supabase.co',
        anonKey: 'dummykey.updateyourkkey.here',
        debug: true,
      );
    }
  }
  
  static SupabaseClient get client => Supabase.instance.client;
  static GoTrueClient get auth => client.auth;
  static SupabaseStorageClient get storage => client.storage;
  static RealtimeClient get realtime => client.realtime;
}