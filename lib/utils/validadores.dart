/// Verifica si un texto parece tener sentido (no es texto aleatorio
/// como "akjskalsjlkajsk" ni repetición de sílabas como "jajajaja" o "papapapa").
bool tieneSentido(String texto) {
  final limpio = texto.trim().toLowerCase();
  if (limpio.isEmpty) return false;

  final letras = limpio.replaceAll(RegExp(r'[^a-záéíóúñ]'), '');
  if (letras.isEmpty) return false;

  // 1. Proporción de vocales — un texto real en español ronda 35-55%
  final vocales = letras.replaceAll(RegExp(r'[^aeiouáéíóú]'), '');
  final proporcionVocales = vocales.length / letras.length;
  if (proporcionVocales < 0.25 || proporcionVocales > 0.65) return false;

  // 2. Diversidad de caracteres — texto aleatorio reusa pocas letras
  // en proporción a su longitud total (ej: "jajdjajdjqjjdisjs" usa
  // solo 6 letras distintas en 17 caracteres)
  if (letras.length >= 8) {
    final letrasUnicas = letras.split('').toSet().length;
    final proporcionDiversidad = letrasUnicas / letras.length;
    if (proporcionDiversidad < 0.35) return false;
  }

  // 3. Repetición de un mismo carácter 3+ veces seguidas (ej: "holaaaa")
  if (RegExp(r'(.)\1{2,}').hasMatch(limpio)) return false;

  // 4. Repetición de un bigrama (2 caracteres) 3+ veces seguidas
  // Cubre "papapapa", "jajajaja", "nonono"
  if (RegExp(r'(..)\1{2,}').hasMatch(limpio.replaceAll(' ', ''))) {
    return false;
  }

  // 5. Debe haber al menos una palabra con más de una letra
  final palabras = limpio.split(RegExp(r'\s+'));
  final palabrasValidas = palabras.where((p) => p.length > 1).toList();
  if (palabrasValidas.isEmpty) return false;

  return true;
}