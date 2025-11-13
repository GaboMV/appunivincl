// lib/database/models/academic_models.dart

// (Este archivo NO debe importar 'utils', las funciones
// de formato de hora deben estar en la PÁGINA o en UTILS,
// pero como la página las necesita, las ponemos en UTILS.
// Este modelo debe permanecer "tonto")
// lib/database/models/academic_models.dart

// --- TABLAS BÁSICAS ---
class Estudiante {
  final int id_estudiante;
  final String usuario;
  final String contrasena;
  final String nombre;
  final String apellido;
  // ... (resto de la clase)
  Estudiante({
    required this.id_estudiante,
    required this.usuario,
    required this.contrasena,
    required this.nombre,
    required this.apellido,
  });
  factory Estudiante.fromMap(Map<String, dynamic> map) {
    return Estudiante(
      id_estudiante: map['id_estudiante'] as int,
      usuario: map['usuario'] as String,
      contrasena: map['contrasena'] as String,
      nombre: map['nombre'] as String,
      apellido: map['apellido'] as String,
    );
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
  final int id_semestre;
  final String nombre;
  Semestre({required this.id_semestre, required this.nombre});
  factory Semestre.fromMap(Map<String, dynamic> map) {
    return Semestre(
      id_semestre: map['id_semestre'] as int,
      nombre: map['nombre'] as String,
    );
  }
}

class Facultad {
  final int id_facultad;
  final String nombre;
  Facultad({required this.id_facultad, required this.nombre});
  factory Facultad.fromMap(Map<String, dynamic> map) {
    return Facultad(
      id_facultad: map['id_facultad'] as int,
      nombre: map['nombre'] as String,
    );
  }
}

class Aula {
  final int id_aula;
  final String nombre;
  Aula({required this.id_aula, required this.nombre});
  factory Aula.fromMap(Map<String, dynamic> map) {
    return Aula(
      id_aula: map['id_aula'] as int,
      nombre: map['nombre'] as String,
    );
  }
}

// --- MATERIAS Y OFERTA ---
class Materia {
  final int id_materia;
  final String codigo;
  final String nombre;
  final int creditos;
  final int id_facultad;

  Materia({
    required this.id_materia,
    required this.codigo,
    required this.nombre,
    required this.creditos,
    required this.id_facultad,
  });
  factory Materia.fromMap(Map<String, dynamic> map) {
    return Materia(
      id_materia: map['id_materia'] as int,
      codigo: map['codigo'] as String,
      nombre: map['nombre'] as String,
      creditos: map['creditos'] as int,
      id_facultad: map['id_facultad'] as int,
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
      'parcial1': parcial1,
    };
  }
}

class SolicitudInscripcion {
  final int id;
  final int idEstudiante;
  final int idParalelo;
  final String motivo;
  final String estado;
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

// --- DTOS (Data Transfer Objects) ---

class HistorialMateria {
  final String nombreMateria;
  final String estadoDB;
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
  double get notaFinal {
    if (segundoTurno != null && segundoTurno! > 0) {
      return segundoTurno!;
    }
    if (examenFinal != null && examenFinal! > 0) {
      return examenFinal!;
    }
    if (parcial1 != null && parcial2 != null) {
      return (parcial1! + parcial2!) / 2;
    }
    return 0;
  }

  // 🚨 ======================================================
  // 🚨 FIX 1: "Retirada" ahora es un estado válido
  // 🚨 ======================================================
  String get estadoCalculado {
    if (estadoDB.toLowerCase() == 'retirada') {
      return "Retirada";
    }
    if (estadoDB.toLowerCase() == 'cursando') {
      return "Cursando";
    }
    if (notaFinal > 50) {
      return "Aprobado";
    } else {
      if (notaFinal > 0) {
        return "Reprobado";
      }
      return "Sin nota final";
    }
  }

  String get lecturaTts {
    if (estadoDB.toLowerCase() == 'cursando') {
      return 'Materia: $nombreMateria. Estado: Cursando. '
          'Primer Parcial: ${parcial1?.toStringAsFixed(0) ?? 'sin nota'}. '
          'Segundo Parcial: ${parcial2?.toStringAsFixed(0) ?? 'sin nota'}.';
    }
    // 🚨 FIX 1: "Retirada" ahora es un estado válido
    if (estadoDB.toLowerCase() == 'retirada') {
      return 'Materia: $nombreMateria. Estado: Retirada.';
    }
    return 'Materia: $nombreMateria. Estado: $estadoCalculado. '
        'Nota Final: ${notaFinal.toStringAsFixed(0)}. '
        'Primer Parcial: ${parcial1?.toStringAsFixed(0) ?? 'sin nota'}. '
        'Segundo Parcial: ${parcial2?.toStringAsFixed(0) ?? 'sin nota'}. '
        'Examen Final: ${examenFinal?.toStringAsFixed(0) ?? 'sin nota'}. '
        'Segundo Turno: ${segundoTurno?.toStringAsFixed(0) ?? 'no aplica'}.';
  }
}

enum EstadoInscripcionParalelo {
  ninguno,
  inscrito,
  solicitado,
  // 🚨 Retirado ya no es un estado, se borra la fila
}

class ParaleloSimple {
  final int idParalelo;
  final String nombreParalelo;
  final String docenteNombre;
  final String docenteApellido;
  final String aula;
  final int idMateria;
  final int creditos;
  final EstadoInscripcionParalelo estadoEstudiante;

