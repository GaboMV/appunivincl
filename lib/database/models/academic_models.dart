// lib/data/models/academic_models.dart

// --- TABLAS BÁSICAS ---
class Estudiante {
  final int id;
  final String usuario;
  final String contrasena;
  final String nombre;
  final String apellido;

  Estudiante({
    required this.id,
    required this.usuario,
    required this.contrasena,
    required this.nombre,
    required this.apellido,
  });

  factory Estudiante.fromMap(Map<String, dynamic> map) {
    return Estudiante(
      id: map['id_estudiante'] as int,
      usuario: map['usuario'] as String,
      contrasena: map['contrasena'] as String,
      nombre: map['nombre'] as String,
      apellido: map['apellido'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'usuario': usuario,
      'contrasena': contrasena,
      'nombre': nombre,
      'apellido': apellido,
    };
  }
}

class Docente {
  final int id;
  final String nombre;
  final String apellido;

  Docente({required this.id, required this.nombre, required this.apellido});
  factory Docente.fromMap(Map<String, dynamic> map) {
    return Docente(
      id: map['id_docente'] as int,
      nombre: map['nombre'] as String,
      apellido: map['apellido'] as String,
    );
  }
}

class Semestre {
  final int id;
  final String nombre;

  Semestre({required this.id, required this.nombre});
  factory Semestre.fromMap(Map<String, dynamic> map) {
    return Semestre(
      id: map['id_semestre'] as int,
      nombre: map['nombre'] as String,
    );
  }
}

class Facultad {
  final int id;
  final String nombre;

  Facultad({required this.id, required this.nombre});
  factory Facultad.fromMap(Map<String, dynamic> map) {
    return Facultad(
      id: map['id_facultad'] as int,
      nombre: map['nombre'] as String,
    );
  }
}

class Aula {
  final int id;
  final String nombre;

  Aula({required this.id, required this.nombre});
  factory Aula.fromMap(Map<String, dynamic> map) {
    return Aula(id: map['id_aula'] as int, nombre: map['nombre'] as String);
  }
}

// --- MATERIAS Y OFERTA ---
class Materia {
  final int id;
  final String codigo;
  final String nombre;
  final int idFacultad;

  Materia({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.idFacultad,
  });
  factory Materia.fromMap(Map<String, dynamic> map) {
    return Materia(
      id: map['id_materia'] as int,
      codigo: map['codigo'] as String,
      nombre: map['nombre'] as String,
      idFacultad: map['id_facultad'] as int,
    );
  }
}

class ParaleloSemestre {
  final int id;
  final int idMateria;
  final int idDocente;
  final int idSemestre;
  final int? idAula;
  final String nombreParalelo;

  ParaleloSemestre({
    required this.id,
    required this.idMateria,
    required this.idDocente,
    required this.idSemestre,
    required this.nombreParalelo,
    this.idAula,
  });

  factory ParaleloSemestre.fromMap(Map<String, dynamic> map) {
    return ParaleloSemestre(
      id: map['id_paralelo'] as int,
      idMateria: map['id_materia'] as int,
      idDocente: map['id_docente'] as int,
      idSemestre: map['id_semestre'] as int,
      idAula: map['id_aula'] as int?,
      nombreParalelo: map['nombre_paralelo'] as String,
    );
  }
}

class Horario {
  final int id;
  final String dia;
  final String horaInicio;
  final String horaFin;

  Horario({
    required this.id,
    required this.dia,
    required this.horaInicio,
    required this.horaFin,
  });
  factory Horario.fromMap(Map<String, dynamic> map) {
    return Horario(
      id: map['id_horario'] as int,
      dia: map['dia'] as String,
      horaInicio: map['hora_inicio'] as String,
      horaFin: map['hora_fin'] as String,
    );
  }
}

// --- INSCRIPCIONES Y SOLICITUDES ---
class Inscripcion {
  final int id;
  final int idEstudiante;
  final int idParalelo;
  final String estado;
  final double? parcial1;
  final double? parcial2;
  final double? examenFinal;
  final double? segundoTurno;

  Inscripcion({
    required this.id,
    required this.idEstudiante,
    required this.idParalelo,
    required this.estado,
    this.parcial1,
    this.parcial2,
    this.examenFinal,
    this.segundoTurno,
  });

