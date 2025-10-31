// lib/data/repositories/estudiante_repository.dart
import 'package:sqflite/sqflite.dart';
import '../models/academic_models.dart';

class EstudianteRepository {
  final Future<Database> dbFuture;

  EstudianteRepository(this.dbFuture);

  Future<void> debugPrintAllStudents() async {
    final db = await dbFuture;
    final List<Map<String, dynamic>> maps = await db.query('Estudiantes');

    print('==================================================');
    print('DEBUG: Contenido de la tabla Estudiantes:');
    if (maps.isEmpty) {
      print('La tabla está vacía.');
    } else {
      for (var map in maps) {
        print(
          '  Usuario ID: ${map['id_estudiante']}, Usuario: ${map['usuario']}, Contraseña: ${map['contrasena']}',
        );
      }
    }
    print('==================================================');
  }

  // 1. AUTENTICACIÓN
  Future<Estudiante?> authenticate(String usuario, String contrasena) async {
    final db = await dbFuture;
    final List<Map<String, dynamic>> maps = await db.query(
      'Estudiantes',
      where: 'usuario = ? AND contrasena = ?',
      whereArgs: [usuario, contrasena],
    );

    return maps.isNotEmpty ? Estudiante.fromMap(maps.first) : null;
  }

  Future<void> debugPrintAllTables(Database db) async {
    final tables = await db.query(
      'sqlite_master',
      where: 'type = ?',
      whereArgs: ['table'],
    );

    print('==================================================');
    print('DEBUG: Tablas encontradas:');
    for (var table in tables) {
      print('  - ${table['name']}');
    }
    print('==================================================');
  }
}
