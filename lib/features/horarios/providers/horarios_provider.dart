// lib/features/horarios/providers/horarios_provider.dart
// (¡¡¡LA PUTA VERSIÓN NUEVA CON API Y LOGS!!!)

import 'package:appuniv/features/notificaiones/providers/notificaciones_provider.dart';
import 'package:appuniv/services/api_service.dart'; 
import 'package:appuniv/features/session/providers/session_provider.dart';
import 'package:appuniv/utils/date_utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'horarios_provider.g.dart';

@Riverpod(keepAlive: true)
Future<List<Map<String, dynamic>>> horarioEstudiante(HorarioEstudianteRef ref) async { 
  ref.watch(socketTriggerProvider);
  print("HORARIOS_PROVIDER: Pidiendo horario...");
  final estudiante = ref.watch(sessionNotifierProvider).estudiante;
  final nombreSemestre = getNombreSemestreActual();

  if (estudiante == null) {
    print("HORARIOS_PROVIDER (ERROR): ¡Estudiante nulo!");
    throw Exception("No autenticado");
  }

  final apiService = ref.watch(apiServiceProvider);
  
  try {
    final List<dynamic> jsonList = await apiService.getHorarioEstudiante(
      estudiante.id_estudiante
    );
    print("HORARIOS_PROVIDER: ¡JSON recibido! Parseando ${jsonList.length} entradas de horario.");

    // ¡¡¡EL PUTO CAST, CARAJO!!!
    return jsonList.cast<Map<String, dynamic>>();
  
  } catch (e) {
    print("Error en horarios $e");
    rethrow;
  }
}

// ¡Este provider de mierda se queda igual, pero ahora recibirá los logs del de arriba!
@Riverpod(keepAlive: true)
Future<Map<String, String>> horarioProcesado(HorarioProcesadoRef ref) async {
  ref.watch(socketTriggerProvider);
  print("HORARIOS_PROVIDER (Procesado): Esperando datos crudos...");
  final horarioList = await ref.watch(horarioEstudianteProvider.future);
  print("HORARIOS_PROVIDER (Procesado): ¡Datos recibidos! Procesando ${horarioList.length} items.");

  final dias = [
    'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo',
  ];
  final Map<String, String> horarioFinal = {};
  final Map<String, List<String>> tempMap = {for (var dia in dias) dia: []};

  for (final item in horarioList) {
    final dia = item['dia'] as String;
    final horaInicioTTS = formatarHoraParaTTS(item['hora_inicio'] as String);
    final horaFinTTS = formatarHoraParaTTS(item['hora_fin'] as String);
    final lectura =
        "${item['materia_nombre']} de $horaInicioTTS a $horaFinTTS, "
        "en ${item['aula_nombre']} con ${item['docente_nombre']} ${item['docente_apellido']}";
    if (tempMap.containsKey(dia)) {
      tempMap[dia]!.add(lectura);
    }
  }
  for (final dia in dias) {
    final clases = tempMap[dia]!;
    if (clases.isEmpty) {
      horarioFinal[dia] = "Sin clases programadas.";
    } else {
      horarioFinal[dia] = clases.join('. Luego... ');
    }
  }
  print("HORARIOS_PROVIDER (Procesado): ¡Horario procesado!");
  return horarioFinal;
}