  factory Inscripcion.fromMap(Map<String, dynamic> map) {
    return Inscripcion(
      id: map['id_inscripcion'] as int,
      idEstudiante: map['id_estudiante'] as int,
      idParalelo: map['id_paralelo'] as int,
      estado: map['estado'] as String,
      parcial1: map['parcial1'] as double?,
      parcial2: map['parcial2'] as double?,
      examenFinal: map['examen_final'] as double?,
      segundoTurno: map['segundo_turno'] as double?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_estudiante': idEstudiante,
      'id_paralelo': idParalelo,
      'estado': estado,
      // Puedes incluir las notas como null al insertar, o en un método separado
      'parcial1': parcial1,
    };
  }
}

class SolicitudInscripcion {
  final int id;
  final int idEstudiante;
  final int idParalelo;
  final String motivo;
  final String estado; // "En Espera", "Aceptada", "Rechazada"

  SolicitudInscripcion({
    required this.id,
    required this.idEstudiante,
    required this.idParalelo,
    required this.motivo,
    required this.estado,
  });

  factory SolicitudInscripcion.fromMap(Map<String, dynamic> map) {
    return SolicitudInscripcion(
      id: map['id_solicitud'] as int,
      idEstudiante: map['id_estudiante'] as int,
      idParalelo: map['id_paralelo'] as int,
      motivo: map['motivo'] as String,
      estado: map['estado'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_estudiante': idEstudiante,
      'id_paralelo': idParalelo,
      'motivo': motivo,
      'estado': estado,
    };
  }

  
}

// lib/database/models/academic_models.dart

// ... (todas tus clases existentes como Estudiante, Semestre, etc.) ...

/// Modelo DTO (Data Transfer Object) para mostrar el historial
/// Combina datos de Inscripciones, Materias y Paralelos.
class HistorialMateria {
  final String nombreMateria;
  final String estadoDB; // El estado guardado en la BD (Cursando, Aprobada, etc.)
  final double? parcial1;
  final double? parcial2;
  final double? examenFinal;
  final double? segundoTurno;

  HistorialMateria({
    required this.nombreMateria,
    required this.estadoDB,
    this.parcial1,
    this.parcial2,
    this.examenFinal,
    this.segundoTurno,
  });

  factory HistorialMateria.fromMap(Map<String, dynamic> map) {
    return HistorialMateria(
      nombreMateria: map['nombre_materia'] as String,
      estadoDB: map['estado'] as String,
      parcial1: map['parcial1'] as double?,
      parcial2: map['parcial2'] as double?,
      examenFinal: map['examen_final'] as double?,
      segundoTurno: map['segundo_turno'] as double?,
    );
  }

  /// Calcula la nota final visible para el estudiante
  double get notaFinal {
    // La nota del 2do Turno reemplaza al Examen Final
    if (segundoTurno != null && segundoTurno! > 0) {
      return segundoTurno!;
    }
    if (examenFinal != null && examenFinal! > 0) {
      return examenFinal!;
    }
    // Si no hay nota final, usamos un promedio simple (o 0 si no hay notas)
    if (parcial1 != null && parcial2 != null) {
      return (parcial1! + parcial2!) / 2;
    }
    return 0;
  }

  /// Determina el estado (Aprobado/Reprobado) según la regla de nota > 50
  String get estadoCalculado {
    if (estadoDB.toLowerCase() == 'cursando') {
      return "Cursando";
    }
    // La regla que pediste:
    if (notaFinal > 50) {
      return "Aprobado";
    } else {
      // Solo decimos "Reprobado" si tiene una nota final y no está cursando
      if (notaFinal > 0) {
        return "Reprobado";
      }
      // Si no, es un estado pendiente o sin nota
      return "Sin nota final";
    }
  }

  /// Genera el texto para el Text-to-Speech (TTS)
  String get lecturaTts {
    // Si está cursando, damos notas parciales
    if (estadoDB.toLowerCase() == 'cursando') {
      return 'Materia: $nombreMateria. Estado: Cursando. '
          'Primer Parcial: ${parcial1 ?? 'Sin nota'}. '
          'Segundo Parcial: ${parcial2 ?? 'Sin nota'}.';
    }
    
    // Si ya terminó (Aprobado/Reprobado)
    return 'Materia: $nombreMateria. Estado: $estadoCalculado. '
        'Nota Final: ${notaFinal.toStringAsFixed(0)}. '
        'Primer Parcial: ${parcial1 ?? 'N/A'}. '
        'Segundo Parcial: ${parcial2 ?? 'N/A'}. '
        'Examen Final: ${examenFinal ?? 'N/A'}. '
        'Segundo Turno: ${segundoTurno ?? 'No aplica'}.';
  }
}
