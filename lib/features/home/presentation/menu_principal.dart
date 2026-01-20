// lib/features/home/pages/menu_principal_accesible.dart
// (¡¡¡VERSIÓN FINAL: NOTIFICACIONES + BLOQUEO DE SISTEMA + NAVEGACIÓN!!!)

import 'package:appuniv/features/historial/presentation/historial_academico_page.dart';
import 'package:appuniv/features/horarios/presentation/horarios_page.dart';
import 'package:appuniv/features/inscripciones/presentation/inscripcion_page.dart';
import 'package:appuniv/features/login/presentation/login.dart';
// IMPORTS DE NOTIFICACIONES

import 'package:appuniv/features/notificaiones/presentation/notificaciones_page.dart';
import 'package:appuniv/features/notificaiones/providers/notificaciones_provider.dart';
// IMPORT DE SISTEMA (BLOQUEO)
import 'package:appuniv/features/system/providers/system_provider.dart';
import 'package:appuniv/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appuniv/core/tts_service.dart';
import 'package:appuniv/features/session/providers/session_provider.dart';

class MenuPrincipalAccesible extends ConsumerStatefulWidget {
  const MenuPrincipalAccesible({super.key});

  @override
  ConsumerState<MenuPrincipalAccesible> createState() =>
      _MenuPrincipalAccesibleState();
}

