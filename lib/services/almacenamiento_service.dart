import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';


typedef ImagenUrls = ({String imagenUrl, String thumbnailUrl});

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Comprime la imagen en dos versiones y las sube a Firebase Storage.
  /// Retorna las URLs de descarga de ambas versiones.
  Future<ImagenUrls> subirImagenReporte({
    required File imagen,
    required String autorId,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final tempDir = await getTemporaryDirectory();

    // Generar versión completa: 1080px ancho, calidad 80
    final archivoCompleto = await FlutterImageCompress.compressAndGetFile(
      imagen.absolute.path,
      '${tempDir.path}/${timestamp}_full.jpg',
      minWidth: 1080,
      minHeight: 1,
      quality: 80,
      format: CompressFormat.jpeg,
    );

    // Generar thumbnail: 300px ancho, calidad 70
    final archivoThumb = await FlutterImageCompress.compressAndGetFile(
      imagen.absolute.path,
      '${tempDir.path}/${timestamp}_thumb.jpg',
      minWidth: 300,
      minHeight: 1,
      quality: 70,
      format: CompressFormat.jpeg,
    );

    if (archivoCompleto == null || archivoThumb == null) {
      throw Exception('Error al comprimir la imagen');
    }

    // Subir versión completa
    final refCompleto =
        _storage.ref('reportes/$autorId/${timestamp}_full.jpg');
    await refCompleto.putFile(
      File(archivoCompleto.path),
      SettableMetadata(contentType: 'image/jpeg'),
    );
    final imagenUrl = await refCompleto.getDownloadURL();

    // Subir thumbnail
    final refThumb =
        _storage.ref('reportes/$autorId/${timestamp}_thumb.jpg');
    await refThumb.putFile(
      File(archivoThumb.path),
      SettableMetadata(contentType: 'image/jpeg'),
    );
    final thumbnailUrl = await refThumb.getDownloadURL();

    return (imagenUrl: imagenUrl, thumbnailUrl: thumbnailUrl);
  }

  /// Elimina una imagen de Storage a partir de su URL de descarga.
  /// Si la URL es inválida o el archivo ya no existe, no lanza error.
  Future<void> eliminarImagen(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      // Si ya no existe o la URL es inválida, simplemente lo ignoramos
    }
  }
}

