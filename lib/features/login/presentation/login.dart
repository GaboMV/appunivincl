// lib/features/login/pages/login_page_accesible.dart
// (¡¡¡VERSIÓN CON SEMÁNTICA EXPLÍCITA PARA TALKBACK/VOICEOVER!!!)

import 'package:appuniv/features/home/presentation/menu_principal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart'; // ¡IMPORTANTE PARA ACCESIBILIDAD!
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

// Servicios
import '../../../core/speech_service.dart';
import '../../../core/tts_service.dart';

// Proveedores
import '../providers/login_provider.dart';
import '../providers/login_state.dart';
import '../../session/providers/session_provider.dart';
import '../../session/providers/session_state.dart';

class LoginPageAccesible extends ConsumerStatefulWidget {
  const LoginPageAccesible({super.key});

  @override
  ConsumerState<LoginPageAccesible> createState() => _LoginPageAccesibleState();
}

class _LoginPageAccesibleState extends ConsumerState<LoginPageAccesible> {
  final tts = TtsService();
  final speech = SpeechService();
  int _campoActual = 0; // 0: Usuario, 1: Password, 2: Botón Ingresar
  bool _escuchando = false;

  @override
  void initState() {
    super.initState();
    _inicializarSpeech();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Anuncio inicial para el TTS interno de la app
      tts.hablar("Pantalla de inicio de sesión. Selecciona el campo usuario.");
    });
  }

  Future<void> _inicializarSpeech() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      tts.hablar("Permiso de micrófono denegado");
      return;
    }
    await speech.init();
  }

  @override
  Widget build(BuildContext context) {
    final login = ref.watch(loginNotifierProvider);
    final loginNotifier = ref.read(loginNotifierProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    // Listeners de estado
    ref.listen<SessionState>(sessionNotifierProvider, (prev, next) {
      if (next.isLoggedIn && !(prev?.isLoggedIn ?? false)) {
        tts.hablar("Inicio de sesión exitoso. Navegando al menú principal.");
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MenuPrincipalAccesible()),
        );
      }
    });

    ref.listen<LoginState>(loginNotifierProvider, (prev, next) {
      if (next.isLoading && !(prev?.isLoading ?? false)) {
        tts.hablar("Verificando credenciales...");
      }
      if (next.errorMessage != null && next.errorMessage != prev?.errorMessage && next.errorMessage!.isNotEmpty) {
        tts.hablar(next.errorMessage!);
        // SemanticsService.announce fuerza a TalkBack a leer el error
        SemanticsService.announce(next.errorMessage!, TextDirection.ltr);
      }
    });

    if (login.isLoading) {
      return  Scaffold(
        body: Center(
          child: Semantics(
            label: "Cargando, por favor espere",
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Semantics(
          // Agrupamos la pantalla para dar contexto
          label: "Formulario de Inicio de Sesión",
          child: Column(
            children: [
              const SizedBox(height: 40),
              Semantics(
                header: true, // ¡ESTO ES ACCESIBILIDAD! Marca como título.
                child: Text(
                  "Inicio de Sesión",
                  style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 28,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 30),
              
              // Campos con semántica explícita
              _buildCampo(
                "Usuario", 
                login.username, 
                _campoActual == 0, 
                colorScheme,
                hint: "Toca para seleccionar el campo usuario"
              ),
              
              _buildCampo(
                "Contraseña",
                login.password,
                _campoActual == 1,
                colorScheme,
                esPassword: true,
                hint: "Toca para seleccionar el campo contraseña"
              ),
              
              const SizedBox(height: 20),
              
              // Botón Ingresar Principal
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                child: Semantics(
                  button: true,
                  label: "Ingresar al sistema",
                  excludeSemantics: true,
                  hint: "valida tus credenciales",
                  enabled: !login.isLoading,
                  child: GestureDetector(
                    onTap: () async {
                      tts.hablar("Ingresando...");
                      await loginNotifier.login();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: _campoActual == 2
                            ? colorScheme.primary
                            : Colors.grey[400],
                        borderRadius: BorderRadius.circular(16),
                        border: _campoActual == 2
                            ? Border.all(color: colorScheme.onSurface, width: 2)
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          "Ingresar",
                          style: TextStyle(
                              fontSize: 20,
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Panel de control inferior
              _buildBotonesAccesibles(login, loginNotifier, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCampo(
    String label,
    String value,
    bool seleccionado,
    ColorScheme colors, {
    bool esPassword = false,
    String? hint,
  }) {
    return Semantics(
      // ¡AQUÍ ESTÁ LA SEMÁNTICA CARAJO!
      textField: true, // Le dice a TalkBack que esto es un campo de texto
      label: label, // "Usuario"
      value: value.isEmpty ? "Vacío" : (esPassword ? "Oculto" : value), // Lee el valor
      hint: hint, // Instrucción extra
      selected: seleccionado, // ¿Está el foco aquí?
      obscured: esPassword, // ¿Es contraseña?
      child: GestureDetector(
        onTap: () {
          setState(() => _campoActual = (label == "Usuario") ? 0 : 1);
          tts.hablar(label);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: seleccionado ? colors.primary.withOpacity(0.1) : Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
            border: seleccionado
                ? Border.all(color: colors.primary, width: 2)
                : Border.all(color: Colors.grey[400]!),
          ),
          child: Text(
            esPassword && value.isNotEmpty ? "*" * value.length : (value.isEmpty ? "..." : value),
            style: TextStyle(
                color: colors.onSurface,
                fontSize: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildBotonesAccesibles(LoginState login, LoginNotifier notifier, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey[100],
      // MergeSemantics agrupa esta zona para el lector
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: _botonGrande(
              "Atrás",
              Icons.arrow_back,
              "Mover foco al campo anterior", // Semántica extra
              () {
                setState(() {
                  _campoActual = (_campoActual - 1) < 0 ? 2 : _campoActual - 1;
                });
                _ttsCampoActual();
              },
              colors,
              habilitado: !_escuchando,
            ),
          ),
          Expanded(
            child: _botonGrande(
              _campoActual <= 1 ? (_escuchando ? "Detener" : "Mic") : "OK",
              _campoActual <= 1 ? (_escuchando ? Icons.stop : Icons.mic) : Icons.check,
              _campoActual <= 1 ? "Dictar texto por voz" : "Ejecutar acción de ingresar", // Semántica dinámica
              () async {
                if (_campoActual <= 1) {
                  if (!_escuchando) {
                    tts.hablar("Empiece a hablar");
                    await Future.delayed(const Duration(milliseconds: 800));
                    setState(() => _escuchando = true);
                    await speech.startListening();
                  } else {
                    final texto = await speech.stopListening();
                    if (texto.isNotEmpty) {
                      final textoLimpio = texto.trim();
                      if (_campoActual == 0) notifier.setUsername(textoLimpio);
                      if (_campoActual == 1) notifier.setPassword(textoLimpio);
                      tts.hablar("Ingresado: $textoLimpio");
                      // Avisar a TalkBack que el valor cambió
                      SemanticsService.announce("Texto ingresado: $textoLimpio", TextDirection.ltr);
                    } else {
                      tts.hablar("No se reconoció nada");
                    }
                    setState(() => _escuchando = false);
                  }
                } else {
                  tts.hablar("Ingresando...");
                  await notifier.login();
                }
              },
              colors,
            ),
          ),
          Expanded(
            child: _botonGrande(
              "Sig",
              Icons.arrow_forward,
              "Mover foco al siguiente campo",
              () {
                setState(() {
                  _campoActual = (_campoActual + 1) % 3;
                });
                _ttsCampoActual();
              },
              colors,
              habilitado: !_escuchando,
            ),
          ),
          Expanded(
            child: _botonGrande(
              "Elim",
              Icons.delete,
              "Borrar contenido del campo actual",
              () {
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
              colors,
              habilitado: !_escuchando,
            ),
          ),
        ],
      ),
    );
  }

  void _ttsCampoActual() {
    if (_campoActual == 0) tts.hablar("Campo usuario");
    else if (_campoActual == 1) tts.hablar("Campo contraseña");
    else tts.hablar("Botón ingresar");
  }

  Widget _botonGrande(
    String texto,
    IconData icono,
    String semanticLabel, // ¡Parámetro nuevo para accesibilidad!
    VoidCallback accion,
    ColorScheme colors, {
    bool habilitado = true,
  }) {
    return Semantics(
      button: true, // Es un botón
      label: "$texto. $semanticLabel", // "Atrás. Mover foco al campo anterior."
      enabled: habilitado,
      excludeSemantics: true, // Ignora el texto e icono de adentro, usa mi etiqueta
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: habilitado ? colors.primary : Colors.grey[400],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        ),
        onPressed: habilitado ? accion : null,
        child: Column(
          children: [
            Icon(
              icono,
              size: 30,
              color: Colors.white.withOpacity(habilitado ? 1.0 : 0.5),
            ),
            const SizedBox(height: 4),
            Text(
              texto,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(habilitado ? 1.0 : 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}