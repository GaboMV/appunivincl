// lib/data/repositories/registro_repository.dart
import 'package:sqflite/sqflite.dart';
import '../models/academic_models.dart';

class RegistroRepository {
  final Future<Database> dbFuture;

  RegistroRepository(this.dbFuture);

  // ===============================================
  // 1. REQUISITOS
  // ===============================================

  // Verifica si el estudiante tiene APROBADA la materia previa
  Future<bool> _tieneMateriaAprobada(
    int idEstudiante,
    int idMateriaPrevia,
  ) async {
    final db = await dbFuture;

    // Busca en las inscripciones del estudiante si ha APROBADO la materia previa
    final List<Map<String, dynamic>> result = await db.rawQuery(
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

  // Verifica si el estudiante cumple TODOS los requisitos
  Future<bool> cumpleRequisitosParaMateria(
    int idEstudiante,
    int idMateriaACursar,
  ) async {
    final db = await dbFuture;

    // 1. Obtener todas las materias requeridas
    final List<Map<String, dynamic>> requisitos = await db.query(
      'Requisitos',
      where: 'id_materia_cursar = ?',
      whereArgs: [idMateriaACursar],
    );

    if (requisitos.isEmpty) return true; // No hay requisitos

    // 2. Verificar cada requisito
    for (var req in requisitos) {
      final int idMateriaPrevia = req['id_materia_previa'] as int;
      if (!await _tieneMateriaAprobada(idEstudiante, idMateriaPrevia)) {
        return false; // Si falta un requisito, retorna falso inmediatamente
      }
    }
    return true; // Cumple con todos
  }

  // ===============================================
  // 2. INSCRIPCIÓN Y RETIRO
  // ===============================================

  // Inscribir al estudiante a un paralelo (asume que los requisitos ya se verificaron)
  Future<int> inscribirEstudiante(int idEstudiante, int idParalelo) async {
    final db = await dbFuture;
    final inscripcion = Inscripcion(
      id: 0, // ID 0 para auto-incremento
      idEstudiante: idEstudiante,
      idParalelo: idParalelo,
      estado: 'Cursando',
    );

    // El toMap solo incluye los campos NO nulos para la inserción inicial
    final map = inscripcion.toMap();
    map['fecha_inscripcion'] = DateTime.now().toIso8601String();

    return await db.insert(
      'Inscripciones',
      map,
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  // Retirar materia
  Future<int> retirarMateria(int idEstudiante, int idParalelo) async {
    final db = await dbFuture;
    return await db.update(
      'Inscripciones',
      {'estado': 'Retirada'},
      where: 'id_estudiante = ? AND id_paralelo = ? AND estado = ?',
      whereArgs: [idEstudiante, idParalelo, 'Cursando'],
    );
  }

  // ===============================================
  // 3. HORARIO (DEL SEMESTRE ACTUAL)
  // ===============================================

  Future<List<Map<String, dynamic>>> getHorarioEstudiante(
    int idEstudiante,
    String nombreSemestre,
  ) async {
    final db = await dbFuture;

    final sql = '''
      SELECT 
          M.nombre AS materia_nombre, 
          PS.nombre_paralelo, 
          D.nombre AS docente_nombre, 
          A.nombre AS aula_nombre,
          H.dia, 
          H.hora_inicio, 
          H.hora_fin
      FROM Inscripciones AS I
      JOIN Paralelos_Semestre AS PS ON I.id_paralelo = PS.id_paralelo
      JOIN Semestres AS S ON PS.id_semestre = S.id_semestre
      JOIN Materias AS M ON PS.id_materia = M.id_materia
      JOIN Docentes AS D ON PS.id_docente = D.id_docente
      LEFT JOIN Aulas AS A ON PS.id_aula = A.id_aula
      JOIN Paralelo_Horario AS PH ON PS.id_paralelo = PH.id_paralelo
      JOIN Horarios AS H ON PH.id_horario = H.id_horario
      WHERE I.id_estudiante = ? AND S.nombre = ? AND I.estado = 'Cursando'
      ORDER BY H.dia, H.hora_inicio;
    ''';

    return await db.rawQuery(sql, [idEstudiante, nombreSemestre]);
  }

  // ===============================================
  // 4. NOTAS
  // ===============================================

  // Obtener notas filtradas por semestre
  Future<List<Map<String, dynamic>>> getNotasPorSemestre(
    int idEstudiante,
    String nombreSemestre,
  ) async {
    final db = await dbFuture;

    final sql = '''
      SELECT 
          M.nombre AS materia_nombre, 
          PS.nombre_paralelo, 
          I.parcial1, 
          I.parcial2, 
          I.examen_final, 
          I.segundo_turno,
          I.estado AS estado_final
      FROM Inscripciones AS I
      JOIN Paralelos_Semestre AS PS ON I.id_paralelo = PS.id_paralelo
      JOIN Semestres AS S ON PS.id_semestre = S.id_semestre
      JOIN Materias AS M ON PS.id_materia = M.id_materia
      WHERE I.id_estudiante = ? AND S.nombre = ?;
    ''';

    return await db.rawQuery(sql, [idEstudiante, nombreSemestre]);
  }

  // ===============================================
  // 5. SOLICITUDES
  // ===============================================

  // Enviar una solicitud
  Future<int> enviarSolicitud(
    int idEstudiante,
    int idParalelo,
    String motivo,
  ) async {
    final db = await dbFuture;
    final solicitud = SolicitudInscripcion(
      id: 0,
      idEstudiante: idEstudiante,
      idParalelo: idParalelo,
      motivo: motivo,
      estado: 'En Espera', // Estado inicial
    );

    final map = solicitud.toMap();
    map['fecha_solicitud'] = DateTime.now().toIso8601String();

    return await db.insert(
      'Solicitudes_Inscripcion',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
