// lib/features/notificaciones/pages/notificaciones_page.dart
// (¡¡¡VERSIÓN CORREGIDA: SEMÁNTICA ARREGLADA Y TEXTOS VISIBLES!!!)

import 'package:appuniv/core/tts_service.dart';
import 'package:appuniv/database/models/academic_models.dart';
import 'package:appuniv/features/notificaiones/providers/notificaciones_provider.dart';
import 'package:appuniv/features/session/providers/session_provider.dart';
import 'package:appuniv/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart'; // ¡IMPORTANTE!
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificacionesPage extends ConsumerStatefulWidget {
  const NotificacionesPage({super.key});

  @override
  ConsumerState<NotificacionesPage> createState() => _NotificacionesPageState();
}

class _NotificacionesPageState extends ConsumerState<NotificacionesPage> {
  final tts = TtsService();
  
  int _idxNotificacion = 0;
  List<SolicitudNotificacion> _listaNotificaciones = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _leerEstadoInicial();
    });
  }

  void _leerEstadoInicial() {
    final asyncData = ref.read(notificacionesProvider);
    
    if (asyncData.hasValue && asyncData.value!.isNotEmpty) {
        final primera = asyncData.value![0];
        tts.hablar(
            "Bandeja de notificaciones. Tienes ${asyncData.value!.length} mensajes. "
            "Primer mensaje: ${primera.titulo}. ${primera.mensaje}. "
            "Presiona OK para confirmar y borrar."
        );
    } else {
        tts.hablar("Bandeja de notificaciones vacía. Presiona Volver para salir.");
    }
  }

  void _navegar(int direccion) {
    if (_listaNotificaciones.isEmpty) {
        tts.hablar("Lista vacía.");
        return;
    }

    setState(() {
        _idxNotificacion = (_idxNotificacion + direccion + _listaNotificaciones.length) % _listaNotificaciones.length;
    });
    
    final noti = _listaNotificaciones[_idxNotificacion];
    
    tts.hablar(
        "Mensaje ${_idxNotificacion + 1}. "
        "${noti.titulo}. " 
        "${noti.mensaje}. " 
        "Fecha: ${noti.fecha.day}/${noti.fecha.month}. "
        "Presiona OK para borrar."
    );
  }

  void _ejecutarAccion() {
    if (_listaNotificaciones.isEmpty) return;
    final noti = _listaNotificaciones[_idxNotificacion];
    _confirmarYBorrar(noti);
  }

  Future<void> _confirmarYBorrar(SolicitudNotificacion noti) async {
      final api = ref.read(apiServiceProvider);
      final estudiante = ref.read(sessionNotifierProvider).estudiante;
      
      if (estudiante == null) return;

      tts.hablar("Confirmando lectura...");
      
      try {
        await api.deleteSolicitudResuelta(noti.idNotificacion, estudiante.id_estudiante);
        ref.invalidate(notificacionesProvider);
        if (_idxNotificacion > 0) _idxNotificacion--;
        tts.hablar("Mensaje eliminado.");
      } catch (e) {
        tts.hablar("Error al eliminar.");
      }
  }

  @override
  Widget build(BuildContext context) {
    final notificacionesAsync = ref.watch(notificacionesProvider);

    return Scaffold(
      backgroundColor: Colors.white, 
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
            "Notificaciones", 
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
        ),
        leading: Semantics(
          label: "Volver al menú principal",
          button: true,
          excludeSemantics: true,
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
               tts.hablar("Volviendo al menú principal.");
               Navigator.of(context).pop();
            },
          ),
        ),
      ),
      body: Column(
        children: [
          // --- LISTA DE NOTIFICACIONES ---
          Expanded(
            child: notificacionesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: Colors.blue)),
              error: (e, s) => Center(child: Text("Error: $e", style: const TextStyle(color: Colors.red))),
              data: (notificaciones) {
                _listaNotificaciones = notificaciones;
                
                if (notificaciones.isEmpty) {
                  return const Center(
                    child: Text(
                      "No tienes notificaciones.",
                      style: TextStyle(color: Colors.black54, fontSize: 20),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: notificaciones.length,
                  itemBuilder: (context, index) {
                    final noti = notificaciones[index];
                    final isSelected = index == _idxNotificacion;
                    return _buildNotificacionItem(noti, isSelected);
                  },
                );
              },
            ),
          ),

          // --- BOTONES DE NAVEGACIÓN ACCESIBLES ---
          _buildBotonesAccesibles(),
        ],
      ),
    );
  }
  
  Widget _buildNotificacionItem(SolicitudNotificacion noti, bool isSelected) {
    Color colorTextoTitulo = Colors.black;
    Color colorFondoTarjeta = Colors.white;
    Color colorBorde = Colors.grey.shade300;
    IconData icono = Icons.info;
    
    if (noti.tipo == 'success') { 
      colorTextoTitulo = Colors.green.shade800;
      icono = Icons.check_circle;
    } else if (noti.tipo == 'error') { 
      colorTextoTitulo = Colors.red.shade800; 
      icono = Icons.cancel;
    } else {
      colorTextoTitulo = Colors.blue.shade800; 
    }

    if (isSelected) {
        colorFondoTarjeta = Colors.blue.shade50; 
        colorBorde = Colors.blue.shade800; 
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorFondoTarjeta,
        border: Border.all(
            color: colorBorde, 
            width: isSelected ? 3 : 1 
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2)
            )
        ]
      ),
      // ¡¡¡AQUÍ ESTÁ EL ARREGLO DEL TEXTO NO EXPUESTO!!!
      // Usamos MergeSemantics para que TalkBack lea todo el contenido de texto junto
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. BLOQUE DE INFORMACIÓN (Fusionado para el lector)
          MergeSemantics(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icono, color: colorTextoTitulo, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          noti.titulo,
                          style: TextStyle(
                              color: colorTextoTitulo, 
                              fontSize: 20, 
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    noti.mensaje,
                    style: const TextStyle(color: Colors.black87, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
            
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      "${noti.fecha.day}/${noti.fecha.month} ${noti.fecha.hour}:${noti.fecha.minute.toString().padLeft(2,'0')}",
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. BOTÓN DE ACCIÓN (Separado para que sea cliqueable si se navega por toque)
          // (Aunque usamos los botones de abajo, esto ayuda visualmente y por si acaso)
          Container(
             width: double.infinity,
             padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
             child: Semantics(
               button: true,
               label: "Confirmar y borrar notificación",
               excludeSemantics: true,
               child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[800],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)
                  ),
                ),
                onPressed: () => _confirmarYBorrar(noti),
                icon: const Icon(Icons.delete_outline, size: 24, color: Colors.white),
                label: const Text("Entendido / Borrar", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
             ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotonesAccesibles() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.grey.shade200, 
          border: const Border(top: BorderSide(color: Colors.grey))
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: _botonGrande("Anterior", Icons.arrow_upward, "Ir al mensaje anterior", () => _navegar(-1)),
          ),
          Expanded(
            child: _botonGrande("Confirmar\n(Borrar)", Icons.delete, "Borrar mensaje actual", _ejecutarAccion, esPeligroso: true),
          ),
          Expanded(
            child: _botonGrande("Siguiente", Icons.arrow_downward, "Ir al siguiente mensaje", () => _navegar(1)),
          ),
          Expanded(
            child: _botonGrande("Volver", Icons.exit_to_app, "Volver al menú principal", () {
              tts.hablar("Volviendo al menú principal.");
              Navigator.of(context).pop();
            }),
          ),
        ],
      ),
    );
  }

  Widget _botonGrande(String texto, IconData icono, String semanticLabel, VoidCallback accion, {bool esPeligroso = false}) {
    final colorFondo = esPeligroso ? Colors.red.shade800 : Colors.blue.shade800;
    
    return Semantics(
        button: true,
        label: "$texto. $semanticLabel",
        excludeSemantics: true,
        child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorFondo,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
                elevation: 4,
              ),
              onPressed: accion,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icono, size: 32, color: Colors.white),
                  const SizedBox(height: 6),
                  Text(
                    texto, 
                    style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ],
              ),
            )
        )
    );
  }
}