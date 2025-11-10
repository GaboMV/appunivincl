// lib/utils/date_utils.dart

/// Determina el nombre del semestre académico actual basado en la fecha.
String getNombreSemestreActual({DateTime? fecha}) {
  final now = fecha ?? DateTime.now();
  final year = now.year;

  // El formato 'AAAA-X [Nombre]' asegura que coincide con la BD
  // y se puede ordenar cronológicamente.

  if (now.month == 1) return '$year-1 Verano';
  if (now.month >= 2 && now.month <= 6) return '$year-2 Semestre 1';
  if (now.month == 7) return '$year-3 Invierno';

  // Agosto a Diciembre
  return '$year-4 Semestre 2';
}

String limpiarTextoParaTTS(String texto) {
  return texto
      // Numerales (del más grande al más pequeño)
      .replaceAll(' IV', ' 4')
      .replaceAll(' III', ' 3')
      .replaceAll(' II', ' 2')
      .replaceAll(' I', ' 1')
      // Guiones de semestres
      .replaceAll('-', ' ');
}
