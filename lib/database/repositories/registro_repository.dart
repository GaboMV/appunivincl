// lib/data/repositories/registro_repository.dart
import 'package:sqflite/sqflite.dart';
// 🚨 Asegúrate de que la ruta a tus modelos sea correcta
import '../models/academic_models.dart'; 

class RegistroRepository {
  final Database _db;

  RegistroRepository(this._db);

  // ===============================================
  // 1. REQUISITOS (Tu código original - Perfecto)
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
  // 2. INSCRIPCIÓN Y RETIRO (Tu código original - Perfecto)
  // ===============================================

  Future<int> inscribirEstudiante(int idEstudiante, int idParalelo) async {
    // NOTA: Asumimos que la lógica de 'cumpleRequisitos' 
    // y 'choqueDeHorario' se valida en el Provider (capa de lógica)
    // antes de llamar a este método de repositorio.
    
    final inscripcion = {
      'id_estudiante': idEstudiante,
      'id_paralelo': idParalelo,
      'estado': 'Cursando',
      'fecha_inscripcion': DateTime.now().toIso8601String(),
    };

    return await _db.insert(
      'Inscripciones',
      inscripcion,
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  Future<int> retirarMateria(int idEstudiante, int idParalelo) async {
    return await _db.update(
      'Inscripciones',
      {'estado': 'Retirada'},
      where: 'id_estudiante = ? AND id_paralelo = ? AND estado = ?',
      whereArgs: [idEstudiante, idParalelo, 'Cursando'],
    );
  }

  // ===============================================
  // 3. HORARIO (DEL SEMESTRE ACTUAL) (Tu código original - Perfecto)
  // ===============================================

  Future<List<Map<String, dynamic>>> getHorarioEstudiante(
    int idEstudiante,
    String nombreSemestre,
  ) async {
    final sql = '''
      SELECT 
          H.dia, 
          H.hora_inicio, 
          H.hora_fin, 
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

    // Tus prints de Debug son muy útiles, los mantenemos
    print('======================================================');
    print('DEBUG: Ejecutando getHorarioEstudiante');
    print('Argumentos: [idEstudiante: $idEstudiante, nombreSemestre: $nombreSemestre]');
    print('======================================================');

    try {
      final List<Map<String, dynamic>> result = await _db.rawQuery(
        sql,
        [idEstudiante, nombreSemestre],
      );

      print('DEBUG: Resultado de la consulta SQL (getHorarioEstudiante):');
      if (result.isEmpty) {
        print('-> La consulta devolvió una lista vacía [].');
      } else {
        print('-> La consulta devolvió ${result.length} fila(s):');
        print(result);
      }
      print('============================================================');

      return result;
    } catch (e) {
      print('!!!!!!!!!!!!!! ERROR DE SQL !!!!!!!!!!!!!!');
      print('Error al ejecutar getHorarioEstudiante: $e');
      print('============================================');
      rethrow;
    }
  }

  // ===============================================
  // 4. HISTORIAL ACADÉMICO (🚨 NUEVA SECCIÓN 🚨)
  // ===============================================

  /// 1. Obtiene la lista de semestres únicos en los que un estudiante
  /// ha estado inscrito (historial).
  Future<List<Semestre>> getSemestresInscritos(int idEstudiante) async {
    const sql = '''
      SELECT DISTINCT 
        S.id_semestre, S.nombre
      FROM Inscripciones AS I
      JOIN Paralelos_Semestre AS PS ON I.id_paralelo = PS.id_paralelo
      JOIN Semestres AS S ON PS.id_semestre = S.id_semestre
      WHERE I.id_estudiante = ?
      ORDER BY S.nombre DESC; 
    ''';

    final List<Map<String, dynamic>> maps = await _db.rawQuery(sql, [idEstudiante]);
    return maps.map((map) => Semestre.fromMap(map)).toList();
  }

  /// 2. Obtiene el detalle de materias y notas para un semestre específico.
  /// (Reemplaza tu 'getNotasPorSemestre' para usar el DTO HistorialMateria)
  Future<List<HistorialMateria>> getHistorialPorSemestre(
      int idEstudiante, int idSemestre) async {
        
    const sql = '''
      SELECT 
        M.nombre AS nombre_materia,
        I.estado,
        I.parcial1,
        I.parcial2,
        I.examen_final,
        I.segundo_turno
      FROM Inscripciones AS I
      JOIN Paralelos_Semestre AS PS ON I.id_paralelo = PS.id_paralelo
      JOIN Materias AS M ON PS.id_materia = M.id_materia
      WHERE I.id_estudiante = ? AND PS.id_semestre = ?;
    ''';

    final List<Map<String, dynamic>> maps = await _db.rawQuery(sql, [idEstudiante, idSemestre]);
    // Usamos el nuevo modelo HistorialMateria del Paso 1
    return maps.map((map) => HistorialMateria.fromMap(map)).toList();
  }

  // ===============================================
  // 5. SOLICITUDES (Tu código original - Perfecto)
  // ===============================================

  Future<int> enviarSolicitud(
    int idEstudiante,
    int idParalelo,
    String motivo,
  ) async {
    
    // (Asumimos que el modelo SolicitudInscripcion existe en academic_models.dart)
    // Si no existe, este mapa simple también funciona:
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
}