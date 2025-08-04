import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RouteService {
  static const String _baseUrl =
      "https://api.openrouteservice.org/v2/directions/foot-walking";
  static String _apiKey = dotenv.env['ROUTE_SERVICE'] ?? '';

  static Future<List<LatLng>> getWalkingRoute(List<LatLng> wayPoints) async {
    if (wayPoints.length < 2) return [];

    final coordinates =
        wayPoints.map((p) => [p.longitude, p.latitude]).toList();

    final body = {
      "coordinates": coordinates,
      "instructions": false
    };

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        "Authorization": _apiKey.trim(),
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    print("🔹 Status code: ${response.statusCode}");
    print("🔹 Response body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data["routes"] != null && data["routes"].isNotEmpty) {
        final encodedGeometry = data["routes"][0]["geometry"];
        return _decodePolyline(encodedGeometry);
      } else {
        throw Exception("Formato della risposta non valido: ${response.body}");
      }
    } else {
      throw Exception("Errore API (${response.statusCode}): ${response.body}");
    }
  }

  static List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      polyline.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return polyline;
  }
}