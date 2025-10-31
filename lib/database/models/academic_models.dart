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
