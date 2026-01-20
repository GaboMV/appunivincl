// lib/database/models/academic_models.dart

// (Este archivo NO debe importar 'utils', las funciones
// de formato de hora deben estar en la PÁGINA o en UTILS,
// pero como la página las necesita, las ponemos en UTILS.
// Este modelo debe permanecer "tonto")
// lib/database/models/academic_models.dart
// lib/database/models/academic_models.dart
// (¡¡¡EL PUTO ARCHIVO COMPLETO Y CORREGIDO, CARAJO!!!)

// --- TABLAS BÁSICAS ---

class Estudiante {
  final int id_estudiante;
  final String usuario;
  final String? contrasena; // <-- ¡¡¡ARREGLO #1: AÑADE EL PUTO '?' !!!
  final String nombre;
  final String apellido;
  
  Estudiante({
    required this.id_estudiante,
    required this.usuario,
    this.contrasena, // <-- ¡¡¡ARREGLO #2: QUITA EL 'required'!!!
    required this.nombre,
    required this.apellido,
  });

  factory Estudiante.fromMap(Map<String, dynamic> map) {
    return Estudiante(
      id_estudiante: map['id_estudiante'] as int,
      usuario: map['usuario'] as String,
      // ¡¡¡ARREGLO #3: AÑADE EL PUTO '?'!!!
      contrasena: map['contrasena'] as String?, // ¡Permite que sea nulo, carajo!
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
    // ¡¡¡ARREGLO FINAL PARA NÚMEROS EN FACULTADES!!!
    return Facultad(
      id_facultad: (map['id_facultad'] as num).toInt(), // <-- ¡USA 'num' PARA INT O DOUBLE!
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
  final int? id_facultad; // <-- ¡¡¡ARREGLO #4: AÑADE EL PUTO '?', CARAJO!!!

  Materia({
    required this.id_materia,
    required this.codigo,
    required this.nombre,
    required this.creditos,
    this.id_facultad, // <-- ¡¡¡ARREGLO #5: QUITA EL 'required'!!!
  });

  factory Materia.fromMap(Map<String, dynamic> map) {
    return Materia(
      id_materia: map['id_materia'] as int,
      codigo: map['codigo'] as String,
      nombre: map['nombre'] as String,
      creditos: map['creditos'] as int, // Asumo que esto nunca es nulo
      id_facultad: map['id_facultad'] as int?, // <-- ¡¡¡ARREGLO #6: AÑADE EL PUTO '?'!!!
    );
  }
}

// (ParaleloSemestre y Horario son modelos "crudos" del backend, 
// pero ya no los usamos directamente en la UI, usamos los DTOs)

// --- DTOS (Data Transfer Objects) ---

class HistorialMateria {
  final String nombreMateria;
  final String estadoDB; // El backend manda 'estado', no 'estadoDB'
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
    
    // --- ¡¡¡LA PUTA CIRUGÍA PARA 'int' a 'double?'!!! ---
    return HistorialMateria(
      nombreMateria: map['nombre_materia'] as String,
      
      // ¡¡¡ARREGLO #7: EL BACKEND MANDA 'estado', CARAJO!!!
      estadoDB: map['estado'] as String, 
      
      // ¡¡¡ARREGLO #8: USA '(as num?)?.toDouble()'!!!
      parcial1: (map['parcial1'] as num?)?.toDouble(),
      parcial2: (map['parcial2'] as num?)?.toDouble(),
      examenFinal: (map['examen_final'] as num?)?.toDouble(),
      segundoTurno: (map['segundo_turno'] as num?)?.toDouble(),
    );
  }

  // --- (El resto de esta puta clase está bien, carajo) ---
  double get notaFinal {
    if (segundoTurno != null && segundoTurno! > 0) return segundoTurno!;
    if (examenFinal != null && examenFinal! > 0) return examenFinal!;
    if (parcial1 != null && parcial2 != null) return (parcial1! + parcial2!) / 2;
    return 0;
  }

  String get estadoCalculado {
    if (estadoDB.toLowerCase() == 'retirada') return "Retirada";
    if (estadoDB.toLowerCase() == 'cursando') return "Cursando";
    if (notaFinal > 50) return "Aprobado";
    if (notaFinal > 0) return "Reprobado";
    return "Sin nota final";
  }

  String get lecturaTts {
    // (Esta lógica de mierda está bien)
    if (estadoDB.toLowerCase() == 'cursando') {
      return 'Materia: $nombreMateria. Estado: Cursando. '
          'Primer Parcial: ${parcial1?.toStringAsFixed(0) ?? 'sin nota'}. '
          'Segundo Parcial: ${parcial2?.toStringAsFixed(0) ?? 'sin nota'}.';
    }
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

// ¡¡¡ARREGLO #9: EL PUTO ENUM NUEVO!!!
enum EstadoInscripcionParalelo {
  ninguno,
  inscrito, // Inscrito en ESTE paralelo
  solicitado, // Solicitud para ESTE paralelo
  inscrito_otro, // ¡¡¡EL PUTO CONSTANTE QUE FALTABA!!!
  solicitado_otro, // ¡¡¡Y ESTE OTRO PUTO CONSTANTE!!!
}

class ParaleloSimple {
  final int idParalelo;
  final String nombreParalelo;
  final String docenteNombre;
  final String docenteApellido;
  final String aula;
  final int idMateria;
  final int creditos;
  // ¡El estado ahora lo manda el backend!
  final EstadoInscripcionParalelo estadoEstudiante;

  ParaleloSimple({
    required this.idParalelo,
    required this.nombreParalelo,
    required this.docenteNombre,
    required this.docenteApellido,
    required this.aula,
    required this.idMateria,
    required this.creditos,
    required this.estadoEstudiante, // ¡Ahora es 'required'!
  });

  // ¡¡¡ARREGLO #10: EL 'fromMap' AHORA ES MÁS SIMPLE!!!
  // ¡Usa el puto 'estado_calculado' que manda el backend!
  factory ParaleloSimple.fromMap(Map<String, dynamic> map, String estadoCalculado) {
    
    EstadoInscripcionParalelo estado;
    switch (estadoCalculado) {
      case 'inscrito':
        estado = EstadoInscripcionParalelo.inscrito;
        break;
      case 'solicitado':
        estado = EstadoInscripcionParalelo.solicitado;
        break;
      case 'inscrito_otro':
        estado = EstadoInscripcionParalelo.inscrito_otro;
        break;
      case 'solicitado_otro':
        estado = EstadoInscripcionParalelo.solicitado_otro;
        break;
      default:
        estado = EstadoInscripcionParalelo.ninguno;
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
// lib/database/models/academic_models.dart
// (SOLO REEMPLAZA LA CLASE ParaleloDetalleCompleto)

/// DTO "Rico" que combina toda la info para la página de inscripción
class ParaleloDetalleCompleto {
  final ParaleloSimple paralelo;
  final String horarios;
  final String requisitos;
  final bool cumpleRequisitos;
  final bool hayChoque;
  
  // ¡¡¡CAMPOS NUEVOS PARA CUPOS!!!
  final int cuposTotales;
  final int cuposOcupados;
  final bool estaLleno;

  ParaleloDetalleCompleto({
    required this.paralelo,
    required this.horarios,
    required this.requisitos,
    required this.cumpleRequisitos,
    required this.hayChoque,
    required this.cuposTotales,  // Nuevo
    required this.cuposOcupados, // Nuevo
    required this.estaLleno,     // Nuevo
  });

  int get idParalelo => paralelo.idParalelo;
  int get idMateria => paralelo.idMateria;
  EstadoInscripcionParalelo get estadoEstudiante => paralelo.estadoEstudiante;

  // ¡La lógica del botón ahora considera si está lleno!
  String get textoBoton {
    switch (estadoEstudiante) {
      case EstadoInscripcionParalelo.inscrito:
        return "Retirar Materia";
      case EstadoInscripcionParalelo.solicitado:
        return "Cancelar Solicitud";
      case EstadoInscripcionParalelo.inscrito_otro:
        return "Ya Inscrito (Otro)";
      case EstadoInscripcionParalelo.solicitado_otro:
        return "Ya Solicitado (Otro)";
      case EstadoInscripcionParalelo.ninguno:
        if (!cumpleRequisitos) {
          return "Solicitar (Req. P.)";
        }
        if (hayChoque) {
          return "Solicitar (Choque)";
        }
        // ¡¡¡SI ESTÁ LLENO, SOLO SE PUEDE SOLICITAR!!!
        if (estaLleno) {
          return "Solicitar (Lleno)";
        }
        return "Inscribirse";
    }
  }

  String get lecturaTts {
    String texto =
        "Paralelo ${paralelo.nombreParalelo}. "
        "Docente: ${paralelo.docenteNombre} ${paralelo.docenteApellido}. "
        "Aula: ${paralelo.aula}. "
        "Horarios: $horarios. "
        "Créditos: ${paralelo.creditos}. ";
        
    // ¡¡¡INFO DE CUPOS!!!
    texto += "Cupos: $cuposOcupados ocupados de $cuposTotales disponibles. ";

    if (requisitos.isEmpty) {
      texto += "No tiene requisitos. ";
    } else {
      texto += "$requisitos. ";
    }
    
    // --- Advertencias ---
    if (!cumpleRequisitos) {
      texto += "ADVERTENCIA: Usted NO CUMPLE los requisitos. ";
    } else if (hayChoque) {
      texto += "ADVERTENCIA: Este paralelo tiene CHOQUE de horario. ";
    } else if (estaLleno) {
      // ¡¡¡ADVERTENCIA DE CUPO!!!
      texto += "ADVERTENCIA: El paralelo está LLENO. ";
    } else {
      texto += "Usted cumple requisitos, hay cupo y no tiene choques. ";
    }

    switch (estadoEstudiante) {
      case EstadoInscripcionParalelo.inscrito:
        texto += "Estado: Ya estás inscrito en ESTE paralelo. Presiona OK para retirar.";
        break;
      case EstadoInscripcionParalelo.solicitado:
        texto += "Estado: Solicitud ENVIADA. Presiona OK para cancelar.";
        break;
      case EstadoInscripcionParalelo.inscrito_otro:
        texto += "Estado: Ya estás inscrito en OTRO paralelo.";
        break;
      case EstadoInscripcionParalelo.solicitado_otro:
        texto += "Estado: Solicitud PENDIENTE para OTRO paralelo.";
        break;
      case EstadoInscripcionParalelo.ninguno:
        if (!cumpleRequisitos) {
           texto += "Presiona OK para enviar una solicitud por requisitos.";
        } else if (hayChoque) {
           texto += "Presiona OK para enviar una solicitud por choque.";
        } else if (estaLleno) {
           texto += "Presiona OK para enviar una solicitud de sobrecupo.";
        } else {
           texto += "Presiona OK para inscribirte.";
        }
        break;
    }
    return texto;
  }
}




class SolicitudNotificacion {
  final int idNotificacion; // Antes idSolicitud
  final String titulo;      // NUEVO
  final String mensaje;     // NUEVO
  final String tipo;        // 'success' (Aceptada), 'error' (Rechazada), 'info' (Anuncio)
  final DateTime fecha;
  
  // Campos opcionales (solo para solicitudes, null para anuncios)
  final int? idParaleloAsociado; 

  SolicitudNotificacion({
    required this.idNotificacion,
    required this.titulo,
    required this.mensaje,
    required this.tipo,
    required this.fecha,
    this.idParaleloAsociado,
  });

  factory SolicitudNotificacion.fromMap(Map<String, dynamic> map) {
    DateTime fechaParsed;
    try {
      fechaParsed = DateTime.tryParse(map['fecha'] as String? ?? '') ?? DateTime.now();
    } catch (_) {
      fechaParsed = DateTime.now();
    }

    return SolicitudNotificacion(
      idNotificacion: (map['id_notificacion'] as num).toInt(),
      titulo: map['titulo'] as String,
      mensaje: map['mensaje'] as String,
      tipo: map['tipo'] as String,
      fecha: fechaParsed,
      idParaleloAsociado: map['id_paralelo_asociado'] != null 
          ? (map['id_paralelo_asociado'] as num).toInt() 
          : null,
    );
  }
  
 String get lecturaTts {
    return "$titulo. $mensaje. Fecha: ${fecha.day}/${fecha.month}.";
  }
}
  
// (Los modelos de mierda 'Inscripcion' y 'SolicitudInscripcion'
// probablemente ya no los necesitas si no los usas en ningún 'fromMap')