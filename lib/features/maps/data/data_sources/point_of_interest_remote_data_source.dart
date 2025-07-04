import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fpdart/fpdart.dart';
import 'package:discover/features/maps/data/models/point_of_interest_model.dart';
import 'package:discover/features/maps/domain/entities/point_of_interest.dart';

typedef ErrorMessage = String;

//This links expire in 10 years
const _url =  'https://xvavdibparbwguuiftrs.supabase.co/storage/v1/object/sign/assets/riccione_points.json?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV8zZjJiMjFmOC0zY2FkLTQ4MzEtODI0Ny0zNjFkNGI4MTI3M2MiLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJhc3NldHMvcmljY2lvbmVfcG9pbnRzLmpzb24iLCJpYXQiOjE3NTE2MjAxOTQsImV4cCI6MjA2Njk4MDE5NH0.FjMR0uPuctCDrZDmK-YuS023lMSDnzAgAWNTCYjz0q4';

TaskEither<ErrorMessage, List<PointOfInterest>> loadPointsFromJson() => 
  TaskEither.tryCatch(
    () async {
      final response = await http.get(Uri.parse(_url));
      if(response.statusCode != 200){
        throw Exception("Impossibile accedere alla risorsa: ${response.statusCode}");
      }
      final List<dynamic> jsonList = json.decode(response.body);
      final models = jsonList
          .map((json) => PointOfInterestModel.fromJson(json))
          .toList();
      
      return models.map((model) => model.toEntity()).toList();
    }, 
    (error, _) => "Errore durante il caricamento dei punti: $error");