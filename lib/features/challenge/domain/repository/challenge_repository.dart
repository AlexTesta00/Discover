import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/challenge.dart';

class ChallengeRepository {
  static const String bucket = 'challenge';
  static const String objectPath = 'data/challenge.json';

  final _storage = Supabase.instance.client.storage;

  Future<List<Challenge>> loadAll() async {
    final publicUrl = _storage.from(bucket).getPublicUrl(objectPath);

    final res = await http.get(Uri.parse(publicUrl));
    if (res.statusCode != 200) {
      throw Exception(
        'Impossibile scaricare challenge.json (HTTP ${res.statusCode})',
      );
    }

    return Challenge.listFromJson(res.body);
  }
}
