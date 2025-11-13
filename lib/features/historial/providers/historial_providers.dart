// lib/features/historial/providers/historial_providers.dart

import 'package:appuniv/database/models/academic_models.dart';
// 🚨 CORREGÍ ESTA RUTA, DEBE APUNTAR AL .g.dart

import 'package:appuniv/database/repositories/repo_provider.dart';
import 'package:appuniv/features/session/providers/session_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// 🚨 ESTA ES LA LÍNEA QUE FALTABA 🚨
// Es la que conecta este archivo con el archivo generado .g.dart
part 'historial_providers.g.dart';

/// Provider que obtiene los semestres donde el estudiante tuvo inscripciones
@Riverpod(keepAlive: true)
Future<List<Semestre>> historialSemestres(HistorialSemestresRef ref) {
  // ... (el resto de tu código está perfecto)
  final estudiante = ref.watch(sessionNotifierProvider).estudiante;
  if (estudiante == null) {
    throw Exception("Usuario no autenticado.");
  }

  final registroRepo = ref.watch(registroRepositoryProvider);
  return registroRepo.getSemestresInscritos(estudiante.id_estudiante);
}

/// Provider que obtiene las materias de UN semestre específico
/// Pasa el idSemestre como argumento
@Riverpod(keepAlive: true)
Future<List<HistorialMateria>> historialMaterias(
  HistorialMateriasRef ref,
  int idSemestre,
) {
  // ... (el resto de tu código está perfecto)
  final estudiante = ref.watch(sessionNotifierProvider).estudiante;
  if (estudiante == null) {
    throw Exception("Usuario no autenticado.");
  }

  final registroRepo = ref.watch(registroRepositoryProvider);
  return registroRepo.getHistorialPorSemestre(
    estudiante.id_estudiante,
    idSemestre,
  );
}
