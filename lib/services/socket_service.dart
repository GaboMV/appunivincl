// lib/services/socket_service.dart

import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'socket_service.g.dart';

// ¡TU URL DE RENDER (SIN /api)!
const String _socketUrl = "https://univbackend.onrender.com"; 

@Riverpod(keepAlive: true)
SocketService socketService(SocketServiceRef ref) {
  return SocketService();
}

class SocketService {
  late io.Socket socket;

  // Este Stream es el "megáfono" que avisa al resto de la app
  final _notifController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get newNotificationStream => _notifController.stream;

  SocketService() {
    _initSocket();
  }

  void _initSocket() {
    try {
      socket = io.io(
        _socketUrl,
        io.OptionBuilder()
          .setTransports(['websocket']) // ¡Forzar Websocket, nada de polling de mierda!
          .enableForceNewConnection()
          .disableAutoConnect() // Esperamos al login
          .build(),
      );
      
      socket.onConnect((_) => debugPrint('✅ SOCKET: Conectado a $_socketUrl'));
      socket.onDisconnect((_) => debugPrint('❌ SOCKET: Desconectado.'));
      
      // 🚨 ¡AQUÍ LLEGA LA MIERDA DEL BACKEND! 🚨
      socket.on('nueva_notificacion', (data) {
        debugPrint('🔔 SOCKET PUSH RECIBIDO: $data');
        // Metemos los datos en el stream para que los providers reaccionen
        _notifController.add(data as Map<String, dynamic>);
      });

    } catch (e) {
      debugPrint('💀 SOCKET ERROR FATAL: $e');
    }
  }

  // Se llama cuando el usuario hace Login
  void connect(int userId) {
    if (socket.connected) return;
    socket.connect();
    // Le decimos al servidor: "Soy el usuario X, méteme en mi sala privada"
    socket.emit('identificarse', userId); 
    debugPrint('SOCKET: Identificando al usuario $userId');
  }

  // Se llama en Logout
  void disconnect() {
    if (socket.connected) socket.disconnect();
  }
}