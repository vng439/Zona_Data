/// Lista básica de palabras prohibidas en español. No pretende ser
/// exhaustiva, cubre los casos más comunes de insultos y lenguaje
/// discriminatorio para un primer nivel de moderación.
const List<String> _palabrasProhibidas = [
  // Insultos comunes
  'pelotudo', 'pelotuda', 'boludo', 'boluda', 'idiota', 'imbecil',
  'estupido', 'estupida', 'tarado', 'tarada', 'gil', 'gila',
  'pendejo', 'pendeja', 'forro', 'forra', 'maricon', 'puto', 'puta',
  'mierda', 'mrd', 'concha', 'pija', 'verga', 'culiao', 'culiado',
  'hijodeputa', 'hdp', 'conchadetumadre', 'ctm',

  // Lenguaje discriminatorio
  'negro de mierda', 'sudaca', 'bolita', 'cabecita',
  'travesti de mierda', 'puto de mierda',
];

/// Normaliza un texto: minúsculas, sin tildes, sin signos de puntuación.
String _normalizar(String texto) {
  var resultado = texto.toLowerCase();
  const tildes = {
    'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u', 'ñ': 'n',
  };
  tildes.forEach((tilde, letra) {
    resultado = resultado.replaceAll(tilde, letra);
  });
  resultado = resultado.replaceAll(RegExp(r'[^\w\s]'), '');
  return resultado;
}

/// Verifica si el texto contiene alguna palabra prohibida como término
/// completo (no como parte de otra palabra válida).
bool contieneLenguajeInapropiado(String texto) {
  final normalizado = _normalizar(texto);
  final palabras = normalizado.split(RegExp(r'\s+'));

  for (final prohibida in _palabrasProhibidas) {
    if (prohibida.contains(' ')) {
      // Frase compuesta: verificar si el texto completo la contiene
      if (normalizado.contains(prohibida)) return true;
    } else {
      // Palabra simple: verificar coincidencia exacta de alguna palabra
      if (palabras.contains(prohibida)) return true;
    }
  }

  return false;
}