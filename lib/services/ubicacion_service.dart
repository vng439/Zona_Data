// lib/services/ubicacion_service.dart

import 'package:geolocator/geolocator.dart';

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
}