class _MenuPrincipalAccesibleState
    extends ConsumerState<MenuPrincipalAccesible> {
  final tts = TtsService();
  int _campoActual = 0;
  
  // 0: Horarios, 1: Inscripciones, 2: Historial, 3: Notificaciones
  final List<String> _opciones = [
    "Ver Horarios del semestre actual",
    "Inscripciones y Solicitudes",
    "Historial de Notas",
    "Campana de Notificaciones", 
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
    if (_campoActual == 3) {
       final count = ref.read(notificacionesNoLeidasProvider);
       if (count > 0) {
         tts.hablar("Campana de Notificaciones. Tienes $count mensajes nuevos. Selecciona OK para abrir.");
       } else {
         tts.hablar("Campana de Notificaciones. No tienes mensajes nuevos. Selecciona OK para abrir.");
       }
    } else if (_campoActual < _opciones.length) {
      // Si es inscripción, avisamos si está bloqueado
      if (_campoActual == 1) {
          final activo = ref.read(systemStatusProvider);
          if (!activo) {
              tts.hablar("Inscripciones y Solicitudes. (Opción Cerrada por Administración).");
              return;
          }
      }
      tts.hablar(_opciones[_campoActual]);
    }
  }

  void _ejecutarAccion(int index) {
    String accion = "Abriendo ";
    tts.detener();

    switch (index) {
      case 0:
        accion += "Horarios.";
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const HorariosPageAccesible()),
        );
        break;
        
      case 1: // INSCRIPCIONES (¡CON BLOQUEO DE SEGURIDAD!)
        final inscripcionesActivas = ref.read(systemStatusProvider);
        
        if (!inscripcionesActivas) {
            tts.hablar("Error. Las inscripciones están CERRADAS por administración. No puedes entrar.");
            return; // ¡NO NAVEGA!
        }
        
        accion += "Inscripciones y Solicitudes.";
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const InscripcionPage(),
          ),
        );
        break;
        
      case 2:
        accion += "Historial Académico.";
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const HistorialAcademicoPage(),
          ),
        );
        break;
        
      case 3: // NOTIFICACIONES
        accion += "Bandeja de Notificaciones.";
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const NotificacionesPage(),
          ),
        );
        break;
    }
    tts.hablar(accion);
  }

  // ... (El código de _buildBoton se queda igual)
  Widget _buildBoton(String texto, IconData icono, int index, ColorScheme colors) {
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
          color: seleccionado ? colors.primary.withOpacity(0.1) : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
          border: seleccionado 
              ? Border.all(color: colors.primary, width: 2) 
              : Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(
              icono, 
              size: 30, 
              color: seleccionado ? colors.primary : Colors.grey[800]
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                texto,
                style: TextStyle(
                  color: colors.onSurface, 
                  fontSize: 24,
                  fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (seleccionado)
              Icon(Icons.arrow_forward_ios, color: colors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildBotonNotificacion(BuildContext context, ColorScheme colors) {
    final int notificacionesCount = ref.watch(notificacionesNoLeidasProvider);
    
    return IconButton(
      icon: Stack(
        alignment: Alignment.topRight,
        children: [
          const Icon(Icons.notifications, color: Colors.white, size: 30),
          if (notificacionesCount > 0)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colors.error, 
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 1),
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                '$notificacionesCount',
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
      onPressed: () {
        setState(() => _campoActual = 3); 
        String mensajeVoz = "No tienes notificaciones nuevas.";
        if (notificacionesCount > 0) {
           mensajeVoz = "Tienes $notificacionesCount notificaciones nuevas. Selecciona OK para verlas.";
        }
        tts.hablar(mensajeVoz);
      },
    );
  }

  // ... (_botonGrande se queda igual)
  Widget _botonGrande(String texto, IconData icono, VoidCallback accion, ColorScheme colors, {bool habilitado = true}) {
    return ElevatedButton(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final estudiante = ref.watch(sessionNotifierProvider).estudiante;
    
    // 1. LISTENER DE NOTIFICACIONES (Para hablar)
    ref.listen<int>(notificacionesNoLeidasProvider, (previous, next) {
        if (next > (previous ?? 0)) {
            // Solo hablamos si estamos en la pantalla principal
            if (ModalRoute.of(context)?.isCurrent ?? false) {
                final diferencia = next - (previous ?? 0);
                tts.hablar("¡Atención! Tienes $diferencia notificación académica nueva.");
            }
        }
    });
    
    // 2. LISTENER DE SISTEMA (Bloqueo/Desbloqueo en tiempo real)
    final inscripcionesActivas = ref.watch(systemStatusProvider); // Esto redibuja la UI si cambia
    
    ref.listen<bool>(systemStatusProvider, (prev, next) {
        // Solo hablamos si estamos en la pantalla principal
        if (ModalRoute.of(context)?.isCurrent ?? false) {
            if (next) {
                tts.hablar("Atención. Se han ABIERTO las inscripciones.");
            } else {
                tts.hablar("Atención. Se han CERRADO las inscripciones.");
            }
        }
    });
    
    // Mantenemos vivo el listener de sockets
    ref.watch(socketNotifRefresherProvider);

    const int totalOpciones = 4; 
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Expanded(
          child: Text(
            "Hola, ${estudiante?.nombre ?? 'Usuario'}",
            style: const TextStyle(color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        backgroundColor: Colors.grey[900],
        actions: [_buildBotonNotificacion(context, colors)],
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),
          _buildBoton(_opciones[0], Icons.calendar_today, 0, colors),
          
          // BOTÓN DE INSCRIPCIONES (Cambia si está bloqueado)
          _buildBoton(
              _opciones[1], 
              inscripcionesActivas ? Icons.app_registration : Icons.lock_outline, // Icono cambia
              1, 
              colors
          ),
          
          _buildBoton(_opciones[2], Icons.score, 2, colors),
          _buildBoton(_opciones[3], Icons.notifications_active, 3, colors),
          
          const Spacer(),
          _buildBotonesAccesibles(totalOpciones, colors),
        ],
      ),
    );
  }

  Widget _buildBotonesAccesibles(int totalOpciones, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey[100], 
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
            }, colors),
          ),
          Expanded(
            child: _botonGrande("OK", Icons.check, () {
              _ejecutarAccion(_campoActual);
            }, colors),
          ),
          Expanded(
            child: _botonGrande("Sig", Icons.arrow_forward, () {
              setState(() {
                _campoActual = (_campoActual + 1) % totalOpciones;
              });
              _ttsCampoActual();
            }, colors),
          ),
          Expanded(
            child: _botonGrande("Salir", Icons.exit_to_app, () async {
              final sessionNotifier = ref.read(sessionNotifierProvider.notifier);

              tts.hablar("Cerrando sesión.");

              await sessionNotifier.logout();

              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginPageAccesible()),
                );
              }
            }, colors),
          ),
        ],
      ),
    );
  }
}