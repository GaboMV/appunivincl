// lib/data/database/database_service.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
// 🚨 Necesitas importar tus modelos aquí para crear objetos de prueba.

// Asume que la ruta es correcta.

class DatabaseService {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<String> get fullPath async {
    final name = 'academic_records.db';
    final path = await getDatabasesPath();
    return join(path, name);
  }

  Future<Database> _initDatabase() async {
    final path = await fullPath;

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate, // Llama a onCreate solo si la BD no existe
      // ⚠️ Si quieres resetear la BD para probar onCreate de nuevo, usa onDowngrade: deleteDatabase
      // onDowngrade: deleteDatabase,
      singleInstance: true,
    );
  }

  // Ejecuta todo el código SQL para crear las tablas
  Future<void> _onCreate(Database db, int version) async {
    final createTableQueries = [
      // 1. ESTRUCTURAS BÁSICAS
      '''CREATE TABLE Estudiantes (id_estudiante INTEGER PRIMARY KEY, usuario TEXT NOT NULL UNIQUE, contrasena TEXT NOT NULL, nombre TEXT NOT NULL, apellido TEXT NOT NULL);''',
      '''CREATE TABLE Docentes (id_docente INTEGER PRIMARY KEY, nombre TEXT NOT NULL, apellido TEXT NOT NULL);''',
      '''CREATE TABLE Semestres (id_semestre INTEGER PRIMARY KEY, nombre TEXT NOT NULL UNIQUE);''',
      '''CREATE TABLE Facultades (id_facultad INTEGER PRIMARY KEY, nombre TEXT NOT NULL UNIQUE);''',
      '''CREATE TABLE Aulas (id_aula INTEGER PRIMARY KEY, nombre TEXT NOT NULL UNIQUE);''',

      // 2. MATERIAS Y REQUISITOS
      '''CREATE TABLE Materias (id_materia INTEGER PRIMARY KEY, codigo TEXT NOT NULL UNIQUE, nombre TEXT NOT NULL, id_facultad INTEGER, FOREIGN KEY (id_facultad) REFERENCES Facultades(id_facultad));''',
      '''CREATE TABLE Requisitos (id_materia_cursar INTEGER, id_materia_previa INTEGER, PRIMARY KEY (id_materia_cursar, id_materia_previa), FOREIGN KEY (id_materia_cursar) REFERENCES Materias(id_materia), FOREIGN KEY (id_materia_previa) REFERENCES Materias(id_materia));''',

      // 3. OFERTA: PARALELOS_SEMESTRE
      '''CREATE TABLE Paralelos_Semestre (id_paralelo INTEGER PRIMARY KEY, id_materia INTEGER NOT NULL, id_docente INTEGER NOT NULL, id_semestre INTEGER NOT NULL, id_aula INTEGER, nombre_paralelo TEXT NOT NULL, FOREIGN KEY (id_materia) REFERENCES Materias(id_materia), FOREIGN KEY (id_docente) REFERENCES Docentes(id_docente), FOREIGN KEY (id_semestre) REFERENCES Semestres(id_semestre), FOREIGN KEY (id_aula) REFERENCES Aulas(id_aula), UNIQUE (id_materia, id_semestre, nombre_paralelo));''',

      // 4. HORARIOS
      '''CREATE TABLE Horarios (id_horario INTEGER PRIMARY KEY, dia TEXT NOT NULL, hora_inicio TEXT NOT NULL, hora_fin TEXT NOT NULL);''',
      '''CREATE TABLE Paralelo_Horario (id_paralelo INTEGER NOT NULL, id_horario INTEGER NOT NULL, PRIMARY KEY (id_paralelo, id_horario), FOREIGN KEY (id_paralelo) REFERENCES Paralelos_Semestre(id_paralelo), FOREIGN KEY (id_horario) REFERENCES Horarios(id_horario));''',

      // 5. REGISTRO Y NOTAS
      '''CREATE TABLE Inscripciones (id_inscripcion INTEGER PRIMARY KEY, id_estudiante INTEGER NOT NULL, id_paralelo INTEGER NOT NULL, fecha_inscripcion TEXT, estado TEXT NOT NULL, parcial1 REAL, parcial2 REAL, examen_final REAL, segundo_turno REAL, FOREIGN KEY (id_estudiante) REFERENCES Estudiantes(id_estudiante), FOREIGN KEY (id_paralelo) REFERENCES Paralelos_Semestre(id_paralelo), UNIQUE (id_estudiante, id_paralelo));''',

      // 6. SOLICITUDES
      '''CREATE TABLE Solicitudes_Inscripcion (id_solicitud INTEGER PRIMARY KEY, id_estudiante INTEGER NOT NULL, id_paralelo INTEGER NOT NULL, fecha_solicitud TEXT, motivo TEXT, estado TEXT NOT NULL, FOREIGN KEY (id_estudiante) REFERENCES Estudiantes(id_estudiante), FOREIGN KEY (id_paralelo) REFERENCES Paralelos_Semestre(id_paralelo), UNIQUE (id_estudiante, id_paralelo));''',
    ];

    for (final query in createTableQueries) {
      await db.execute(query);
    }

    // 🚨 Llamada a la siembra de datos justo después de crear las tablas 🚨
    await _seedDatabase(db);
  }

  // 🚨 NUEVO MÉTODO PARA INSERTAR DATOS INICIALES 🚨
  // lib/data/database/database_service.dart

  // ... (tus imports y la clase DatabaseService)

  // 🚨 NUEVO MÉTODO PARA INSERTAR DATOS INICIALES (USANDO TRANSACCIÓN SEGURA) 🚨
