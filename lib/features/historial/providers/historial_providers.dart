// lib/features/historial/providers/historial_providers.dart
// (¡¡¡LA PUTA VERSIÓN NUEVA CON API Y LOGS!!!)

import 'package:appuniv/services/api_service.dart';
import 'package:appuniv/database/models/academic_models.dart'; // (¡Revisa esta ruta!)
import 'package:appuniv/features/session/providers/session_provider.dart';
import 'package:appuniv/services/socket_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'historial_providers.g.dart';

@Riverpod(keepAlive: true)
Future<List<Semestre>> historialSemestres(HistorialSemestresRef ref) async {
  ref.watch(socketServiceProvider);
  print("HISTORIAL_PROVIDER: Pidiendo semestres...");
  final estudiante = ref.watch(sessionNotifierProvider).estudiante;
  if (estudiante == null) {
    print("HISTORIAL_PROVIDER (ERROR): ¡Puto estudiante nulo!");
    throw Exception("Usuario no autenticado, carajo.");
  }

  final api = ref.watch(apiServiceProvider);
  
  try {
    final List<dynamic> jsonList = await api.getSemestresInscritos(estudiante.id_estudiante);
    print("HISTORIAL_PROVIDER (Semestres): ¡JSON recibido! Parseando ${jsonList.length} semestres.");
    
    // ¡Aquí parseamos, carajo!
    return jsonList.map((json) => Semestre.fromMap(json as Map<String, dynamic>)).toList();
  
  } catch (e) {
    print("HISTORIAL_PROVIDER (Semestres ERROR): ¡La cagó el parseo o la API! $e");
    rethrow;
  }
}

@Riverpod(keepAlive: true)
Future<List<HistorialMateria>> historialMaterias(
  HistorialMateriasRef ref,
  int idSemestre,
) async {
  ref.watch(socketServiceProvider);
  print("HISTORIAL_PROVIDER: Pidiendo materias para semestre $idSemestre...");
  final estudiante = ref.watch(sessionNotifierProvider).estudiante;
  if (estudiante == null) {
    print("HISTORIAL_PROVIDER (ERROR): ¡Puto estudiante nulo!");
    throw Exception("Usuario no autenticado, carajo.");
  }

  final api = ref.watch(apiServiceProvider);

  try {
    final List<dynamic> jsonList = await api.getHistorialPorSemestre(
      estudiante.id_estudiante,
      idSemestre,
    );
    print("HISTORIAL_PROVIDER (Materias): ¡JSON recibido! Parseando ${jsonList.length} materias.");

    // ¡Aquí parseamos, carajo!
    return jsonList.map((json) => HistorialMateria.fromMap(json as Map<String, dynamic>)).toList();
  
  } catch (e) {
    print("HISTORIAL_PROVIDER (Materias ERROR): ¡La cagó el parseo o la API! $e");
    rethrow;
  }
}