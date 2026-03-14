import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Requests permission (if needed) and returns the current device position.
  /// Throws a descriptive Exception on failure.
  static Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Serviço de localização está desabilitado. Ative o GPS.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permissão de localização negada.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permissão de localização negada permanentemente. Habilite nas configurações.');
    }

    // Busca a posição atual com precisão média/alta
    final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    return pos;
  }
}
