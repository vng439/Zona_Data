// lib/services/ubicacion_service.dart

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class UbicacionService {
  // Solicita permiso y devuelve la ubicación actual
  Future<Position?> obtenerUbicacion() async {
    // Verificamos si el servicio de ubicación está habilitado
    final servicioHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicioHabilitado) return null;

    // Verificamos el permiso actual
    LocationPermission permiso = await Geolocator.checkPermission();

    // Si fue denegado, lo pedimos
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) return null;
    }

    // Si fue denegado permanentemente no podemos hacer nada
    if (permiso == LocationPermission.deniedForever) return null;

    // Tenemos permiso, obtenemos la ubicación
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );


    
  }

  /// Convierte coordenadas en una dirección legible (calle aproximada).
/// Devuelve null si no se pudo resolver.
Future<String?> obtenerDireccion(double latitud, double longitud) async {
  try {
    final ubicaciones = await placemarkFromCoordinates(latitud, longitud);
    if (ubicaciones.isEmpty) return null;

    final lugar = ubicaciones.first;
    final partes = [
      if (lugar.street != null && lugar.street!.isNotEmpty) lugar.street,
      if (lugar.subLocality != null && lugar.subLocality!.isNotEmpty)
        lugar.subLocality,
    ];

    if (partes.isEmpty) return null;
    return partes.join(', ');
  } catch (e) {
    return null;
  }
}
}
