// lib/features/horarios/providers/horarios_provider.dart

import 'package:appuniv/database/repositories/repo_provider.dart';
import 'package:appuniv/features/session/providers/session_provider.dart';
import 'package:appuniv/utils/date_utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'horarios_provider.g.dart'; // Asegúrate que esto coincida

// Mod// lib/features/horarios/providers/horarios_provider.dart


// --- FUNCIONES AUXILIARES PARA EL FORMATO DE HORA ---
String _convertirA12Horas(String hora24) {
  try {
    final partes = hora24.split(':');
    int hora = int.parse(partes[0]);
    final String minutos = partes[1];
    
    final String ampm = hora >= 12 ? 'PM' : 'AM';
    
    if (hora == 0) hora = 12; // 00:xx es 12 AM
    if (hora > 12) hora -= 12;

    // TTS lee "8 y 00 AM" mejor que "8:00 AM"
    // Usamos $minutos aunque sea "00" para evitar ambigüedades.
    return '$hora y $minutos $ampm'; 
  } catch (e) {
    return hora24; 
  }
}

// 🚨 1. MODELO DE DATOS CORREGIDO
// -------------------------------------------------------------------
class _HorarioItem {
  final String dia;
  final String horaInicio;
  final String horaFin;
  final String nombreMateria;
  final String nombreAula;
  final String nombreDocente;
  final String apellidoDocente; // 🚨 ¡NUEVO CAMPO!

  _HorarioItem({
    required this.dia,
    required this.horaInicio,
    required this.horaFin,
    required this.nombreMateria,
    required this.nombreAula,
    required this.nombreDocente,
    required this.apellidoDocente, // 🚨 ¡Añadido aquí!
  });

  factory _HorarioItem.fromMap(Map<String, dynamic> map) {
    return _HorarioItem(
      dia: map['dia'] as String,
      horaInicio: map['hora_inicio'] as String,
      horaFin: map['hora_fin'] as String,
      // Los alias de tu SQL son: materia_nombre, aula_nombre, docente_nombre, docente_apellido
      nombreMateria: map['materia_nombre'] as String,
      nombreAula: map['aula_nombre'] as String,
      nombreDocente: map['docente_nombre'] as String,
      apellidoDocente: map['docente_apellido'] as String, // 🚨 ¡Añadido!
    );
  }

  // 🚨 FUNCIÓN toTtsString CORREGIDA (Usa 12h y Apellido)
  String toTtsString() {
    final horaInicio12h = _convertirA12Horas(horaInicio.substring(0, 5));
    final horaFin12h = _convertirA12Horas(horaFin.substring(0, 5));
    
    // Frase completa con formato 12h y nombre COMPLETO del docente.
    return "De $horaInicio12h a $horaFin12h, ${nombreMateria} en el aula ${nombreAula} con ${nombreDocente} ${apellidoDocente}.";
  }
}

// 🚨 2. PROVIDER
// -------------------------------------------------------------------

@riverpod
Future<Map<String, String>> horarioProcesado(HorarioProcesadoRef ref) async {
  
  final estudiante = ref.watch(sessionNotifierProvider).estudiante;
  if (estudiante == null) {
    throw Exception("No hay sesión de estudiante activa.");
  }

  final repo = ref.watch(registroRepositoryProvider); 
  final nombreSemestreActual = getNombreSemestreActual(); 

  final rawData = await repo.getHorarioEstudiante( 
    estudiante.id,
    nombreSemestreActual,
  );

  final items = rawData.map((map) => _HorarioItem.fromMap(map)).toList();

  final Map<String, String> horarioFinal = {
    'Lunes': 'Sin clases programadas.',
    'Martes': 'Sin clases programadas.',
    'Miércoles': 'Sin clases programadas.',
    'Jueves': 'Sin clases programadas.',
    'Viernes': 'Sin clases programadas.',
    'Sábado': 'Sin clases programadas.',
    'Domingo': 'Sin clases programadas.',
  };

  final Map<String, List<String>> lecturasPorDia = {};

  for (final item in items) {
    // Esto asegura que el item se agregue a la lista del día correcto.
    if (!lecturasPorDia.containsKey(item.dia)) {
      lecturasPorDia[item.dia] = [];
    }
    lecturasPorDia[item.dia]!.add(item.toTtsString());
  }

  horarioFinal.forEach((dia, defaultMsg) {
    // Esta lógica de comparación de días es correcta para manejar acentos
    final diaSinAcento = dia.toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u');
      
    final claveEncontrada = lecturasPorDia.keys.firstWhere(
        (k) => k.toLowerCase() == diaSinAcento,
        orElse: () => '',
    );

    if (claveEncontrada.isNotEmpty) {
      horarioFinal[dia] = lecturasPorDia[claveEncontrada]!.join(' ');
    }
  });

  return horarioFinal;
}