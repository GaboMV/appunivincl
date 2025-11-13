// lib/features/inscripciones/providers/inscripcion_providers.dart

// 🚨 CORRECCIÓN DE TIPEO AQUÍ
import 'package:appuniv/database/database_providers.dart';
import 'package:appuniv/database/models/academic_models.dart';
import 'package:appuniv/database/repositories/registro_repository.dart';
import 'package:appuniv/database/repositories/repo_provider.dart';
import 'package:appuniv/features/historial/providers/historial_providers.dart';
import 'package:appuniv/features/horarios/providers/horarios_provider.dart';
import 'package:appuniv/features/session/providers/session_provider.dart';
// 🚨 CORRECCIÓN DE TIPEO AQUÍ
import 'package:appuniv/utils/date_utils.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart'; // Necesario para la consulta de semestre

part 'inscripcion_providers.g.dart';

// lib/features
// (Facultades, MateriasPorFacultad, MateriasPorBusqueda, ParalelosMateria... 
// ...todos estos se quedan exactamente igual que antes)

@Riverpod(keepAlive: true)
Future<List<Facultad>> facultades(FacultadesRef ref) {
  final materiaRepo = ref.watch(materiaRepositoryProvider);
  return materiaRepo.getAllFacultades();
}

@Riverpod(keepAlive: true)
Future<List<Materia>> materiasPorFacultad(
    MateriasPorFacultadRef ref, int idFacultad) {
  final materiaRepo = ref.watch(materiaRepositoryProvider);
  return materiaRepo.getMateriasByFacultad(idFacultad);
}

@Riverpod(keepAlive: true)
Future<List<Materia>> materiasPorBusqueda(
    MateriasPorBusquedaRef ref, String query) {
  if (query.trim().isEmpty) {
    return Future.value([]);
  }
  final materiaRepo = ref.watch(materiaRepositoryProvider);
  return materiaRepo.searchMaterias(query);
}

@Riverpod(keepAlive: true)
Future<List<ParaleloDetalleCompleto>> paralelosMateria(
    ParalelosMateriaRef ref, int idMateria) async {
      
  final materiaRepo = ref.watch(materiaRepositoryProvider);
  final registroRepo = ref.watch(registroRepositoryProvider);
  final estudiante = ref.read(sessionNotifierProvider).estudiante;
  final db = await ref.read(databaseInstanceProvider.future);
  
  if (estudiante == null) throw Exception("No autenticado");
  final idEstudiante = estudiante.id_estudiante;

  final nombreSemestreActual = getNombreSemestreActual();
  final semestreMap = await db.query('Semestres',
      where: 'nombre = ?', whereArgs: [nombreSemestreActual], limit: 1);
  if (semestreMap.isEmpty) {
    throw Exception("Semestre actual $nombreSemestreActual no encontrado.");
  }
  final idSemestreActual = semestreMap.first['id_semestre'] as int;

  final results = await Future.wait([
    materiaRepo.getRequisitosString(idMateria),
    registroRepo.cumpleRequisitosParaMateria(idEstudiante, idMateria),
  ]);
  final String requisitos = results[0] as String;
  final bool cumpleReq = results[1] as bool;

  final paralelosSimples = await materiaRepo.getParalelosConEstado(
    idEstudiante: idEstudiante,
    idMateria: idMateria,
    idSemestreActual: idSemestreActual,
  );

  final List<ParaleloDetalleCompleto> paralelosCompletos =
      await Future.wait(paralelosSimples.map((paraleloSimple) async {
    final horarios =
        await materiaRepo.getHorariosString(paraleloSimple.idParalelo);
    return ParaleloDetalleCompleto(
      paralelo: paraleloSimple,
      horarios: horarios,
      requisitos: requisitos,
      cumpleRequisitos: cumpleReq,
    );
  }));

  return paralelosCompletos;
}


// --- PROVEEDOR DE LÓGICA (escritura) ---

@Riverpod(keepAlive: true)
class InscripcionService extends _$InscripcionService {
  @override
  void build() {}

  (Estudiante, RegistroRepository) _getDependencies() {
    final estudiante = ref.read(sessionNotifierProvider).estudiante;
    if (estudiante == null) throw Exception("Usuario no autenticado");
    final registroRepo = ref.read(registroRepositoryProvider);
    return (estudiante, registroRepo);
  }
  
  Future<(int, Database)> _getSemestreActualId() async {
    final db = await ref.read(databaseInstanceProvider.future);
    final nombreSemestreActual = getNombreSemestreActual();
    final semestreMap = await db.query('Semestres',
        where: 'nombre = ?', whereArgs: [nombreSemestreActual], limit: 1);
    if (semestreMap.isEmpty) {
      throw Exception("Semestre actual $nombreSemestreActual no encontrado.");
    }
    return (semestreMap.first['id_semestre'] as int, db);
  }

