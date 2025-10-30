// lib/features/login/pages/login_page_accesible.dart
import 'package:appuniv/features/home/presentation/menu_principal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

// Servicios de voz
import '../../../core/speech_service.dart'; 
import '../../../core/tts_service.dart';

// Proveedores y Estados
import '../providers/login_provider.dart'; 
import '../providers/login_state.dart';
import '../../session/providers/session_provider.dart'; 
import '../../session/providers/session_state.dart'; 

// Pantalla de Navegación

class LoginPageAccesible extends ConsumerStatefulWidget {
  const LoginPageAccesible({super.key});

  @override
  ConsumerState<LoginPageAccesible> createState() => _LoginPageAccesibleState();
}

class _LoginPageAccesibleState extends ConsumerState<LoginPageAccesible> {
  final tts = TtsService();
  final speech = SpeechService();
  int _campoActual = 0;
  bool _escuchando = false;

  @override
  void initState() {
    super.initState();
    _inicializarSpeech();
    
    // 🚨 SOLUCIÓN DE CICLO DE VIDA: Solo dejamos el TTS inicial aquí 🚨
    WidgetsBinding.instance.addPostFrameCallback((_) {
      tts.hablar("Pantalla de inicio de sesión. Selecciona el campo usuario.");
    });
  }
  
  // No necesitamos didChangeDependencies ni dispose para los listeners con esta sintaxis segura.

  Future<void> _inicializarSpeech() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      tts.hablar("Permiso de micrófono denegado");
      return;
    }
    final disponible = await speech.init();
    if (!disponible) {
      tts.hablar("Reconocimiento de voz no disponible");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos los notifiers y estados
    final login = ref.watch(loginNotifierProvider); 
    final loginNotifier = ref.read(loginNotifierProvider.notifier);

    // 🚨 1. LISTENERS MOVIDOS AL MÉTODO BUILD 🚨
    // (Riverpod se encarga de la limpieza automática)
    
    // ESCUCHA DE SESIÓN (Para la navegación exitosa)
    ref.listen<SessionState>(sessionNotifierProvider, (prev, next) {
      if (next.isLoggedIn && !(prev?.isLoggedIn ?? false)) {
        tts.hablar("Inicio de sesión exitoso. Navegando al menú principal.");
        
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MenuPrincipalAccesible()),
        );
      }
    });

    // ESCUCHA DE LOGIN (Para errores de credenciales, validación y carga)
    ref.listen<LoginState>(loginNotifierProvider, (prev, next) {
      
      // Log y TTS para el inicio del proceso
      if (next.isLoading && !(prev?.isLoading ?? false)) {
          print('LOG: Iniciando proceso de autenticación...');
          tts.hablar("Verificando credenciales...");
      }

      // TTS para el error
      final bool errorDidAppear = next.errorMessage != null && next.errorMessage!.isNotEmpty;
      final bool errorIsDifferent = next.errorMessage != prev?.errorMessage;

      if (errorDidAppear && (errorIsDifferent || (prev?.errorMessage == null || prev!.errorMessage!.isEmpty))) {
        print('LOG ERROR: ${next.errorMessage}'); 
        tts.hablar(next.errorMessage!); 
      }
    });
    
    // 2. Indicador de carga bloqueante
    if (login.isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.greenAccent)),
      );
    }
    
    // 3. UI del Login
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Text(
              "Inicio de Sesión",
              style: TextStyle(color: Colors.white, fontSize: 28),
            ),
            const SizedBox(height: 30),
            _buildCampo("Usuario", login.username, _campoActual == 0),
            _buildCampo("Contraseña", login.password, _campoActual == 1, esPassword: true),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: GestureDetector(
                onTap: () async {
                  tts.hablar("Ingresando...");
                  await loginNotifier.login();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: _campoActual == 2 ? Colors.greenAccent : Colors.green,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text("Ingresar", style: TextStyle(fontSize: 20, color: Colors.white)),
                  ),
                ),
              ),
            ),
            const Spacer(),
            _buildBotonesAccesibles(login, loginNotifier),
          ],
        ),
      ),
    );
  }

  // --- MÉTODOS AUXILIARES (Sin Cambios) ---

  Widget _buildCampo(String label, String value, bool seleccionado, {bool esPassword = false}) {
    return GestureDetector(
      onTap: () {
        setState(() => _campoActual = (label == "Usuario") ? 0 : 1);
        tts.hablar(label);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: seleccionado ? Colors.blueGrey[700] : Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          esPassword ? "*" * value.length : value,
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }

  Widget _buildBotonesAccesibles(LoginState login, LoginNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey[850],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
            Expanded(child:
          _botonGrande(
            "Atrás", Icons.arrow_back, () {
              setState(() {
                _campoActual = (_campoActual - 1) < 0 ? 2 : _campoActual - 1;
              });
              _ttsCampoActual();
            },
            habilitado: !_escuchando,
          )),
          Expanded(child:
          _botonGrande(
            _campoActual <= 1 ? (_escuchando ? "Detener" : "Mic") : "OK",
            _campoActual <= 1 ? Icons.mic : Icons.check,
            () async {
              if (_campoActual <= 1) { // Lógica del Micrófono (Input)
                if (!_escuchando) {
                  tts.hablar("Empiece a hablar");
                  await Future.delayed(const Duration(milliseconds: 800));
                  setState(() => _escuchando = true);
                  await speech.startListening();
                } else {
                  final texto = await speech.stopListening();
                  if (texto.isNotEmpty) {
                    final textoLimpio = texto.trim(); 
                    if (_campoActual == 0) {
                      notifier.setUsername(textoLimpio);
                      print('LOG INPUT: Usuario ingresado: "$textoLimpio"');
                    }
                    if (_campoActual == 1) {
                      notifier.setPassword(textoLimpio);
                      print('LOG INPUT: Contraseña ingresada: "$textoLimpio"');
                    }
                    tts.hablar("Ingresado: $textoLimpio"); 
                  } else {
                    tts.hablar("No se reconoció nada");
                  }
                  setState(() => _escuchando = false);
                }
              } else { // Botón OK (Ingresar)
                print('LOG AUTH: Intentando login con Usuario: ${login.username} | Contraseña: ${login.password}');
                tts.hablar("Ingresando...");
                await notifier.login();
              }
            },
          )),
          Expanded(child:
          _botonGrande(
            "Sig", Icons.arrow_forward, () {
              setState(() {
                _campoActual = (_campoActual + 1) % 3;
              });
              _ttsCampoActual();
            },
            habilitado: !_escuchando,
          )),
          Expanded(child:
          _botonGrande(
            "Elim", Icons.delete, () {
              if (_campoActual == 0) {
                notifier.setUsername('');
                tts.hablar("Campo usuario borrado");
              } else if (_campoActual == 1) {
                notifier.setPassword('');
                tts.hablar("Campo contraseña borrado");
              } else {
                tts.hablar("Borrado deshabilitado en botones");
              }
            },
            habilitado: !_escuchando,
          )),
        ],
      ),
    );
  }

  void _ttsCampoActual() {
    if (_campoActual == 0) tts.hablar("Campo usuario");
    else if (_campoActual == 1) tts.hablar("Campo contraseña");
    else tts.hablar("Botón ingresar");
  }

  Widget _botonGrande(String texto, IconData icono, VoidCallback accion, {bool habilitado = true}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: habilitado ? Colors.blueGrey : Colors.grey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
      onPressed: habilitado ? accion : null,
      child: Column(
        children: [
          Icon(icono, size: 32, color: Colors.white),
          const SizedBox(height: 8),
          Text(texto, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}