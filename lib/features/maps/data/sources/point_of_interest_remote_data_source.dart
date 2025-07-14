import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fpdart/fpdart.dart';
import 'package:discover/features/maps/data/models/point_of_interest_model.dart';
import 'package:discover/features/maps/domain/entities/point_of_interest.dart';

typedef ErrorMessage = String;

//This links expire in 10 years
const _url =  'https://xvavdibparbwguuiftrs.supabase.co/storage/v1/object/sign/assets/riccione_points.json?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV9jZmFiZWY5NS03YTI3LTQ2YTQtOWU1Ny01MWI0MzNkOThlYmYiLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJhc3NldHMvcmljY2lvbmVfcG9pbnRzLmpzb24iLCJpYXQiOjE3NTI0OTYxNDgsImV4cCI6MjM4MzIxNjE0OH0.NoTZso7ZVc_c9PED9QoYVEUy0_bPJILK2QbWpCCabpo';

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