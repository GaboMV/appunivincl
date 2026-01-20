import 'package:appuniv/services/api_service.dart';
import 'package:appuniv/services/socket_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/material.dart'; 
import 'package:appuniv/core/tts_service.dart';

part 'system_provider.g.dart';

@Riverpod(keepAlive: true)
class SystemStatus extends _$SystemStatus {
  @override
  bool build() {
    // 1. Escuchar Socket para cambios en tiempo real
    final socketService = ref.watch(socketServiceProvider);
    
    // Nos suscribimos al evento específico de sistema
    socketService.socket.on('cambio_estado_sistema', (data) {
        final nuevoEstado = data['inscripciones_activas'] as bool;
        state = nuevoEstado; // Actualizamos el estado
        
        // Feedback de voz inmediato
        final tts = TtsService();
        if (nuevoEstado) {
            tts.hablar("Atención. Las inscripciones se han ABIERTO.");
        } else {
            tts.hablar("Atención. Las inscripciones se han CERRADO por administración.");
        }
    });
    
    // 2. Cargar estado inicial de la API
    _cargarEstadoInicial();
    
    return true; // Por defecto asumimos abierto mientras carga
  }

  Future<void> _cargarEstadoInicial() async {
      final api = ref.read(apiServiceProvider);
      final estado = await api.getSystemStatus();
      state = estado;
  }
}