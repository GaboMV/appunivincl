// lib/features/session/providers/session_provider.dart

import 'dart:convert';
import 'package:appuniv/database/models/academic_models.dart';
import 'package:appuniv/services/api_service.dart';
import 'package:appuniv/services/socket_service.dart'; // ¡IMPORTA ESTO!
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'session_state.dart'; 

part 'session_provider.g.dart';

@riverpod
class SessionNotifier extends _$SessionNotifier {
  
  @override
  SessionState build() {
    return SessionState(estudiante: null, isLoggedIn: false); 
  }

  void setSession(Estudiante estudiante) {
    state = SessionState(estudiante: estudiante, isLoggedIn: true);
    
    // 🚨 ¡ENCENDEMOS EL SOCKET AL ENTRAR! 🚨
    ref.read(socketServiceProvider).connect(estudiante.id_estudiante);
  }
  
  Future<void> logout() async {
    final apiService = ref.read(apiServiceProvider);
    
    // 🚨 ¡APAGAMOS EL SOCKET AL SALIR! 🚨
    ref.read(socketServiceProvider).disconnect();
    
    await apiService.logout(); 
    state = SessionState(estudiante: null, isLoggedIn: false);
  }
  
  Future<bool> initializeSession() async {
      final apiService = ref.read(apiServiceProvider);
      final token = await apiService.getToken();
      final userJson = await apiService.getUserDataJson();
      
      if (token != null && userJson != null) {
          try {
              final userMap = jsonDecode(userJson) as Map<String, dynamic>;
              final estudiante = Estudiante.fromMap(userMap);
              
              // ¡Al restaurar sesión, también conectamos el socket!
              setSession(estudiante); 
              return true;
          } catch (e) {
              await apiService.logout();
              return false;
          }
      }
      return false; 
  }
}