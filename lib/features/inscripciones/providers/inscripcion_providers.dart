// lib/features/inscripciones/providers/inscripcion_providers.dart
// (¡¡¡LA PUTA VERSIÓN CORREGIDA QUE BUSCA 'paralelo' Y NO 'paralelo_crudo'!!!)

import 'package:appuniv/features/notificaiones/providers/notificaciones_provider.dart';
import 'package:appuniv/services/api_service.dart';
import 'package:appuniv/database/models/academic_models.dart'; // ¡Tus modelos DTO! (Revisa esta ruta)
import 'package:appuniv/features/historial/providers/historial_providers.dart';
import 'package:appuniv/features/horarios/providers/horarios_provider.dart';
import 'package:appuniv/features/session/providers/session_provider.dart';
import 'package:appuniv/utils/date_utils.dart'; 
import 'package:flutter/material.dart'; 
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inscripcion_providers.g.dart';

// === PROVEEDORES DE LECTURA (GET) ===

@Riverpod(keepAlive: true)
Future<List<Facultad>> facultades(FacultadesRef ref) {
  print("INSCRIPCION_PROVIDER: Pidiendo facultades...");
  final api = ref.watch(apiServiceProvider);
  return api.getAllFacultades().then(
    (jsonList) {
      try {
        print("INSCRIPCION_PROVIDER (Facultades): ¡JSON recibido! Parseando ${jsonList.length} facultades.");
        return jsonList.map((json) => Facultad.fromMap(json)).toList();
      } catch (e) {
        print("INSCRIPCION_PROVIDER (Facultades ERROR): ¡La cagó el parseo! $e");
        rethrow;
      }
    }
  );
}

@Riverpod(keepAlive: true)
Future<List<Materia>> materiasPorFacultad(
  MateriasPorFacultadRef ref,
  int idFacultad,
) {
  print("INSCRIPCION_PROVIDER: Pidiendo materias para facultad $idFacultad...");
  final api = ref.watch(apiServiceProvider);
  return api.getMateriasByFacultad(idFacultad).then(
    (jsonList) {
      try {
        print("INSCRIPCION_PROVIDER (Materias Fac): ¡JSON recibido! Parseando ${jsonList.length} materias.");
        return jsonList.map((json) => Materia.fromMap(json)).toList();
      } catch (e) {
        print("INSCRIPCION_PROVIDER (Materias Fac ERROR): ¡La cagó el parseo! $e");
        rethrow;
      }
    }
  );
}

@Riverpod(keepAlive: true)
Future<List<Materia>> materiasPorBusqueda(
  MateriasPorBusquedaRef ref,
  String query,
) {
  if (query.trim().isEmpty) {
    return Future.value([]);
  }
  print("INSCRIPCION_PROVIDER: Buscando materias con '$query'...");
  final api = ref.watch(apiServiceProvider);
  return api.searchMaterias(query).then(
    (jsonList) {
      try {
        print("INSCRIPCION_PROVIDER (Materias Busq): ¡JSON recibido! Parseando ${jsonList.length} materias.");
        return jsonList.map((json) => Materia.fromMap(json)).toList();
      } catch (e) {
        print("INSCRIPCION_PROVIDER (Materias Busq ERROR): ¡La cagó el parseo! $e");
        rethrow;
      }
    }
  );
}

@Riverpod(keepAlive: true)
Future<List<ParaleloDetalleCompleto>> paralelosMateria(
  ParalelosMateriaRef ref,
  int idMateria,
) async {
    ref.watch(socketTriggerProvider);
  ref.watch(socketTriggerProvider);
  print("INSCRIPCION_PROVIDER: Pidiendo paralelos para materia $idMateria...");
  
  final api = ref.watch(apiServiceProvider);
  final estudiante = ref.read(sessionNotifierProvider).estudiante;
  if (estudiante == null) throw Exception("No autenticado, carajo");

  const int idSemestreActual = 4; // ¡Asumido!
  
  print("INSCRIPCION_PROVIDER (Paralelos): Llamando a la API...");
  final jsonList = await api.getParalelosDetalle(
    idMateria,
    estudiante.id_estudiante,
    idSemestreActual,
  );
  print("INSCRIPCION_PROVIDER (Paralelos): ¡JSON recibido! Parseando ${jsonList.length} paralelos.");

  try {
    // ¡¡¡AQUÍ ESTÁ LA PUTA CORRECCIÓN, CARAJO!!!
    // ¡¡¡Cambié 'paralelo_crudo' por 'paralelo'!!!
    final paralelosCompletos = jsonList.map((jsonParalelo) {
      
      // ¡Parseamos el ParaleloSimple usando el 'paralelo' y el 'estado_calculado'!
      final paraleloSimple = ParaleloSimple.fromMap(
        jsonParalelo['paralelo'] as Map<String, dynamic>, // <-- ¡¡¡AQUÍ ESTÁ LA PUTA CORRECCIÓN!!!
        jsonParalelo['estado_calculado'] as String,
      );
      
      return ParaleloDetalleCompleto(
        paralelo: paraleloSimple, // ¡El DTO simple!
        horarios: jsonParalelo['horarios'] as String,
        requisitos: jsonParalelo['requisitos'] as String,
        cumpleRequisitos: jsonParalelo['cumpleRequisitos'] as bool,
        hayChoque: jsonParalelo['hayChoque'] as bool,
        cuposTotales: (jsonParalelo['cupos_totales'] as num).toInt(),
        cuposOcupados: (jsonParalelo['cupos_ocupados'] as num).toInt(),
        estaLleno: jsonParalelo['esta_lleno'] as bool,
      );
    }).toList();
    
    print("INSCRIPCION_PROVIDER (Paralelos): ¡Parseo exitoso, carajo!");
    return paralelosCompletos;

  } catch (e) {
    print("INSCRIPCION_PROVIDER (Paralelos ERROR): ¡La cagó el parseo! $e");
    // ¡Aquí es donde te salía el error de 'Null as int' si el modelo 'Materia' estaba mal!
    rethrow;
  }
}