  void _invalidateExternalCaches(int idMateria) {
    ref.invalidate(paralelosMateriaProvider(idMateria));
    ref.invalidate(historialSemestresProvider);
    ref.invalidate(historialMateriasProvider); 
    
    // 🚨 ======================================================
    // 🚨 FIX: Invalidar el provider PÚBLICO
    // 🚨 ======================================================
    ref.invalidate(horarioEstudianteProvider); 
    
    debugPrint("LOG: Caches de Historial, Paralelos y Horarios invalidadas.");
  }

  Future<String> inscribirOsolicitar(ParaleloDetalleCompleto paralelo) async {
    final (estudiante, registroRepo) = _getDependencies();
    final idEstudiante = estudiante.id_estudiante;
    final idParalelo = paralelo.idParalelo;

    debugPrint("--- 🟢 ACCIÓN DE INSCRIPCIÓN ---");

    // --- ACCIÓN 1: RETIRAR MATERIA ---
    if (paralelo.estadoEstudiante == EstadoInscripcionParalelo.inscrito) {
      debugPrint("LOG: Intentando retirar materia...");
      await registroRepo.retirarMateria(idEstudiante, idParalelo);
      debugPrint("LOG: ✅ ÉXITO: Materia retirada");
      _invalidateExternalCaches(paralelo.idMateria);
      return "Materia retirada exitosamente.";
    }
    
    // --- ACCIÓN 2: CANCELAR SOLICITUD ---
    if (paralelo.estadoEstudiante == EstadoInscripcionParalelo.solicitado) {
      debugPrint("LOG: Intentando retirar solicitud...");
      await registroRepo.retirarSolicitud(idEstudiante, idParalelo);
      debugPrint("LOG: ✅ ÉXITO: Solicitud retirada");
      _invalidateExternalCaches(paralelo.idMateria);
      return "Solicitud cancelada.";
    }

    // --- ACCIÓN 3: INSCRIBIR O SOLICITAR ---
    if (paralelo.estadoEstudiante == EstadoInscripcionParalelo.ninguno) {
      
      final (idSemestreActual, _) = await _getSemestreActualId();

      // VALIDACIÓN 1: DUPLICADO DE MATERIA
      final bool yaInscrito = await registroRepo.isEnrolledInSubject(
          idEstudiante, paralelo.idMateria, idSemestreActual);
      if (yaInscrito) {
        debugPrint("LOG: ❌ ERROR: Ya inscrito en esta materia.");
        return "Error. Ya estás inscrito en esta materia en otro paralelo. Retira la materia original para inscribirte en este.";
      }

      // VALIDACIÓN 2: REQUISITOS
      if (paralelo.cumpleRequisitos) {
        
        // VALIDACIÓN 3: CHOQUE DE HORARIO
        final bool hayChoque = await registroRepo.checkScheduleConflict(
            idEstudiante, idParalelo, idSemestreActual);

        if (hayChoque) {
          // HAY CHOQUE -> FORZAR SOLICITUD
          debugPrint("LOG: Cumple requisitos, pero hay CHOQUE. Forzando solicitud...");
          try {
            await registroRepo.enviarSolicitud(
                idEstudiante, idParalelo, "Choque de horario");
            debugPrint("LOG: ✅ ÉXITO: Solicitud enviada (por choque)");
            _invalidateExternalCaches(paralelo.idMateria);
            return "No puedes inscribirte directamente por choque de horario. Se envió una solicitud.";
          } catch (e) {
            debugPrint("LOG: ❌ ERROR Solicitud: ${e.toString()}");
            return "Error al enviar la solicitud: ${e.toString()}";
          }
        } else {
          // NO HAY CHOQUE -> INSCRIBIR DIRECTO
          debugPrint("LOG: Cumple requisitos y no hay choque. Intentando inscribir...");
          try {
            await registroRepo.inscribirEstudiante(idEstudiante, idParalelo);
            debugPrint("LOG: ✅ ÉXITO: Inscripción directa");
            _invalidateExternalCaches(paralelo.idMateria);
            return "Inscripción exitosa.";
          } catch (e) {
            debugPrint("LOG: ❌ ERROR Inscripción: ${e.toString()}");
            return "Error al inscribir: ${e.toString()}";
          }
        }
      } else {
        // NO CUMPLE REQUISITOS -> SOLICITAR
        debugPrint("LOG: No cumple requisitos. Intentando enviar solicitud...");
        try {
          await registroRepo.enviarSolicitud(
              idEstudiante, idParalelo, "No cumple requisitos");
          debugPrint("LOG: ✅ ÉXITO: Solicitud enviada (por requisitos)");
          _invalidateExternalCaches(paralelo.idMateria);
          return "No cumples los requisitos. Se envió una solicitud de inscripción.";
        } catch (e) {
          debugPrint("LOG: ❌ ERROR Solicitud: ${e.toString()}");
          return "Error al enviar la solicitud: ${e.toString()}";
        }
      }
    }
    
    return "No se puede realizar la acción.";
  }
}