// lib/data/database/database_service.dart
// ... (dentro de la clase DatabaseService)

  // 🚨 ===================================================================== 🚨
  // 🚨 REEMPLAZA TU MÉTODO _seedDatabase COMPLETO CON ESTE "MEGA-DEBUG" 🚨
  // 🚨 ===================================================================== 🚨
Future<void> _seedDatabase(Database db) async {
    await db.transaction((txn) async {
      print('🌱 Ejecutando _seedDatabase... (Versión UNIFICADA)');
      
      // --- 1. SEMESTRES (Formato cronológico unificado) ---
      final int semVerano25Id = await txn.insert('Semestres', {'nombre': '2025-1 Verano'});
      final int sem1_25Id = await txn.insert('Semestres', {'nombre': '2025-2 Semestre 1'});
      final int semInvierno25Id = await txn.insert('Semestres', {'nombre': '2025-3 Invierno'});
      final int sem2_25Id = await txn.insert('Semestres', {'nombre': '2025-4 Semestre 2'}); // <-- Este es el "actual"
      final int sem1_24Id = await txn.insert('Semestres', {'nombre': '2024-2 Semestre 1'});
      final int sem2_23Id = await txn.insert('Semestres', {'nombre': '2023-4 Semestre 2'});

      // --- ESTRUCTURAS BÁSICAS ---
      final int facIngId = await txn.insert('Facultades', {'nombre': 'Ingeniería'});
      final int aulaA1Id = await txn.insert('Aulas', {'nombre': 'Aula A-10'});
      final int aulaB2Id = await txn.insert('Aulas', {'nombre': 'Aula B-20'});
      final int docGomezId = await txn.insert('Docentes', {'nombre': 'Ana', 'apellido': 'Gomez'});
      final int docLopezId = await txn.insert('Docentes', {'nombre': 'Roberto', 'apellido': 'Lopez'});

      // --- 3. ESTUDIANTE ---
      final int estPerezId = await txn.insert('Estudiantes', {
        'usuario': 'jperez', 'contrasena': 'contraseña123', 'nombre': 'José', 'apellido': 'Perez',
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      // --- 4. MATERIAS ---
      final int matCalc1Id = await txn.insert('Materias', {'codigo': 'MAT-101', 'nombre': 'Cálculo I', 'id_facultad': facIngId});
      final int matCalc2Id = await txn.insert('Materias', {'codigo': 'MAT-102', 'nombre': 'Cálculo II', 'id_facultad': facIngId});
      final int matFis1Id = await txn.insert('Materias', {'codigo': 'FIS-101', 'nombre': 'Física I', 'id_facultad': facIngId});
      final int matAlg1Id = await txn.insert('Materias', {'codigo': 'MAT-100', 'nombre': 'Álgebra I', 'id_facultad': facIngId});
      final int matFis0Id = await txn.insert('Materias', {'codigo': 'FIS-100', 'nombre': 'Física Básica', 'id_facultad': facIngId});
      final int matIntroProgId = await txn.insert('Materias', {'codigo': 'CS-100', 'nombre': 'Intro. a la Programación', 'id_facultad': facIngId});


      // --- 7. OFERTA DE MATERIAS (PARALELOS_SEMESTRE) ---
      // Semestre "Actual" (2025-4 Semestre 2)
      final int parActualCalc2Id = await txn.insert('Paralelos_Semestre', {'id_materia': matCalc2Id, 'id_docente': docGomezId, 'id_semestre': sem2_25Id, 'id_aula': aulaA1Id, 'nombre_paralelo': 'A'});
      final int parActualFis1Id = await txn.insert('Paralelos_Semestre', {'id_materia': matFis1Id, 'id_docente': docLopezId, 'id_semestre': sem2_25Id, 'id_aula': aulaB2Id, 'nombre_paralelo': 'B'});
      
      // Resto del historial
      final int par_1_25_Calc1Id = await txn.insert('Paralelos_Semestre', {'id_materia': matCalc1Id, 'id_docente': docGomezId, 'id_semestre': sem1_25Id, 'id_aula': aulaA1Id, 'nombre_paralelo': 'A'});
      final int parVerano25Calc1Id = await txn.insert('Paralelos_Semestre', {'id_materia': matCalc1Id, 'id_docente': docGomezId, 'id_semestre': semVerano25Id, 'id_aula': aulaA1Id, 'nombre_paralelo': 'V'});
      final int par_1_24_Alg1Id = await txn.insert('Paralelos_Semestre', {'id_materia': matAlg1Id, 'id_docente': docLopezId, 'id_semestre': sem1_24Id, 'id_aula': aulaB2Id, 'nombre_paralelo': 'C'});
      final int par_2_23_Fis0Id = await txn.insert('Paralelos_Semestre', {'id_materia': matFis0Id, 'id_docente': docLopezId, 'id_semestre': sem2_23Id, 'id_aula': aulaB2Id, 'nombre_paralelo': 'D'});
      final int parInvierno25Id = await txn.insert('Paralelos_Semestre', {'id_materia': matIntroProgId, 'id_docente': docGomezId, 'id_semestre': semInvierno25Id, 'id_aula': aulaA1Id, 'nombre_paralelo': 'W'});


      // --- 8. ASIGNACIÓN DE HORARIOS (¡IMPORTANTE PARA LA PANTALLA DE HORARIOS!) ---
      // Estos son los horarios para el semestre "actual" (2025-4 Semestre 2)
      final int h1Id = await txn.insert('Horarios', {'dia': 'Lunes', 'hora_inicio': '08:00', 'hora_fin': '10:00'});
      final int h3Id = await txn.insert('Horarios', {'dia': 'Miércoles', 'hora_inicio': '08:00', 'hora_fin': '10:00'});
      final int h5Id = await txn.insert('Horarios', {'dia': 'Lunes', 'hora_inicio': '10:00', 'hora_fin': '12:00'});
      final int h6Id = await txn.insert('Horarios', {'dia': 'Miércoles', 'hora_inicio': '10:00', 'hora_fin': '12:00'});
      
      // Asignar horarios a Cálculo II
      await txn.insert('Paralelo_Horario', {'id_paralelo': parActualCalc2Id, 'id_horario': h1Id});
      await txn.insert('Paralelo_Horario', {'id_paralelo': parActualCalc2Id, 'id_horario': h3Id});
      // Asignar horarios a Física I
      await txn.insert('Paralelo_Horario', {'id_paralelo': parActualFis1Id, 'id_horario': h5Id});
      await txn.insert('Paralelo_Horario', {'id_paralelo': parActualFis1Id, 'id_horario': h6Id});


      // --- 9. HISTORIAL DE INSCRIPCIONES (¡IMPORTANTE PARA AMBAS PANTALLAS!) ---
      
      // "2025-4 Semestre 2" -> Cursando (Para la pantalla de Horarios)
      await txn.insert('Inscripciones', {
        'id_estudiante': estPerezId, 'id_paralelo': parActualCalc2Id, 'estado': 'Cursando', 
        'fecha_inscripcion': DateTime.now().toIso8601String(), 'parcial1': 75.0
      });
      await txn.insert('Inscripciones', {
        'id_estudiante': estPerezId, 'id_paralelo': parActualFis1Id, 'estado': 'Cursando', 
        'fecha_inscripcion': DateTime.now().toIso8601String(), 'parcial1': 55.0, 'parcial2': 61.0
      });

      // "2025-3 Invierno" -> Aprobada (Para el Historial)
      await txn.insert('Inscripciones', {
        'id_estudiante': estPerezId, 'id_paralelo': parInvierno25Id, 'estado': 'Aprobada', 
        'parcial1': 90.0, 'parcial2': 92.0, 'examen_final': 95.0
      });

      // "2025-2 Semestre 1" -> Aprobada (Para el Historial)
      await txn.insert('Inscripciones', {
        'id_estudiante': estPerezId, 'id_paralelo': par_1_25_Calc1Id, 'estado': 'Aprobada', 
        'parcial1': 80.0, 'parcial2': 85.0, 'examen_final': 90.0
      });

      // "2025-1 Verano" -> Reprobada (Para el Historial)
      await txn.insert('Inscripciones', {
        'id_estudiante': estPerezId, 'id_paralelo': parVerano25Calc1Id, 'estado': 'Reprobada', 
        'parcial1': 30.0, 'parcial2': 35.0, 'examen_final': 40.0
      });
      
      // "2024-2 Semestre 1" -> Aprobada (Para el Historial)
      await txn.insert('Inscripciones', {
        'id_estudiante': estPerezId, 'id_paralelo': par_1_24_Alg1Id, 'estado': 'Aprobada', 
        'parcial1': 70.0, 'parcial2': 78.0, 'examen_final': 80.0
      });

      // "2023-4 Semestre 2" -> Aprobada (Para el Historial)
      await txn.insert('Inscripciones', {
        'id_estudiante': estPerezId, 'id_paralelo': par_2_23_Fis0Id, 'estado': 'Aprobada', 
        'parcial1': 60.0, 'parcial2': 66.0, 'examen_final': 70.0
      });

      print('✅ BASE DE DATOS SEMBRADA (Versión UNIFICADA). Lista para probar HORARIOS e HISTORIAL.');
    });
  }
}