  ParaleloSimple({
    required this.idParalelo,
    required this.nombreParalelo,
    required this.docenteNombre,
    required this.docenteApellido,
    required this.aula,
    required this.idMateria,
    required this.creditos,
    required this.estadoEstudiante,
  });

  factory ParaleloSimple.fromMap(Map<String, dynamic> map) {
    EstadoInscripcionParalelo estado = EstadoInscripcionParalelo.ninguno;
    if (map['estado_inscripcion'] != null) {
      if (map['estado_inscripcion'] == 'Cursando') {
        estado = EstadoInscripcionParalelo.inscrito;
      }
      // 🚨 FIX 1: Si está 'Retirada', la tratamos como 'ninguno'
      // porque el 'DELETE' en el repo falló o aún no se ha ejecutado.
      // El estado 'Retirada' ya no debería existir en la lógica de inscripción.
      else if (map['estado_inscripcion'] == 'Retirada') {
        estado = EstadoInscripcionParalelo.ninguno;
      }
    } else if (map['estado_solicitud'] != null) {
      if (map['estado_solicitud'] == 'En Espera') {
        estado = EstadoInscripcionParalelo.solicitado;
      }
    }

    return ParaleloSimple(
      idParalelo: map['id_paralelo'] as int,
      nombreParalelo: map['nombre_paralelo'] as String,
      docenteNombre: map['docente_nombre'] as String,
      docenteApellido: map['docente_apellido'] as String,
      aula: map['aula_nombre'] ?? 'Sin aula',
      idMateria: map['id_materia'] as int,
      creditos: map['creditos'] as int,
      estadoEstudiante: estado,
    );
  }
}

/// DTO "Rico" que combina toda la info para la página de inscripción
class ParaleloDetalleCompleto {
  final ParaleloSimple paralelo;
  final String horarios; // Ej: "Lunes 08:00-10:00" (Crudo)
  final String requisitos;
  final bool cumpleRequisitos;

  ParaleloDetalleCompleto({
    required this.paralelo,
    required this.horarios,
    required this.requisitos,
    required this.cumpleRequisitos,
  });

  int get idParalelo => paralelo.idParalelo;
  int get idMateria => paralelo.idMateria;
  EstadoInscripcionParalelo get estadoEstudiante => paralelo.estadoEstudiante;

  String get textoBoton {
    switch (estadoEstudiante) {
      case EstadoInscripcionParalelo.inscrito:
        return "Retirar Materia";
      case EstadoInscripcionParalelo.solicitado:
        return "Cancelar Solicitud";
      case EstadoInscripcionParalelo.ninguno:
        return cumpleRequisitos ? "Inscribirse" : "Solicitar (Req. P.)";
    }
  }

  /// Devuelve el texto "crudo". La UI (página) se encargará de formatearlo.
  String get lecturaTts {
    String texto =
        "Paralelo ${paralelo.nombreParalelo}. "
        "Docente: ${paralelo.docenteNombre} ${paralelo.docenteApellido}. "
        "Aula: ${paralelo.aula}. "
        "Horarios: $horarios. "
        "Créditos: ${paralelo.creditos}. ";

    if (requisitos.isEmpty) {
      texto += "No tiene requisitos. ";
    } else {
      texto += "$requisitos. ";
      texto +=
          cumpleRequisitos
              ? "Usted CUMPLE los requisitos. "
              : "Usted NO CUMPLE los requisitos. ";
    }

    switch (estadoEstudiante) {
      case EstadoInscripcionParalelo.inscrito:
        texto +=
            "Estado: Ya estás inscrito. Presiona OK para retirar la materia.";
        break;
      case EstadoInscripcionParalelo.solicitado:
        texto +=
            "Estado: Solicitud enviada. Presiona OK para cancelar la solicitud.";
        break;
      case EstadoInscripcionParalelo.ninguno:
        if (cumpleRequisitos) {
          texto += "Presiona OK para inscribirte.";
        } else {
          texto += "Presiona OK para enviar una solicitud.";
        }
        break;
    }
    return texto;
  }
}
