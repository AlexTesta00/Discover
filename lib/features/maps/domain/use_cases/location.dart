import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {

  static Future<bool> requestLocationPermission() async {
    var status = await Permission.location.status;
    if(status.isDenied){
      status = await Permission.locationWhenInUse.request();
    }

    return status.isGranted;
  }

  static Future<Position?> getCurrentLocation() async {
    final hasPermission = await requestLocationPermission();
    if(!hasPermission) return null;

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}