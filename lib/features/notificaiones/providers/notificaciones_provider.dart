// lib/features/notificaciones/providers/notificaciones_provider.dart
// lib/features/notificaciones/providers/notificaciones_provider.dart
// (¡¡¡VERSIÓN SILENCIOSA - SOLO DATOS!!!)

import 'package:appuniv/core/tts_service.dart';
import 'package:appuniv/database/models/academic_models.dart';
import 'package:appuniv/features/session/providers/session_provider.dart';
import 'package:appuniv/services/api_service.dart';
import 'package:appuniv/services/socket_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:async';
import 'package:flutter/material.dart'; // Solo para debugPrint

part 'notificaciones_provider.g.dart';

const Duration _pollingInterval = Duration(seconds: 15);

// === 1. EL DETONADOR GLOBAL (SOCKET) ===
@Riverpod(keepAlive: true)
int socketTrigger(SocketTriggerRef ref) {
  final socketService = ref.watch(socketServiceProvider);
  
  final sub = socketService.newNotificationStream.listen((data) {
    debugPrint("LOG: [SOCKET EVENT] ¡Datos frescos! Incrementando trigger...");
    // ¡YA NO HABLA AQUÍ! Solo avisa a los demás providers.
    ref.state++; 
  });
  
  ref.onDispose(() => sub.cancel());
  return 0; 
}

// === 2. EL DETONADOR DE POLLING (TIMER) ===
@Riverpod(keepAlive: true)
Stream<int> _pollingTick(_PollingTickRef ref) {
    return Stream.periodic(_pollingInterval, (x) => x);
}

// === 3. PROVEEDOR DE LA LISTA (DATA) ===
@Riverpod(keepAlive: true)
Future<List<SolicitudNotificacion>> notificaciones(NotificacionesRef ref) async {
  final estudiante = ref.watch(sessionNotifierProvider).estudiante;
  if (estudiante == null) return [];
  
  ref.watch(socketTriggerProvider); // Escucha al socket
  ref.watch(_pollingTickProvider);  // Escucha al timer

  final api = ref.watch(apiServiceProvider);
  final jsonList = await api.getSolicitudesResueltas(estudiante.id_estudiante);

  return jsonList.map((json) => SolicitudNotificacion.fromMap(json as Map<String, dynamic>)).toList();
}


// === 4. PROVEEDOR DE CONTEO ===
@Riverpod(keepAlive: true)
int notificacionesNoLeidas(NotificacionesNoLeidasRef ref) {
    final notificacionesAsync = ref.watch(notificacionesProvider);

    return notificacionesAsync.when(
        data: (list) => list.length,
        loading: () => 0, 
        error: (e, s) => 0,
    );
    // ¡YA NO HABLA AQUÍ TAMPOCO!
}
@Riverpod(keepAlive: true)
void socketNotifRefresher(SocketNotifRefresherRef ref) {
  final socketService = ref.watch(socketServiceProvider);
  final tts = TtsService();

  // Escuchamos el stream del socket
  final sub = socketService.newNotificationStream.listen((data) {
    debugPrint("LOG: [SOCKET EVENT] ¡Datos frescos! Refrescando providers...");
    
    // 1. Alertar por voz INMEDIATAMENTE
    final titulo = data['titulo'] as String? ?? 'Atención';
    final mensaje = data['mensaje'] as String? ?? 'Tienes una actualización académica.';
    
    // Usamos un callback para asegurar que no choque con otros audios
    WidgetsBinding.instance.addPostFrameCallback((_) {
       tts.hablar("¡$titulo! $mensaje");
    });
    
    // 2. ¡INVALIDAR EL PROVIDER DE DATOS!
    ref.invalidate(notificacionesProvider); 
    
    // 3. ¡INVALIDAR HORARIOS SI ES NECESARIO! (Opcional, pero recomendado)
    // ref.invalidate(horarioEstudianteProvider);
  });

  ref.onDispose(() => sub.cancel());
}