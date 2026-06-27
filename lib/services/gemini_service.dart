import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_keys.dart';

enum ResultadoModeracionImagen {
  apropiada,
  inapropiada,
  noSePudoValidar,
}

class GeminiService {
  static const String _modelo = 'gemini-2.5-flash';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  /// Analiza una imagen contra contenido inapropiado.
  /// Devuelve `noSePudoValidar` si hay cualquier problema de red, API,
  /// o parseo — nunca asume que la imagen es apropiada en ese caso.
  Future<ResultadoModeracionImagen> analizarImagen(File imagen) async {
  try {
    final bytes = await imagen.readAsBytes();
    final base64Imagen = base64Encode(bytes);

    final url = Uri.parse(
      '$_baseUrl/$_modelo:generateContent?key=${ApiKeys.geminiApiKey}',
    );

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {
              'text':
                  'Analizá esta imagen. Respondé ÚNICAMENTE con la palabra '
                  '"SI" si la imagen contiene contenido explícito, sexual, '
                  'desnudez, violencia gráfica o cualquier contenido '
                  'inapropiado para una aplicación pública de reportes '
                  'urbanos (baches, basura, problemas de luminaria, etc). '
                  'Respondé ÚNICAMENTE con la palabra "NO" si la imagen es '
                  'apropiada, sin importar la calidad o si no se relaciona '
                  'con temas urbanos. No agregues explicación, solo SI o NO.',
            },
            {
              'inline_data': {
                'mime_type': 'image/jpeg',
                'data': base64Imagen,
              },
            },
          ],
        },
      ],
    });

    final respuesta = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );


    if (respuesta.statusCode != 200) {
      return ResultadoModeracionImagen.noSePudoValidar;
    }

    final json = jsonDecode(respuesta.body);
    final texto = json['candidates']?[0]?['content']?['parts']?[0]?['text']
            ?.toString()
            .trim()
            .toUpperCase() ??
        '';

    if (texto.contains('SI')) {
      return ResultadoModeracionImagen.inapropiada;
    }
    if (texto.contains('NO')) {
      return ResultadoModeracionImagen.apropiada;
    }

    return ResultadoModeracionImagen.noSePudoValidar;
  } catch (e) {
      return ResultadoModeracionImagen.noSePudoValidar;
  }
}
}
