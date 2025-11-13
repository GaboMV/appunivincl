// lib/data/database/database_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
      onCreate: _onCreate,
      singleInstance: true,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    final createTableQueries = [
      // 1. ESTRUCTURAS BÁSICAS
      '''CREATE TABLE Estudiantes (id_estudiante INTEGER PRIMARY KEY, usuario TEXT NOT NULL UNIQUE, contrasena TEXT NOT NULL, nombre TEXT NOT NULL, apellido TEXT NOT NULL);''',
      '''CREATE TABLE Docentes (id_docente INTEGER PRIMARY KEY, nombre TEXT NOT NULL, apellido TEXT NOT NULL);''',
      '''CREATE TABLE Semestres (id_semestre INTEGER PRIMARY KEY, nombre TEXT NOT NULL UNIQUE);''',
      '''CREATE TABLE Facultades (id_facultad INTEGER PRIMARY KEY, nombre TEXT NOT NULL UNIQUE);''',
      '''CREATE TABLE Aulas (id_aula INTEGER PRIMARY KEY, nombre TEXT NOT NULL UNIQUE);''',

      // 2. MATERIAS Y REQUISITOS (🚨 TABLA MATERIAS ACTUALIZADA 🚨)
      '''CREATE TABLE Materias (id_materia INTEGER PRIMARY KEY, codigo TEXT NOT NULL UNIQUE, nombre TEXT NOT NULL, creditos INTEGER NOT NULL DEFAULT 0, id_facultad INTEGER, FOREIGN KEY (id_facultad) REFERENCES Facultades(id_facultad));''',
      '''CREATE TABLE Requisitos (id_materia_cursar INTEGER, id_materia_previa INTEGER, PRIMARY KEY (id_materia_cursar, id_materia_previa), FOREIGN KEY (id_materia_cursar) REFERENCES Materias(id_materia), FOREIGN KEY (id_materia_previa) REFERENCES Materias(id_materia));''',

      // 3. OFERTA
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
    await _seedDatabase(db);
  }

  // 🚨 ======================================================
  // 🚨 _seedDatabase COMPLETAMENTE ACTUALIZADO
  // 🚨 (CON CRÉDITOS, REQUISITOS Y HORARIOS COMPLETOS)
  // 🚨 ======================================================
  // lib/data/database/database_service.dart
  // ... (dentro de la clase DatabaseService) ...

  // lib/data/database/database_service.dart
  // (dentro de la clase DatabaseService)

  // 🚨 ======================================================
  // 🚨 _seedDatabase CON MÁS DATOS (v6 - LA BUENA)
  // 🚨 ======================================================
  // lib/data/database/database_service.dart
  // (dentro de la clase DatabaseService)

  // 🚨 ======================================================
  // 🚨 _seedDatabase CON HORARIOS PARA JPEREZ Y CHOQUES
  // lib/data/database/database_service.dart
  // (dentro de la clase DatabaseService)

  // 🚨 ======================================================
  // 🚨 _seedDatabase CON CHOQUE DE HORARIO PARA JPEREZ
  // 🚨 ======================================================
  Future<void> _seedDatabase(Database db) async {
    await db.transaction((txn) async {
      print(
        '🌱 Ejecutando _seedDatabase... (Versión INSCRIPCIONES v7 - Choque JPEREZ)',
      );

      // --- 1. SEMESTRES ---
      final int semVerano25Id = await txn.insert('Semestres', {
        'nombre': '2025-1 Verano',
      });
      final int sem1_25Id = await txn.insert('Semestres', {
        'nombre': '2025-2 Semestre 1',
      });
      final int semInvierno25Id = await txn.insert('Semestres', {
        'nombre': '2025-3 Invierno',
      });
      final int sem2_25Id = await txn.insert('Semestres', {
        'nombre': '2025-4 Semestre 2',
      }); // Actual
      final int sem1_24Id = await txn.insert('Semestres', {
        'nombre': '2024-2 Semestre 1',
      });
      final int sem2_23Id = await txn.insert('Semestres', {
        'nombre': '2023-4 Semestre 2',
      });

      // --- 2. FACULTADES ---
      final int facIngId = await txn.insert('Facultades', {
        'nombre': 'Ingeniería',
      });
      final int facEconId = await txn.insert('Facultades', {
        'nombre': 'Economía',
      });
      final int facHumId = await txn.insert('Facultades', {
        'nombre': 'Humanidades',
      });

      // --- 3. AULAS, DOCENTES ---
      final int aulaA1Id = await txn.insert('Aulas', {'nombre': 'Aula A-10'});
      final int aulaB2Id = await txn.insert('Aulas', {'nombre': 'Aula B-20'});
      final int docGomezId = await txn.insert('Docentes', {
        'nombre': 'Ana',
        'apellido': 'Gomez',
      });
      final int docLopezId = await txn.insert('Docentes', {
        'nombre': 'Roberto',
        'apellido': 'Lopez',
      });
      final int docMartaId = await txn.insert('Docentes', {
        'nombre': 'Marta',
        'apellido': 'Suarez',
      });

      // --- 4. ESTUDIANTES ---
      final int estPerezId = await txn.insert('Estudiantes', {
        'usuario': 'jperez',
        'contrasena': 'contraseña123',
        'nombre': 'José',
        'apellido': 'Perez',
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      final int estSilvaId = await txn.insert('Estudiantes', {
        'usuario': 'asilva',
        'contrasena': 'contra123',
        'nombre': 'Ana',
        'apellido': 'Silva',
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      // --- 5. MATERIAS (NUEVAS AÑADIDAS) ---
      final int matCalc1Id = await txn.insert('Materias', {
        'codigo': 'MAT-101',
        'nombre': 'Cálculo I',
        'creditos': 5,
        'id_facultad': facIngId,
      });
      final int matCalc2Id = await txn.insert('Materias', {
        'codigo': 'MAT-102',
        'nombre': 'Cálculo II',
        'creditos': 5,
        'id_facultad': facIngId,
      });
      final int matEcuacId = await txn.insert('Materias', {
        'codigo': 'MAT-200',
        'nombre': 'Ecuaciones Diferenciales',
        'creditos': 5,
        'id_facultad': facIngId,
      });
      final int matFis1Id = await txn.insert('Materias', {
        'codigo': 'FIS-101',
        'nombre': 'Física I',
        'creditos': 4,
        'id_facultad': facIngId,
      });
      final int matFis2Id = await txn.insert('Materias', {
        'codigo': 'FIS-102',
        'nombre': 'Física II',
        'creditos': 4,
        'id_facultad': facIngId,
      });
      final int matIntroProgId = await txn.insert('Materias', {
        'codigo': 'CS-100',
        'nombre': 'Intro. a la Programación',
        'creditos': 3,
        'id_facultad': facIngId,
      });
      final int matMicro1Id = await txn.insert('Materias', {
        'codigo': 'ECO-100',
        'nombre': 'Microeconomía I',
        'creditos': 4,
        'id_facultad': facEconId,
      });
      final int matMicro2Id = await txn.insert('Materias', {
        'codigo': 'ECO-101',
        'nombre': 'Microeconomía II',
        'creditos': 4,
        'id_facultad': facEconId,
      });
      final int matSocioId = await txn.insert('Materias', {
        'codigo': 'HUM-101',
        'nombre': 'Sociología',
        'creditos': 3,
        'id_facultad': facHumId,
      });
      final int matDerechoId = await txn.insert('Materias', {
        'codigo': 'DER-100',
        'nombre': 'Derecho I',
        'creditos': 3,
        'id_facultad': facHumId,
      });
      final int matPsicoId = await txn.insert('Materias', {
        'codigo': 'PSI-100',
        'nombre': 'Psicología',
        'creditos': 3,
        'id_facultad': facHumId,
      });

      // --- 6. REQUISITOS ---
      await txn.insert('Requisitos', {
        'id_materia_cursar': matCalc2Id,
        'id_materia_previa': matCalc1Id,
      }); // Calc II -> Calc I
      await txn.insert('Requisitos', {
        'id_materia_cursar': matEcuacId,
        'id_materia_previa': matCalc2Id,
      }); // Ecuac. -> Calc II
      await txn.insert('Requisitos', {
        'id_materia_cursar': matFis2Id,
        'id_materia_previa': matFis1Id,
      }); // Física II -> Física I
      await txn.insert('Requisitos', {
        'id_materia_cursar': matMicro2Id,
        'id_materia_previa': matMicro1Id,
      }); // Micro II -> Micro I

      // --- 7. HORARIOS (MÁS DÍAS) ---
      final int h1 = await txn.insert('Horarios', {
        'dia': 'Lunes',
        'hora_inicio': '08:00',
        'hora_fin': '10:00',
      });
      final int h2 = await txn.insert('Horarios', {
        'dia': 'Miércoles',
        'hora_inicio': '08:00',
        'hora_fin': '10:00',
      });
      final int h3 = await txn.insert('Horarios', {
        'dia': 'Lunes',
        'hora_inicio': '10:00',
        'hora_fin': '12:00',
      });
      final int h4 = await txn.insert('Horarios', {
        'dia': 'Miércoles',
        'hora_inicio': '10:00',
        'hora_fin': '12:00',
      });
      final int h5 = await txn.insert('Horarios', {
        'dia': 'Martes',
        'hora_inicio': '14:00',
        'hora_fin': '16:00',
      });
      final int h6 = await txn.insert('Horarios', {
        'dia': 'Jueves',
        'hora_inicio': '14:00',
        'hora_fin': '16:00',
      });
      final int h7 = await txn.insert('Horarios', {
        'dia': 'Viernes',
        'hora_inicio': '09:00',
        'hora_fin': '11:00',
      });
      final int h8 = await txn.insert('Horarios', {
        'dia': 'Martes',
        'hora_inicio': '08:00',
        'hora_fin': '10:00',
      });
      final int h9 = await txn.insert('Horarios', {
        'dia': 'Jueves',
        'hora_inicio': '08:00',
        'hora_fin': '10:00',
      });
      final int h10 = await txn.insert('Horarios', {
        'dia': 'Viernes',
        'hora_inicio': '14:00',
        'hora_fin': '16:00',
      });

      // --- 8. OFERTA DE PARALELOS (Semestre Actual 2025-4) ---
      final int p_c2_A = await txn.insert('Paralelos_Semestre', {
        'id_materia': matCalc2Id,
        'id_docente': docGomezId,
        'id_semestre': sem2_25Id,
        'id_aula': aulaA1Id,
        'nombre_paralelo': 'A',
      });
      final int p_c2_B = await txn.insert('Paralelos_Semestre', {
        'id_materia': matCalc2Id,
        'id_docente': docLopezId,
        'id_semestre': sem2_25Id,
        'id_aula': aulaB2Id,
        'nombre_paralelo': 'B',
      });
      final int p_ec = await txn.insert('Paralelos_Semestre', {
        'id_materia': matEcuacId,
        'id_docente': docGomezId,
        'id_semestre': sem2_25Id,
        'id_aula': aulaA1Id,
        'nombre_paralelo': 'A',
      });
      final int p_f1_A = await txn.insert('Paralelos_Semestre', {
        'id_materia': matFis1Id,
        'id_docente': docLopezId,
        'id_semestre': sem2_25Id,
        'id_aula': aulaB2Id,
        'nombre_paralelo': 'A',
      });
      final int p_f1_B = await txn.insert('Paralelos_Semestre', {
        'id_materia': matFis1Id,
        'id_docente': docGomezId,
        'id_semestre': sem2_25Id,
        'id_aula': aulaA1Id,
        'nombre_paralelo': 'B',
      });
      final int p_f2 = await txn.insert('Paralelos_Semestre', {
        'id_materia': matFis2Id,
        'id_docente': docLopezId,
        'id_semestre': sem2_25Id,
        'id_aula': aulaB2Id,
        'nombre_paralelo': 'A',
      });
      final int p_m2 = await txn.insert('Paralelos_Semestre', {
        'id_materia': matMicro2Id,
        'id_docente': docMartaId,
        'id_semestre': sem2_25Id,
        'id_aula': aulaA1Id,
        'nombre_paralelo': 'C',
      });
      final int p_soc = await txn.insert('Paralelos_Semestre', {
        'id_materia': matSocioId,
        'id_docente': docMartaId,
        'id_semestre': sem2_25Id,
        'id_aula': aulaB2Id,
        'nombre_paralelo': 'A',
      });
      final int p_der = await txn.insert('Paralelos_Semestre', {
        'id_materia': matDerechoId,
        'id_docente': docMartaId,
        'id_semestre': sem2_25Id,
        'id_aula': aulaA1Id,
        'nombre_paralelo': 'A',
      });
      final int p_psi = await txn.insert('Paralelos_Semestre', {
        'id_materia': matPsicoId,
        'id_docente': docMartaId,
        'id_semestre': sem2_25Id,
        'id_aula': aulaB2Id,
        'nombre_paralelo': 'A',
      });

      // --- Oferta de Paralelos (Semestres Pasados) ---
      final int p_c1_pasado = await txn.insert('Paralelos_Semestre', {
        'id_materia': matCalc1Id,
        'id_docente': docGomezId,
        'id_semestre': sem1_25Id,
        'id_aula': aulaA1Id,
        'nombre_paralelo': 'A',
      });
      final int p_f1_pasado = await txn.insert('Paralelos_Semestre', {
        'id_materia': matFis1Id,
        'id_docente': docLopezId,
        'id_semestre': sem1_24Id,
        'id_aula': aulaB2Id,
        'nombre_paralelo': 'A',
      });
      final int p_m1_pasado = await txn.insert('Paralelos_Semestre', {
        'id_materia': matMicro1Id,
        'id_docente': docMartaId,
        'id_semestre': sem1_25Id,
        'id_aula': aulaA1Id,
        'nombre_paralelo': 'A',
      });

      // --- 9. ASIGNACIÓN DE HORARIOS (CON CHOQUES) ---
      await txn.insert('Paralelo_Horario', {
        'id_paralelo': p_c2_A,
        'id_horario': h1,
      }); // Calc II-A (Lu 08-10)
      await txn.insert('Paralelo_Horario', {
        'id_paralelo': p_c2_A,
        'id_horario': h2,
      }); // Calc II-A (Mi 08-10)
      await txn.insert('Paralelo_Horario', {
        'id_paralelo': p_c2_B,
        'id_horario': h5,
      }); // Calc II-B (Ma 14-16)
      await txn.insert('Paralelo_Horario', {
        'id_paralelo': p_c2_B,
        'id_horario': h6,
      }); // Calc II-B (Ju 14-16)
      await txn.insert('Paralelo_Horario', {
        'id_paralelo': p_ec,
        'id_horario': h3,
      }); // Ecuac. (Lu 10-12)
      await txn.insert('Paralelo_Horario', {
        'id_paralelo': p_ec,
        'id_horario': h4,
      }); // Ecuac. (Mi 10-12)
      await txn.insert('Paralelo_Horario', {
        'id_paralelo': p_f1_A,
        'id_horario': h3,
      }); // Física I-A (Lu 10-12) 🚨 CHOQUE CON ECUAC.
      await txn.insert('Paralelo_Horario', {
        'id_paralelo': p_f1_A,
        'id_horario': h4,
      }); // Física I-A (Mi 10-12) 🚨 CHOQUE CON ECUAC.
      await txn.insert('Paralelo_Horario', {
        'id_paralelo': p_f1_B,
        'id_horario': h5,
      }); // Física I-B (Ma 14-16) 🚨 CHOQUE CON CALC II-B
      await txn.insert('Paralelo_Horario', {
        'id_paralelo': p_f2,
        'id_horario': h8,
      }); // Física II (Ma 08-10)
      await txn.insert('Paralelo_Horario', {
        'id_paralelo': p_f2,
        'id_horario': h9,
      }); // Física II (Ju 08-10)
      await txn.insert('Paralelo_Horario', {
        'id_paralelo': p_m2,
        'id_horario': h1,
      }); // Micro II (Lu 08-10) 🚨 CHOQUE CON CALC II-A
      await txn.insert('Paralelo_Horario', {
        'id_paralelo': p_soc,
        'id_horario': h7,
      }); // Sociología (Vi 09-11)
      await txn.insert('Paralelo_Horario', {
        'id_paralelo': p_der,
        'id_horario': h10,
      }); // Derecho I (Vi 14-16)
      await txn.insert('Paralelo_Horario', {
        'id_paralelo': p_psi,
        'id_horario': h7,
      }); // Psicología (Vi 09-11) 🚨 CHOQUE CON SOCIOLOGÍA
      // Historial
      await txn.insert('Paralelo_Horario', {
        'id_paralelo': p_c1_pasado,
        'id_horario': h1,
      });
      await txn.insert('Paralelo_Horario', {
        'id_paralelo': p_f1_pasado,
        'id_horario': h3,
      });
      await txn.insert('Paralelo_Horario', {
        'id_paralelo': p_m1_pasado,
        'id_horario': h5,
      });

      // --- 10. HISTORIAL DE INSCRIPCIONES (ESCENARIOS) ---

      // === ESCENARIO 1: JOSÉ PEREZ ('jperez') ===
      // 🚨 REPROBÓ CÁLCULO I -> No cumple requisitos para Cálculo II
      await txn.insert('Inscripciones', {
        'id_estudiante': estPerezId,
        'id_paralelo': p_c1_pasado,
        'estado': 'Reprobada',
        'parcial1': 40.0,
        'examen_final': 40.0,
      });
      // APROBÓ MICRO I -> Sí cumple requisitos para Micro II
      await txn.insert('Inscripciones', {
        'id_estudiante': estPerezId,
        'id_paralelo': p_m1_pasado,
        'estado': 'Aprobada',
        'parcial1': 60.0,
        'examen_final': 70.0,
      });

      // 🚨 ======================================================
      // 🚨 INSCRIPCIONES ACTUALES DE JPEREZ (PARA PROBAR HORARIOS)
      // 🚨 ======================================================
      // (Ambas materias usan los horarios h3 y h4: Lu/Mi 10-12)

      // 1. INSCRITO EN Ecuaciones Diferenciales
      await txn.insert('Inscripciones', {
        'id_estudiante': estPerezId,
        'id_paralelo': p_ec,
        'estado': 'Cursando',
        'fecha_inscripcion': DateTime.now().toIso8601String(),
      });

      // 2. INSCRITO EN Física I (Paralelo A)
      await txn.insert('Inscripciones', {
        'id_estudiante': estPerezId,
        'id_paralelo': p_f1_A,
        'estado': 'Cursando',
        'fecha_inscripcion': DateTime.now().toIso8601String(),
      });

      // === ESCENARIO 2: ANA SILVA ('asilva') ===
      // APROBÓ CÁLCULO I
      await txn.insert('Inscripciones', {
        'id_estudiante': estSilvaId,
        'id_paralelo': p_c1_pasado,
        'estado': 'Aprobada',
        'parcial1': 80.0,
        'examen_final': 90.0,
      });
      // APROBÓ FÍSICA I
      await txn.insert('Inscripciones', {
        'id_estudiante': estSilvaId,
        'id_paralelo': p_f1_pasado,
        'estado': 'Aprobada',
        'parcial1': 70.0,
        'examen_final': 75.0,
      });
      // ESTÁ CURSANDO SOCIOLOGÍA (Viernes) -> Probará "Retirar" y probará choques
      await txn.insert('Inscripciones', {
        'id_estudiante': estSilvaId,
        'id_paralelo': p_soc,
        'estado': 'Cursando',
        'fecha_inscripcion': DateTime.now().toIso8601String(),
      });

      print('✅ BASE DE DATOS SEMBRADA (v7 - JPEREZ CON CHOQUE).');
    });
  }
}
