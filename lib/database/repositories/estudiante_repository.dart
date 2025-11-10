// lib/data/repositories/estudiante_repository.dart
import 'package:sqflite/sqflite.dart';
import '../models/academic_models.dart';

class EstudianteRepository {
  // 🚨 CAMBIO 1: Ya no es un Future. Es la base de datos real.
  final Database _db;

  // 🚨 CAMBIO 2: El constructor acepta la Database.
  EstudianteRepository(this._db);

  Future<void> debugPrintAllStudents() async {
    // 🚨 CAMBIO 3: No más 'await dbFuture'. Usamos _db directamente.
    final List<Map<String, dynamic>> maps = await _db.query('Estudiantes');

    print('==================================================');
    print('DEBUG: Contenido de la tabla Estudiantes:');
    if (maps.isEmpty) {
      print('La tabla está vacía.');
    } else {
      for (var map in maps) {
        print(
          '   Usuario ID: ${map['id_estudiante']}, Usuario: ${map['usuario']}, Contraseña: ${map['contrasena']}',
        );
      }
    }
    print('==================================================');
  }

  // 1. AUTENTICACIÓN
  Future<Estudiante?> authenticate(String usuario, String contrasena) async {
    // 🚨 CAMBIO 4: Usamos _db directamente.
    final List<Map<String, dynamic>> maps = await _db.query(
      'Estudiantes',
      where: 'usuario = ? AND contrasena = ?',
      whereArgs: [usuario, contrasena],
    );

    return maps.isNotEmpty ? Estudiante.fromMap(maps.first) : null;
  }

  // 🚨 CAMBIO 5: Este método ya no necesita recibir 'db' como parámetro.
  Future<void> debugPrintAllTables() async {
    final tables = await _db.query(
      'sqlite_master',
      where: 'type = ?',
      whereArgs: ['table'],
    );

    print('==================================================');
    print('DEBUG: Tablas encontradas:');
    for (var table in tables) {
      print('   - ${table['name']}');
    }
    print('==================================================');
  }

  Future<List<Map<String, dynamic>>> getHorarioSemestre(
    int idEstudiante,
    String nombreSemestre,
  ) async {
    const sql = '''
      SELECT ... 
      '''; // (Tu SQL está bien)
    
    // 🚨 CAMBIO 6: Usamos _db directamente.
    final List<Map<String, dynamic>> result = await _db.rawQuery(
      sql,
      [idEstudiante, nombreSemestre],
    );

    return result;
  }
}