// lib/data/repositories/registro_repository.dart
import 'package:sqflite/sqflite.dart';
import '../models/academic_models.dart';

class RegistroRepository {
  final Database _db;
  RegistroRepository(this._db);

  // ===============================================
  // 1. REQUISITOS
  // ===============================================

  Future<bool> _tieneMateriaAprobada(
    int idEstudiante,
    int idMateriaPrevia,
  ) async {
    final List<Map<String, dynamic>> result = await _db.rawQuery(
      '''
      SELECT I.estado
      FROM Inscripciones AS I
      JOIN Paralelos_Semestre AS PS ON I.id_paralelo = PS.id_paralelo
      WHERE I.id_estudiante = ? AND PS.id_materia = ? AND I.estado = 'Aprobada';
      ''',
      [idEstudiante, idMateriaPrevia],
    );
    return result.isNotEmpty;
  }

  Future<bool> cumpleRequisitosParaMateria(
    int idEstudiante,
    int idMateriaACursar,
  ) async {
    final List<Map<String, dynamic>> requisitos = await _db.query(
      'Requisitos',
      where: 'id_materia_cursar = ?',
      whereArgs: [idMateriaACursar],
    );
    if (requisitos.isEmpty) return true; // No hay requisitos
    for (var req in requisitos) {
      final int idMateriaPrevia = req['id_materia_previa'] as int;
      if (!await _tieneMateriaAprobada(idEstudiante, idMateriaPrevia)) {
        return false;
      }
    }
    return true;
  }

  // ===============================================
  // 2. INSCRIPCIÓN Y RETIRO
  // ===============================================

