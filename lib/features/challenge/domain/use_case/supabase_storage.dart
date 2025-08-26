import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageService {
  final _client = Supabase.instance.client;

  Future<void> uploadChallengePhoto({
    required File file,
    required String email,
    String? filename,
  }) async {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final name = filename ?? '${email}_$ts.jpg';
    await _client.storage
        .from('challenge')
        .upload(name, file, fileOptions: const FileOptions(contentType: 'image/jpeg'));
  }
}
