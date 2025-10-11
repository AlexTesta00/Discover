
import 'dart:io';
import 'package:discover/features/user/domain/use_cases/user_service.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';

final _supabase = Supabase.instance.client;

typedef Error = String;

Future<Either<Error, Unit>> submitNotice(String category, String description, File? photo) async {
  try{
    final email = getUserEmail();
    if(email == null){
      return left('Utente non autenticato, impossibile inviare la segnalazione');
    }

    String? imageUrl;

    if(photo != null){
      final fileExt = path.extension(photo.path);
      final fileName = '${DateTime.now().microsecondsSinceEpoch}$fileExt';
      final mimeType = lookupMimeType(photo.path);

      final storageResponse = await _supabase.storage
        .from('notices')
        .upload(
          'notice/$fileName', 
          photo,
          fileOptions: FileOptions(contentType: mimeType),
        );
      
      if(storageResponse.isEmpty){
        return left('Errore durante l\'upload dell\'immagine');
      }

      imageUrl = _supabase.storage.from('notices').getPublicUrl('notice/$fileName');
    }

    final insertResponse = await _supabase.from('notices').insert({
      'email': email,
      'category': category,
      'description': description,
      'image': imageUrl
    });

    return right(unit);
  }catch (error) {
    return left('Errore imprevisto: $error');
  }
}