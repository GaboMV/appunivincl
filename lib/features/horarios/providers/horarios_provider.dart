// lib/features/horarios/providers/horarios_provider.dart
import 'package:appuniv/database/repositories/repo_provider.dart';
import 'package:appuniv/features/session/providers/session_provider.dart';
import 'package:appuniv/utils/date_utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'horarios_provider.g.dart';

// 🚨 ======================================================
// 🚨 1. RENOMBRADO A PÚBLICO (sin guion bajo)
// 🚨 ======================================================
@Riverpod(keepAlive: true)
Future<List<Map<String, dynamic>>> horarioEstudiante(HorarioEstudianteRef ref) {
  final estudiante = ref.watch(sessionNotifierProvider).estudiante;
  final nombreSemestre = getNombreSemestreActual();

  if (estudiante == null) throw Exception("No autenticado");

  final registroRepo = ref.watch(registroRepositoryProvider);
  return registroRepo.getHorarioEstudiante(
    estudiante.id_estudiante,
    nombreSemestre,
  );
}

// Provider 2: Datos procesados para la UI
@Riverpod(keepAlive: true)
Future<Map<String, String>> horarioProcesado(HorarioProcesadoRef ref) async {
  // 🚨 2. AHORA USA EL PROVIDER PÚBLICO
  final horarioList = await ref.watch(horarioEstudianteProvider.future);

  final dias = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
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

  return horarioFinal;
}
