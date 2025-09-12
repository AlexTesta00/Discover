import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fpdart/fpdart.dart';
import 'package:discover/features/maps/data/models/point_of_interest_model.dart';
import 'package:discover/features/maps/domain/entities/point_of_interest.dart';

typedef ErrorMessage = String;

TaskEither<ErrorMessage, List<PointOfInterest>> loadPointsFromStorage() =>
  TaskEither.tryCatch(
    () async {
      final supabase = Supabase.instance.client;

      final bytes = await supabase
          .storage
          .from('assets')
          .download('points_of_interest.json');

      final body = utf8.decode(bytes);
      final List<dynamic> jsonList = json.decode(body);

      final models = jsonList
          .map((j) => PointOfInterestModel.fromJson(j))
          .toList();

      return models.map((m) => m.toEntity()).toList();
    },
    (error, _) => 'Errore durante il caricamento dei punti: $error',
  );