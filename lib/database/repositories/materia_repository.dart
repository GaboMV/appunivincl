// lib/data/repositories/materia_repository.dart
import 'package:appuniv/database/models/academic_models.dart';
import 'package:sqflite/sqflite.dart';

class MateriaRepository {
  final Database _db;
  MateriaRepository(this._db);

  /// 1. OBTENER FACULTADES
  Future<List<Facultad>> getAllFacultades() async {
    final List<Map<String, dynamic>> maps = await _db.query('Facultades');
    return maps.map((map) => Facultad.fromMap(map)).toList();
  }

  /// 2. BÚSQUEDA POR NOMBRE O CÓDIGO
  Future<List<Materia>> searchMaterias(String query) async {
    final List<Map<String, dynamic>> maps = await _db.query(
      'Materias',
      where: 'nombre LIKE ? OR codigo LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return maps.map((map) => Materia.fromMap(map)).toList();
  }

  /// 3. BÚSQUEDA POR FACULTAD
  Future<List<Materia>> getMateriasByFacultad(int idFacultad) async {
    final List<Map<String, dynamic>> maps = await _db.query(
      'Materias',
      where: 'id_facultad = ?',
      whereArgs: [idFacultad],
    );
    return maps.map((map) => Materia.fromMap(map)).toList();
  }

  /// 4. OBTENER MATERIA POR ID
  Future<Materia> getMateriaById(int idMateria) async {
    final List<Map<String, dynamic>> maps = await _db.query(
      'Materias',
      where: 'id_materia = ?',
      whereArgs: [idMateria],
      limit: 1,
    );
    if (maps.isEmpty) {
      throw Exception("Materia no encontrada");
    }
    return Materia.fromMap(maps.first);
  }

  // 🚨 ======================================================
  // 🚨 CAMBIO AQUÍ (FIX 1: Preparación para el formato de hora)
  // 🚨 ======================================================
  /// 5. OBTENER HORARIOS COMO STRING (Formato completo, sin abreviar)
  Future<String> getHorariosString(int idParalelo) async {
    final sql = '''
      SELECT H.dia, H.hora_inicio, H.hora_fin
      FROM Paralelo_Horario AS PH
      JOIN Horarios AS H ON PH.id_horario = H.id_horario
      WHERE PH.id_paralelo = ?
      ORDER BY H.dia; 
    ''';
    final List<Map<String, dynamic>> maps = await _db.rawQuery(sql, [
      idParalelo,
    ]);
    if (maps.isEmpty) {
      return ""; // Devuelve vacío, no "Horario no definido"
    }

    // Devuelve el formato "Lunes 08:00-10:00, Miércoles 08:00-10:00"
    return maps
        .map((h) {
          final dia = h['dia'].toString(); // "Lunes"
          final inicio = h['hora_inicio'] as String; // "08:00"
          final fin = h['hora_fin'] as String; // "10:00"
          return "$dia $inicio-$fin";
        })
        .join(', ');
  }

  /// 6. OBTENER REQUISITOS COMO STRING
  Future<String> getRequisitosString(int idMateria) async {
    final sql = '''
      SELECT M.nombre
      FROM Requisitos AS R
      JOIN Materias AS M ON R.id_materia_previa = M.id_materia
      WHERE R.id_materia_cursar = ?;
    ''';
    final List<Map<String, dynamic>> maps = await _db.rawQuery(sql, [
      idMateria,
    ]);
    if (maps.isEmpty) {
      return "";
    }
    final nombres = maps.map((m) => m['nombre'] as String).join(', ');
    return "Requiere: $nombres";
  }

  /// 7. OBTENER PARALELOS CON ESTADO
  Future<List<ParaleloSimple>> getParalelosConEstado({
    required int idEstudiante,
    required int idMateria,
    required int idSemestreActual,
  }) async {
    final sql = '''
      SELECT 
        PS.id_paralelo, PS.nombre_paralelo, PS.id_materia,
        D.nombre AS docente_nombre, D.apellido AS docente_apellido,
        A.nombre AS aula_nombre,
        M.creditos,
        I.estado AS estado_inscripcion,
        SOL.estado AS estado_solicitud
      FROM Paralelos_Semestre AS PS
      JOIN Docentes AS D ON PS.id_docente = D.id_docente
      JOIN Materias AS M ON PS.id_materia = M.id_materia
      LEFT JOIN Aulas AS A ON PS.id_aula = A.id_aula
      LEFT JOIN Inscripciones AS I 
        ON PS.id_paralelo = I.id_paralelo AND I.id_estudiante = ?
      LEFT JOIN Solicitudes_Inscripcion AS SOL
        ON PS.id_paralelo = SOL.id_paralelo AND SOL.id_estudiante = ?
      WHERE 
        PS.id_materia = ? AND PS.id_semestre = ?;
    ''';

    final List<Map<String, dynamic>> maps = await _db.rawQuery(sql, [
      idEstudiante,
      idEstudiante,
      idMateria,
      idSemestreActual,
    ]);

    return maps.map((map) => ParaleloSimple.fromMap(map)).toList();
  }
}