  Future<int> inscribirEstudiante(int idEstudiante, int idParalelo) async {
    final map = {
      'id_estudiante': idEstudiante,
      'id_paralelo': idParalelo,
      'estado': 'Cursando',
      'fecha_inscripcion': DateTime.now().toIso8601String(),
    };
    return await _db.insert(
      'Inscripciones',
      map,
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  // 🚨 ======================================================
  // 🚨 FIX 1: "RETIRAR" AHORA ES UN DELETE
  // 🚨 (Esto permite inscribirse en otro paralelo)
  // 🚨 ======================================================
  Future<int> retirarMateria(int idEstudiante, int idParalelo) async {
    // En lugar de 'UPDATE', hacemos 'DELETE' para que el
    // estudiante pueda inscribirse en otro paralelo.
    return await _db.delete(
      'Inscripciones',
      where: 'id_estudiante = ? AND id_paralelo = ? AND estado = ?',
      whereArgs: [idEstudiante, idParalelo, 'Cursando'],
    );
  }

  // 🚨 ======================================================
  // 🚨 NUEVAS FUNCIONES DE VALIDACIÓN (FIX 3 y 4)
  // 🚨 ======================================================

  /// Revisa si el estudiante ya está inscrito en otra paralelo DE LA MISMA MATERIA
  Future<bool> isEnrolledInSubject(
    int idEstudiante,
    int idMateria,
    int idSemestreActual,
  ) async {
    final sql = '''
      SELECT I.id_inscripcion
      FROM Inscripciones AS I
      JOIN Paralelos_Semestre AS PS ON I.id_paralelo = PS.id_paralelo
      WHERE I.id_estudiante = ? 
        AND PS.id_materia = ?
        AND PS.id_semestre = ?
        AND I.estado = 'Cursando'
      LIMIT 1;
    ''';
    final result = await _db.rawQuery(sql, [
      idEstudiante,
      idMateria,
      idSemestreActual,
    ]);
    return result.isNotEmpty;
  }

  /// Revisa si hay choque de horario
  Future<bool> checkScheduleConflict(
    int idEstudiante,
    int idParaleloNuevo,
    int idSemestreActual,
  ) async {
    // 1. Obtener los IDs de horario del NUEVO paralelo
    final nuevosHorariosMap = await _db.query(
      'Paralelo_Horario',
      columns: ['id_horario'],
      where: 'id_paralelo = ?',
      whereArgs: [idParaleloNuevo],
    );
    final nuevosHorariosIds =
        nuevosHorariosMap.map((h) => h['id_horario'] as int).toSet();

    if (nuevosHorariosIds.isEmpty)
      return false; // No tiene horario, no puede chocar

    // 2. Obtener los IDs de horario de TODAS las materias YA INSCRITAS
    final sqlInscritos = '''
      SELECT PH.id_horario
      FROM Inscripciones AS I
      JOIN Paralelos_Semestre AS PS ON I.id_paralelo = PS.id_paralelo
      JOIN Paralelo_Horario AS PH ON PS.id_paralelo = PH.id_paralelo
      WHERE I.id_estudiante = ? 
        AND PS.id_semestre = ? 
        AND I.estado = 'Cursando';
    ''';
    final inscritosHorariosMap = await _db.rawQuery(sqlInscritos, [
      idEstudiante,
      idSemestreActual,
    ]);
    final inscritosHorariosIds =
        inscritosHorariosMap.map((h) => h['id_horario'] as int).toSet();

    if (inscritosHorariosIds.isEmpty)
      return false; // No tiene otras materias, no puede chocar

    // 3. Comparar los dos sets
    final intersection = nuevosHorariosIds.intersection(inscritosHorariosIds);
    return intersection.isNotEmpty; // Si hay intersección, hay choque
  }

  // ===============================================
  // 3. HORARIO
  // ===============================================

  Future<List<Map<String, dynamic>>> getHorarioEstudiante(
    int idEstudiante,
    String nombreSemestre,
  ) async {
    // ... (sin cambios)
    final sql = '''
      SELECT 
          H.dia, H.hora_inicio, H.hora_fin, 
          M.nombre AS materia_nombre, 
          A.nombre AS aula_nombre, 
          D.nombre AS docente_nombre,
          D.apellido AS docente_apellido
      FROM Inscripciones AS I
      JOIN Paralelos_Semestre AS PS ON I.id_paralelo = PS.id_paralelo
      JOIN Semestres AS S ON PS.id_semestre = S.id_semestre
      JOIN Materias AS M ON PS.id_materia = M.id_materia
      JOIN Aulas AS A ON PS.id_aula = A.id_aula
      JOIN Docentes AS D ON PS.id_docente = D.id_docente
      JOIN Paralelo_Horario AS PH ON PS.id_paralelo = PH.id_paralelo
      JOIN Horarios AS H ON PH.id_horario = H.id_horario
      WHERE 
          I.id_estudiante = ? AND
          S.nombre = ? AND
          I.estado = 'Cursando';
    ''';
    final List<Map<String, dynamic>> result = await _db.rawQuery(sql, [
      idEstudiante,
      nombreSemestre,
    ]);
    return result;
  }

  // ===============================================
  // 4. HISTORIAL ACADÉMICO
  // ===============================================

  Future<List<Semestre>> getSemestresInscritos(int idEstudiante) async {
    // ... (sin cambios)
    const sql = '''
      SELECT DISTINCT 
        S.id_semestre, S.nombre
      FROM Inscripciones AS I
      JOIN Paralelos_Semestre AS PS ON I.id_paralelo = PS.id_paralelo
      JOIN Semestres AS S ON PS.id_semestre = S.id_semestre
      WHERE I.id_estudiante = ?
      ORDER BY S.nombre DESC; 
    ''';
    final List<Map<String, dynamic>> maps = await _db.rawQuery(sql, [
      idEstudiante,
    ]);
    return maps.map((map) => Semestre.fromMap(map)).toList();
  }

  Future<List<HistorialMateria>> getHistorialPorSemestre(
    int idEstudiante,
    int idSemestre,
  ) async {
    // ... (sin cambios)
    const sql = '''
      SELECT 
        M.nombre AS nombre_materia,
        I.estado, I.parcial1, I.parcial2, I.examen_final, I.segundo_turno
      FROM Inscripciones AS I
      JOIN Paralelos_Semestre AS PS ON I.id_paralelo = PS.id_paralelo
      JOIN Materias AS M ON PS.id_materia = M.id_materia
      WHERE I.id_estudiante = ? AND PS.id_semestre = ?;
    ''';
    final List<Map<String, dynamic>> maps = await _db.rawQuery(sql, [
      idEstudiante,
      idSemestre,
    ]);
    return maps.map((map) => HistorialMateria.fromMap(map)).toList();
  }

  // ===============================================
  // 5. SOLICITUDES
  // ===============================================

  Future<int> enviarSolicitud(
    int idEstudiante,
    int idParalelo,
    String motivo,
  ) async {
    final map = {
      'id_estudiante': idEstudiante,
      'id_paralelo': idParalelo,
      'motivo': motivo,
      'estado': 'En Espera',
      'fecha_solicitud': DateTime.now().toIso8601String(),
    };
    return await _db.insert(
      'Solicitudes_Inscripcion',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> retirarSolicitud(int idEstudiante, int idParalelo) async {
    return await _db.delete(
      'Solicitudes_Inscripcion',
      where: 'id_estudiante = ? AND id_paralelo = ? AND estado = ?',
      whereArgs: [idEstudiante, idParalelo, 'En Espera'],
    );
  }
}
