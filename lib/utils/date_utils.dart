// lib/utils/date_utils.dart

/// Determina el nombre del semestre académico actual basado en la fecha.
String getNombreSemestreActual({DateTime? fecha}) {
  final now = fecha ?? DateTime.now();
  final year = now.year;

  if (now.month == 1) return '$year-1 Verano';
  if (now.month >= 2 && now.month <= 6) return '$year-2 Semestre 1';
  if (now.month == 7) return '$year-3 Invierno';
  return '$year-4 Semestre 2';
}

// 🚨 ======================================================
// 🚨 FUNCIONES DE FORMATO DE HORA (FIX "cero ocho diez")
// 🚨 ======================================================

/// Convierte "17:00" en "5 de la tarde"
String formatarHoraParaTTS(String hora24) {
  try {
    final int hora = int.parse(hora24.split(':').first);

    if (hora < 12) {
      if (hora == 0) return "12 de la medianoche";
      return "$hora de la mañana";
    }
    if (hora == 12) {
      return "12 del mediodía";
    }
    if (hora > 12 && hora < 19) {
      return "${hora - 12} de la tarde";
    }
    // 19:00 en adelante
    return "${hora - 12} de la noche";
  } catch (e) {
    return hora24; // Devuelve el original si falla
  }
}

/// Convierte "Lunes 08:00-10:00, Miércoles 08:00-10:00"
/// en "Lunes de 8 de la mañana a 10 de la mañana, Miércoles..."
String formatarHorariosParaTTS(String horariosRaw) {
  if (horariosRaw.isEmpty) {
    return "Horario no definido";
  }
  try {
    // 1. Separa "Lunes 08:00-10:00" y "Miércoles 08:00-10:00"
    return horariosRaw.split(', ').map((bloque) {
      // 2. Separa "Lunes" y "08:00-10:00"
      final parts = bloque.split(' ');
      final dia = parts[0];
      // 3. Separa "08:00" y "10:00"
      final horas = parts[1].split('-');
      final inicio = formatarHoraParaTTS(horas[0]); // "8 de la mañana"
      final fin = formatarHoraParaTTS(horas[1]); // "10 de la mañana"
      return "$dia de $inicio a $fin";
    }).join(', ');
  } catch (e) {
    return horariosRaw; // Devuelve el original si falla
  }
}

// --- FUNCIONES DE LIMPIEZA ---

extension StringCleaning on String {
  String removeAccents() {
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
  }

  String removeAllSpaces() {
    return replaceAll(RegExp(r'\s+'), '');
  }
}

class AuthNormalizer {
  static String normalizeUsername(String input) {
    if (input.isEmpty) return '';
    return input.removeAccents().removeAllSpaces().toLowerCase();
  }

  static String normalizePassword(String input) {
    if (input.isEmpty) return '';
    return input.removeAccents().removeAllSpaces();
  }
}

/// Limpia un texto para que el motor TTS lo lea de forma natural.
String limpiarTextoParaTTS(String texto) {
  String textoLimpio = texto
      // Numerales
      .replaceAll(' IV', ' 4')
      .replaceAll(' III', ' 3')
      .replaceAll(' II', ' 2')
      .replaceAll(' I', ' 1')
      // Guiones
      .replaceAll('-', ' ');
  
  // Reemplaza "N/A" (del modelo de historial) por "sin nota"
  textoLimpio = textoLimpio.replaceAll('N/A', 'sin nota');

  return textoLimpio;
}

/// Normaliza la entrada de voz para que coincida con la BD.
String normalizarQueryBusqueda(String query) {
  final queryCapitalized = query.split(' ').map((word) {
    if (word.isEmpty) return '';
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');

  return queryCapitalized
      .replaceAll(' 4', ' IV')
      .replaceAll(' 3', ' III')
      .replaceAll(' 2', ' II')
      .replaceAll(' 1', ' I');
}