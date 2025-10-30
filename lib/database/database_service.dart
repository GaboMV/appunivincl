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
      '''CREATE TABLE Solicitudes_Inscripcion (id_solicitud INTEGER PRIMARY KEY, id_estudiante INTEGER NOT NULL, id_paralelo INTEGER NOT NULL, fecha_solicitud TEXT, motivo TEXT, estado TEXT NOT NULL, FOREIGN KEY (id_estudiante) REFERENCES Estudiantes(id_estudiante), FOREIGN KEY (id_paralelo) REFERENCES Paralelos_Semestre(id_paralelo), UNIQUE (id_estudiante, id_paralelo));'''
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
Future<void> _seedDatabase(Database db) async {
  
  // Usamos una transacción (txn) para garantizar que TODAS las inserciones se completen 
  // o NINGUNA se complete (roll-back) si hay un error de constraint.
  await db.transaction((txn) async {
    // --- 1. ESTUDIANTE DE PRUEBA (USUARIO Y CONTRASEÑA LIMPIOS) ---
    final int estudianteId = await txn.insert('Estudiantes', {
      // 🚨 CORRECCIÓN: Usamos solo minúsculas y sin espacios 🚨
      'usuario': 'jperez', 
      'contrasena': 'contraseña123', 
      'nombre': 'José', 
      'apellido': 'Perez'
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    
    // --- 2. SEMESTRE DE PRUEBA (Actual) ---
    final int semestreId = await txn.insert('Semestres', {
      'nombre': '2/2025'
    });
    
    // --- 3. FACULTADES Y MATERIAS ---
    final int facultadId = await txn.insert('Facultades', {'nombre': 'Ingeniería'});
    final int matCalculo1Id = await txn.insert('Materias', {
      'codigo': 'MAT-101', 
      'nombre': 'Cálculo I', 
      'id_facultad': facultadId
    });
    final int matCalculo2Id = await txn.insert('Materias', {
      'codigo': 'MAT-102', 
      'nombre': 'Cálculo II', 
      'id_facultad': facultadId
    });
    
    // --- 4. REQUISITOS (Cálculo II requiere Cálculo I) ---
    await txn.insert('Requisitos', {
      'id_materia_cursar': matCalculo2Id,
      'id_materia_previa': matCalculo1Id,
    });
    
    // --- 5. DOCENTE ---
    final int docenteId = await txn.insert('Docentes', {
      'nombre': 'Ana', 
      'apellido': 'Gomez'
    });
    
    // --- 6. PARALELO SEMESTRE (Cálculo I - Paralelo A) ---
    final int paraleloId = await txn.insert('Paralelos_Semestre', {
      'id_materia': matCalculo1Id,
      'id_docente': docenteId,
      'id_semestre': semestreId,
      'nombre_paralelo': 'A',
      'id_aula': null // Ejemplo sin aula
    });
    
    // --- 7. INSCRIPCIÓN (Juan aprobó Cálculo I para probar el requisito) ---
    await txn.insert('Inscripciones', {
      'id_estudiante': estudianteId,
      'id_paralelo': paraleloId,
      'fecha_inscripcion': DateTime.now().toIso8601String(),
      'estado': 'Aprobada', 
      'parcial1': 80.0,
      'examen_final': 90.0
    });
    
    print('================================================================');
    print('✅ INICIALIZACIÓN DE BASE DE DATOS COMPLETA Y SEMBRADA.');
    print('   - Usuario de Prueba: jperez');
    print('   - Contraseña: 1234');
    print('================================================================');
  }); // Si la transacción es exitosa, se guarda.
}

// ... (Asegúrate de que tu _onCreate llama a _seedDatabase(db) )
}