// === PROVEEDOR DE ESCRITURA (POST) ===

@Riverpod(keepAlive: true)
class InscripcionService extends _$InscripcionService {
  @override
  void build() {}

  (Estudiante, ApiService, int) _getDependencies() {
    final estudiante = ref.read(sessionNotifierProvider).estudiante;
    if (estudiante == null) throw Exception("Usuario no autenticado, carajo");
    final api = ref.read(apiServiceProvider);
    const idSemestreActual = 4; // ¡Asumido!
    return (estudiante, api, idSemestreActual);
  }

  void _invalidateExternalCaches(int idMateria) {
    ref.invalidate(paralelosMateriaProvider(idMateria));
    ref.invalidate(historialSemestresProvider);
    ref.invalidate(historialMateriasProvider);
    ref.invalidate(horarioEstudianteProvider); 
    debugPrint("LOG: Caches de Historial, Paralelos y Horarios invalidadas.");
  }

  /// ¡LA LÓGICA DE MIERDA QUE ME PEDISTE!
 Future<String> inscribirOsolicitar(ParaleloDetalleCompleto paralelo) async {
    final (estudiante, api, idSemestreActual) = _getDependencies();
    final idEstudiante = estudiante.id_estudiante;
    final idParalelo = paralelo.idParalelo;

    debugPrint("--- 🟢 INSCRIPCION_SERVICE: ACCIÓN (API) ---");

    try {
      // REGLAS 5 & 6 (Retirar Inscripción/Solicitud)
      if (paralelo.estadoEstudiante == EstadoInscripcionParalelo.inscrito) {
        final respuesta = await api.retirarMateria(idEstudiante, idParalelo);
        _invalidateExternalCaches(paralelo.idMateria);
        return respuesta['message'] as String? ?? "Materia retirada exitosamente.";
      }

      if (paralelo.estadoEstudiante == EstadoInscripcionParalelo.solicitado) {
        final respuesta = await api.retirarSolicitud(idEstudiante, idParalelo);
        _invalidateExternalCaches(paralelo.idMateria);
        return respuesta['message'] as String? ?? "Solicitud cancelada.";
      }

      // REGLA 4: Bloquear (Ya inscrito/solicitado en Otro)
      if (paralelo.estadoEstudiante == EstadoInscripcionParalelo.inscrito_otro) {
          return "Error. Ya estás inscrito en esta materia en otro paralelo. Debes retirarla primero.";
      }
      if (paralelo.estadoEstudiante == EstadoInscripcionParalelo.solicitado_otro) {
          return "Error. Ya tienes una solicitud pendiente para esta materia. Cancela la solicitud original primero.";
      }

      // REGLAS 1, 2 y 3 (Inscribir, Req. Fallido, Choque)
      if (paralelo.estadoEstudiante == EstadoInscripcionParalelo.ninguno) {
        
        debugPrint("LOG: Estado 'ninguno'. Llamando a 'inscribir' (API)...");
        
        final Map<String, dynamic> respuesta = await api.inscribirMateria(
          idEstudiante, 
          idParalelo, 
          paralelo.idMateria, 
          idSemestreActual
        );

        _invalidateExternalCaches(paralelo.idMateria);
        
        // ¡El backend devolvió 201 (Inscrito) o 202 (Solicitud)!
        // ¡Devolvemos el puto mensaje amigable del backend!
        final mensaje = respuesta['message'] as String? ?? "Acción completada exitosamente.";
        debugPrint("LOG: ✅ ÉXITO: API respondió con $mensaje");
        return mensaje;
      }

      return "No se puede realizar la acción (Estado desconocido).";

    } catch (e) {
      // ¡¡¡AQUÍ ESTÁ LA PUTA CIRUGÍA PARA EL TTS!!!
      // El apiService devuelve "Exception: Error 409: Restricción ÚNICA..."
      final errorString = e.toString();
      
      if (errorString.contains('403') && errorString.contains('requisitos')) {
          return "Fallo en la inscripción. No cumples los requisitos. Debes enviar una solicitud por separado.";
      }
      if (errorString.contains('409') && errorString.contains('solicitud pendiente')) {
          return "Fallo en la inscripción. Ya tienes una solicitud para ESTE paralelo.";
      }
      if (errorString.contains('401') || errorString.contains('403')) {
          return "Tu sesión ha expirado. Por favor, inicia sesión de nuevo.";
      }
       if (errorString.contains('202')) {
          return "Se ha enviado una solicitud de inscripción. Espera la aprobación.";
      }
      
      // Si es un error de red o de servidor 500, devolvemos un mensaje genérico.
      return "Error de sistema inesperado. Intenta de nuevo.";
    }
  }
}