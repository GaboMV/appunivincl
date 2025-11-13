// lib/features/home/pages/menu_principal_accesible.dart

import 'package:appuniv/features/historial/presentation/historial_academico_page.dart';
import 'package:appuniv/features/horarios/presentation/horarios_page.dart';
import 'package:appuniv/features/inscripciones/presentation/inscripcion_page.dart';
import 'package:appuniv/features/login/presentation/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appuniv/core/tts_service.dart';
import 'package:appuniv/features/session/providers/session_provider.dart';
// Asegúrate de importar tus pantallas secundarias aquí cuando las crees

class MenuPrincipalAccesible extends ConsumerStatefulWidget {
  const MenuPrincipalAccesible({super.key});

  @override
  ConsumerState<MenuPrincipalAccesible> createState() =>
      _MenuPrincipalAccesibleState();
}

class _MenuPrincipalAccesibleState
    extends ConsumerState<MenuPrincipalAccesible> {
  final tts = TtsService();
  int _campoActual =
      0; // 0: Horarios, 1: Inscripciones, 2: Historial, 3: Notificaciones

  // Nombres de los botones para la lectura de pantalla
  final List<String> _opciones = [
    "Ver Horarios del semestre actual",
    "Inscripciones y Solicitudes",
    "Historial de Notas",
  ];

  @override
  void initState() {
    super.initState();
    final estudiante = ref.read(sessionNotifierProvider).estudiante;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      tts.hablar(
        "Menú principal. Bienvenido ${estudiante?.nombre ?? ''}. Selecciona Horarios.",
      );
    });
  }

  void _ttsCampoActual() {
    if (_campoActual < _opciones.length) {
      tts.hablar(_opciones[_campoActual]);
    } else if (_campoActual == 3) {
      tts.hablar("Campana de Notificaciones. Selecciona OK para ver.");
    }
  }

  void _ejecutarAccion(int index) {
    String accion = "Abriendo ";
    tts.detener(); // Detener el TTS antes de navegar/ejecutar

    switch (index) {
      case 0:
        accion += "Horarios.";
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const HorariosPageAccesible()),
        );
        break;
      case 1:
        accion += "Inscripciones y Solicitudes.";
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const InscripcionPage(), // Llama a la nueva página
        ));
        break;
      case 2:
        accion += "Historial Académico.";
        Navigator.of(context).push(
          MaterialPageRoute(
            // Llama a la nueva página única
            builder: (_) => const HistorialAcademicoPage(),
          ),
        );
        break;
    }
    tts.hablar(accion);
  }

  // Widget _buildBoton, _buildBotonNotificacion, _botonGrande se mantienen igual que en la respuesta anterior
  // -----------------------------------------------------------------------------------------------------

  Widget _buildBoton(String texto, IconData icono, int index) {
    final bool seleccionado = _campoActual == index;
    return GestureDetector(
      onTap: () {
        setState(() => _campoActual = index);
        _ttsCampoActual();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: seleccionado ? Colors.indigo.shade700 : Colors.indigo.shade900,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icono, size: 30, color: Colors.white),
            const SizedBox(width: 20),
            Text(
              texto,
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
            const Spacer(),
            if (seleccionado)
              const Icon(Icons.arrow_forward_ios, color: Colors.white70),
          ],
        ),
      ),
    );
  }

  Widget _buildBotonNotificacion(BuildContext context) {
    final int notificaciones = 3;

    return IconButton(
      icon: Stack(
        alignment: Alignment.topRight,
        children: [
          const Icon(Icons.notifications, color: Colors.white, size: 30),
          if (notificaciones > 0)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                '$notificaciones',
                style: const TextStyle(color: Colors.white, fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
      onPressed: () {
        setState(() => _campoActual = 3); // La opción 3 es la campana
        tts.hablar(
          "Tienes $notificaciones notificaciones nuevas. Selecciona OK para ver.",
        );
      },
    );
  }

  Widget _botonGrande(
    String texto,
    IconData icono,
    VoidCallback accion, {
    bool habilitado = true,
  }) {
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

  // -----------------------------------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final estudiante = ref.watch(sessionNotifierProvider).estudiante;

    // Definimos el número total de opciones accesibles (3 botones + la campana)
    const int totalOpciones = 4;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "Hola, ${estudiante?.nombre ?? 'Usuario'}",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[900],
        actions: [_buildBotonNotificacion(context)],
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),
          _buildBoton(_opciones[0], Icons.calendar_today, 0),
          _buildBoton(_opciones[1], Icons.app_registration, 1),
          _buildBoton(_opciones[2], Icons.score, 2),
          const Spacer(),
          // Panel inferior para la navegación accesible
          _buildBotonesAccesibles(totalOpciones),
        ],
      ),
    );
  }

  Widget _buildBotonesAccesibles(int totalOpciones) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey[850],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: _botonGrande("Atrás", Icons.arrow_back, () {
              setState(() {
                _campoActual =
                    (_campoActual - 1 + totalOpciones) % totalOpciones;
              });
              _ttsCampoActual();
            }),
          ),
          Expanded(
            child: _botonGrande("OK", Icons.check, () {
              if (_campoActual == 3) {
                tts.hablar("Abriendo panel de notificaciones.");
                // Lógica para notificaciones
              } else {
                _ejecutarAccion(_campoActual);
              }
            }),
          ),
          Expanded(
            child: _botonGrande("Sig", Icons.arrow_forward, () {
              setState(() {
                _campoActual = (_campoActual + 1) % totalOpciones;
              });
              _ttsCampoActual();
            }),
          ),
          Expanded(
            child: _botonGrande("Salir", Icons.exit_to_app, () {
              final sessionNotifier = ref.read(
                sessionNotifierProvider.notifier,
              );
              tts.hablar("Cerrando sesión.");
              sessionNotifier.logout();
              // Navega de vuelta al login
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginPageAccesible()),
              );
            }),
          ),
        ],
      ),
    );
  }
}
