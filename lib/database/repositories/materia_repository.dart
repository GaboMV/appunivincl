// lib/data/repositories/materia_repository.dart
import 'package:sqflite/sqflite.dart';
import '../models/academic_models.dart';

class MateriaRepository {
  final Future<Database> dbFuture;

  MateriaRepository(this.dbFuture);

  // 1. OBTENER FACULTADES (Para el filtro inicial)
  Future<List<Facultad>> getAllFacultades() async {
    final db = await dbFuture;
    final List<Map<String, dynamic>> maps = await db.query('Facultades');
    return maps.map((map) => Facultad.fromMap(map)).toList();
  }

  // 2. BÚSQUEDA POR NOMBRE O CÓDIGO
  Future<List<Materia>> searchMaterias(String query) async {
    final db = await dbFuture;
    final List<Map<String, dynamic>> maps = await db.query(
      'Materias',
      where: 'nombre LIKE ? OR codigo LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return maps.map((map) => Materia.fromMap(map)).toList();
  }

  // 3. BÚSQUEDA POR FACULTAD
  Future<List<Materia>> getMateriasByFacultad(int idFacultad) async {
    final db = await dbFuture;
    final List<Map<String, dynamic>> maps = await db.query(
      'Materias',
      where: 'id_facultad = ?',
      whereArgs: [idFacultad],
    );
    return maps.map((map) => Materia.fromMap(map)).toList();
  }

  // 4. OBTENER PARALELOS OFERTADOS para una Materia en un Semestre (Necesario para inscribirse)
  Future<List<Map<String, dynamic>>> getParalelosOfertados(
    int idMateria,
    int idSemestre,
  ) async {
    final db = await dbFuture;

    // Consulta JOIN para obtener el paralelo, docente y aula
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

    return await db.rawQuery(sql, [idMateria, idSemestre]);
  }
}
