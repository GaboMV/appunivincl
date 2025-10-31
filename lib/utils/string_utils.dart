extension StringCleaning on String {
  /// Elimina tildes (acentos) de la cadena de texto.
  String removeAccents() {
    // Patrón de reemplazo (ej: á -> a, é -> e)
    return this
        .replaceAll('á', 'a')
        .replaceAll('Á', 'A')
        .replaceAll('é', 'e')
        .replaceAll('É', 'E')
        .replaceAll('í', 'i')
        .replaceAll('Í', 'I')
        .replaceAll('ó', 'o')
        .replaceAll('Ó', 'O')
        .replaceAll('ú', 'u')
        .replaceAll('Ú', 'U');
    // Opcional, dependiendo de si Ñ debe ser eliminada
  }

  /// Elimina todos los espacios, saltos de línea y tabulaciones.
  String removeAllSpaces() {
    // Usa una expresión regular para eliminar todos los caracteres de espacio
    return replaceAll(RegExp(r'\s+'), '');
  }
}

/// Clase para aplicar las reglas de normalización del sistema.
class AuthNormalizer {
  /// Regla: usuario en minúsculas, sin acentos ni espacios.
  static String normalizeUsername(String input) {
    if (input.isEmpty) return '';
    return input.removeAccents().removeAllSpaces().toLowerCase();
  }

  /// Regla: Contraseña sin espacios, con mayúscula inicial (opcionalmente)
  /// Usaremos solo la eliminación de espacios y tildes para evitar forzar la mayúscula inicial,
  /// lo que podría causar problemas si la contraseña se guarda sin mayúscula inicial.
  ///
  /// Para la comparación, lo más seguro es eliminar tildes y espacios.
  static String normalizePassword(String input) {
    if (input.isEmpty) return '';
    // Dejamos la sensibilidad a mayúsculas/minúsculas intacta, solo limpiamos ruido.
    return input.removeAccents().removeAllSpaces();
  }
}
