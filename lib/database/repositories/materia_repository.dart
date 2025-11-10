// lib/data/repositories/materia_repository.dart
import 'package:sqflite/sqflite.dart';
import '../models/academic_models.dart';

class MateriaRepository {
  // 🚨 CAMBIO 1: Recibe la BD real, no el Future
  final Database _db;

  // 🚨 CAMBIO 2: Constructor actualizado
  MateriaRepository(this._db);

  // 1. OBTENER FACULTADES
  Future<List<Facultad>> getAllFacultades() async {
    // 🚨 CAMBIO 3: Usamos _db directamente (no más 'await dbFuture')
    final List<Map<String, dynamic>> maps = await _db.query('Facultades');
    return maps.map((map) => Facultad.fromMap(map)).toList();
  }

  // 2. BÚSQUEDA POR NOMBRE O CÓDIGO
  Future<List<Materia>> searchMaterias(String query) async {
    final List<Map<String, dynamic>> maps = await _db.query(
      'Materias',
      where: 'nombre LIKE ? OR codigo LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return maps.map((map) => Materia.fromMap(map)).toList();
  }

  // 3. BÚSQUEDA POR FACULTAD
  Future<List<Materia>> getMateriasByFacultad(int idFacultad) async {
    final List<Map<String, dynamic>> maps = await _db.query(
      'Materias',
      where: 'id_facultad = ?',
      whereArgs: [idFacultad],
    );
    return maps.map((map) => Materia.fromMap(map)).toList();
  }

  // 4. OBTENER PARALELOS OFERTADOS
  Future<List<Map<String, dynamic>>> getParalelosOfertados(
    int idMateria,
    int idSemestre,
  ) async {
    // La consulta JOIN está perfecta
    final sql = '''
      SELECT 
          PS.id_paralelo, PS.nombre_paralelo, 
          D.nombre AS docente_nombre, D.apellido AS docente_apellido,
          A.nombre AS aula_nombre
      FROM Paralelos_Semestre AS PS
      JOIN Docentes AS D ON PS.id_docente = D.id_docente
      LEFT JOIN Aulas AS A ON PS.id_aula = A.id_aula 
      WHERE PS.id_materia = ? AND PS.id_semestre = ?;
    ''';

    // 🚨 CAMBIO 4: Usamos _db directamente
    return await _db.rawQuery(sql, [idMateria, idSemestre]);
  }
}