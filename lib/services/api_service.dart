// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api_service.g.dart';

// 🚨 URL DE TU BACKEND EN RENDER
const String _baseUrl = "https://univbackend.onrender.com";

@Riverpod(keepAlive: true)
ApiService apiService(ApiServiceRef ref) {
  return ApiService();
}

class ApiService {
  // 🚨 CONFIGURACIÓN CRÍTICA PARA ANDROID (Evita el error al volver a loguearse)
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  
  final _tokenKey = 'jwt_token';
  final _userKey = 'user_data';

  // ==================================================================
  // 🔒 GESTIÓN DE TOKEN Y STORAGE (LOGS AÑADIDOS)
  // ==================================================================

  Future<void> _saveToken(String token) async {
    print("💾 API_STORAGE: Guardando Token...");
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    print("💾 API_STORAGE: Guardando datos de usuario: $userData");
    await _storage.write(key: _userKey, value: jsonEncode(userData));
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<String?> getUserDataJson() async {
    return await _storage.read(key: _userKey);
  }

  // 🚨 FIX LOGOUT: USAR deleteAll PARA LIMPIAR TODO DE UNA VEZ
  Future<void> logout() async {
    print("🚪 API_AUTH: Ejecutando LOGOUT (Borrando todo el storage)...");
    try {
      await _storage.deleteAll();
      print("✅ API_AUTH: Logout completado. Storage limpio.");
    } catch (e) {
      print("❌ API_AUTH: Error al borrar storage: $e");
    }
  }

  // ==================================================================
  // 🛠️ HELPERS HTTP (HEADERS Y ERRORES)
  // ==================================================================

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await getToken();
    // print("🔑 API_HEADERS: Usando Token: ${token != null ? 'SI (Encontrado)' : 'NO (Nulo)'}");
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

  final Map<String, String> _publicPostHeaders = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  Exception _handleError(http.Response response) {
    print("🔥 API_ERROR: Status ${response.statusCode} | Body: ${response.body}");
    
    if (response.statusCode == 401 || response.statusCode == 403) {
      return Exception('Sesión expirada o inválida (401). Inicia sesión de nuevo.');
    }
    try {
      final data = jsonDecode(response.body);
      if (data['error'] != null) {
        return Exception(data['error']);
      }
      return Exception('Error del servidor: ${response.body}');
    } catch (e) {
      return Exception('Error desconocido (${response.statusCode}): ${response.body}');
    }
  }

  // ==================================================================
  // 🚀 1. AUTENTICACIÓN
  // ==================================================================

  Future<Map<String, dynamic>> login(String usuario, String contrasena) async {
    final url = Uri.parse('$_baseUrl/api/auth/login');
    print("🚀 API_LOGIN: POST $url con usuario '$usuario'");

    try {
      final response = await http.post(
        url,
        headers: _publicPostHeaders,
        body: jsonEncode({'usuario': usuario, 'contrasena': contrasena}),
      );

      print("📥 API_LOGIN: Respuesta ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        
        final token = data['token'];
        final estudianteData = data['estudiante'];

        if (token == null || estudianteData == null) {
          throw Exception('Respuesta de login incompleta (falta token o datos).');
        }

        await _saveToken(token);
        await _saveUserData(estudianteData);
        
        print("✅ API_LOGIN: Login ÉXITOSO. Datos guardados.");
        return data;
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      print("❌ API_LOGIN ERROR FATAL: $e");
      rethrow;
    }
  }

  // ==================================================================
  // 📚 2. MATERIAS (GET)
  // ==================================================================

  Future<List<dynamic>> getAllFacultades() async {
    return _getRequest('/api/materia/facultades');
  }

  Future<List<dynamic>> searchMaterias(String query) async {
    return _getRequest('/api/materia/search/$query');
  }

  Future<List<dynamic>> getMateriasByFacultad(int idFacultad) async {
    return _getRequest('/api/materia/by-facultad/$idFacultad');
  }

  Future<Map<String, dynamic>> getMateriaById(int idMateria) async {
    // Este devuelve un objeto, no una lista, así que lo hacemos manual
    final url = Uri.parse('$_baseUrl/api/materia/$idMateria');
    final response = await http.get(url, headers: await _getAuthHeaders());
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw _handleError(response);
    }
  }

  Future<List<dynamic>> getParalelosDetalle(int idMateria, int idEstudiante, int idSemestreActual) async {
    return _getRequest('/api/materia/paralelos/$idMateria/$idEstudiante/$idSemestreActual');
  }

  // ==================================================================
  // 📝 3. REGISTRO E INSCRIPCIONES (GET & POST)
  // ==================================================================

  Future<List<dynamic>> getSemestresInscritos(int idEstudiante) async {
    return _getRequest('/api/registro/semestres/$idEstudiante');
  }

  Future<List<dynamic>> getHistorialPorSemestre(int idEstudiante, int idSemestre) async {
    return _getRequest('/api/registro/historial/$idEstudiante/$idSemestre');
  }

Future<List<dynamic>> getHorarioEstudiante(int idEstudiante) async {
    // Ya no enviamos el semestre. El backend lo sabe por la base de datos.
  return _getRequest('/api/materia/estudiante/horario/$idEstudiante');
}

  Future<Map<String, dynamic>> inscribirMateria(int idEstudiante, int idParalelo, int idMateria, int idSemestreActual) async {
    return _postRequest('/api/registro/inscribir', {
      'idEstudiante': idEstudiante,
      'idParalelo': idParalelo,
      'idMateria': idMateria,
      'idSemestreActual': idSemestreActual
    }, expectedCode: 201);
  }

  Future<Map<String, dynamic>> retirarMateria(int idEstudiante, int idParalelo) async {
    return _postRequest('/api/registro/retirar', {
      'idEstudiante': idEstudiante,
      'idParalelo': idParalelo,
    });
  }

  Future<Map<String, dynamic>> enviarSolicitud(int idEstudiante, int idParalelo, String motivo) async {
    return _postRequest('/api/registro/solicitud/enviar', {
      'idEstudiante': idEstudiante,
      'idParalelo': idParalelo,
      'motivo': motivo,
    }, expectedCode: 201);
  }

  Future<Map<String, dynamic>> retirarSolicitud(int idEstudiante, int idParalelo) async {
    return _postRequest('/api/registro/solicitud/retirar', {
      'idEstudiante': idEstudiante,
      'idParalelo': idParalelo,
    });
  }

  // ==================================================================
  // 🔔 4. NOTIFICACIONES (NUEVO)
  // ==================================================================

  Future<List<dynamic>> getNotificaciones(int idEstudiante) async {
    // Asumiendo que tienes este endpoint en el backend
    // Si no lo tienes aún, esto fallará (404), pero la estructura está lista.
    try {
      return await _getRequest('/api/registro/notificaciones/$idEstudiante');
    } catch (e) {
      print("⚠️ API_NOTIF: Endpoint no encontrado o error: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>> marcarNotificacionLeida(int idNotificacion) async {
     return _postRequest('/api/registro/notificaciones/marcar-leida', {
      'idNotificacion': idNotificacion,
    });
  }


  // ==================================================================
  // 🛠️ HELPERS PRIVADOS PARA EVITAR REPETIR CÓDIGO
  // ==================================================================

  Future<List<dynamic>> _getRequest(String path) async {
    final url = Uri.parse('$_baseUrl$path');
    print("📡 API_GET: $url");
    
    try {
      final response = await http.get(url, headers: await _getAuthHeaders());
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      print("❌ API_GET ERROR en $path: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _postRequest(String path, Map<String, dynamic> body, {int expectedCode = 200}) async {
    final url = Uri.parse('$_baseUrl$path');
    print("🚀 API_POST: $url | Data: $body");

    try {
      final response = await http.post(
        url,
        headers: await _getAuthHeaders(),
        body: jsonEncode(body),
      );
      
      print("📥 API_POST RESP: ${response.statusCode}");

      // Aceptamos el código esperado (ej: 201 Created) o 200 OK, o 202 Accepted
      if (response.statusCode == expectedCode || response.statusCode == 200 || response.statusCode == 202) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      print("❌ API_POST ERROR en $path: $e");
      rethrow;
    }
  }
  Future<List<dynamic>> getSolicitudesResueltas(int idEstudiante) async {
    // ¡OJO A LA RUTA! Ahora es /notificaciones/
    final url = Uri.parse('$_baseUrl/api/registro/notificaciones/$idEstudiante');
    
    final response = await http.get(url, headers: await _getAuthHeaders());
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw _handleError(response);
    }
  }

  // 2. DELETE NOTIFICACION (Nueva Ruta)
  // Nota: Cambié el nombre del argumento a idNotificacion para ser claro
  Future<Map<String, dynamic>> deleteSolicitudResuelta(int idNotificacion, int idEstudiante) async {
    // ¡OJO A LA RUTA! Ahora es /notificaciones/
    final url = Uri.parse('$_baseUrl/api/registro/notificaciones/$idNotificacion');
    
    // El backend no pide body para borrar por ID, pero lo dejamos por si acaso
    final response = await http.delete(
        url, 
        headers: await _getAuthHeaders(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw _handleError(response);
    }
  }
  Future<bool> getSystemStatus() async {
    final url = Uri.parse('$_baseUrl/api/registro/sistema/estado');
    try {
        final response = await http.get(url, headers: await _getAuthHeaders());
        if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            return data['inscripciones_activas'] as bool;
        }
    } catch (e) {
        print("Error obteniendo estado sistema: $e");
    }
    return true; // Por defecto abierto si falla
  }
}