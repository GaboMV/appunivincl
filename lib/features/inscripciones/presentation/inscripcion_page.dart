// lib/features/inscripciones/pages/inscripcion_page.dart
import 'package:appuniv/core/tts_service.dart';
import 'package:appuniv/database/models/academic_models.dart';
import 'package:appuniv/features/inscripciones/providers/inscripcion_providers.dart';
import 'package:appuniv/utils/date_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:appuniv/core/speech_service.dart';

enum _ModoNav {
  menu,
  listaFacultad,
  listaMateria,
  escuchandoBusqueda,
  listaParalelo,
}

class InscripcionPage extends ConsumerStatefulWidget {
  const InscripcionPage({super.key});

  @override
  ConsumerState<InscripcionPage> createState() => _InscripcionPageState();
}

class _InscripcionPageState extends ConsumerState<InscripcionPage> {
  final tts = TtsService();
  final speech = SpeechService();
  bool _speechInicializado = false;

  _ModoNav _modo = _ModoNav.menu;
  int _idxMenu = 0;
  int _idxFacultad = 0;
  int _idxMateria = 0;
  int _idxParalelo = 0;

  List<Facultad> _listaFacultades = [];
  List<Materia> _listaMaterias = [];
  List<ParaleloDetalleCompleto> _listaParalelos = [];

  int? _idFacultadSeleccionada;
  String _queryBusqueda = "";
  int? _idMateriaSeleccionada;

  bool _haHabladoBienvenidaLista = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        _speechInicializado = await speech.init();
      } catch (e) {
        print("Error inicializando speech: $e");
        _speechInicializado = false;
      }
      _leerAyudaInicial();
    });
  }

  void _leerAyudaInicial() {
    ref.read(facultadesProvider).whenData((facultades) {
      _listaFacultades = facultades;
    });
    tts.hablar(
        "Inscripción de materias. Foco en menú. Opción: Buscar por Facultad. Presione OK para seleccionar.");
  }

  /// Formatea la lecturaTts del modelo para el TTS
  String _formatarLecturaParalelo(ParaleloDetalleCompleto p) {
    final lecturaBase = p.lecturaTts;
    final horariosFormateados = formatarHorariosParaTTS(p.horarios);
    final lecturaFormateada = lecturaBase.replaceFirst(
        "Horarios: ${p.horarios}.", 
        "Horarios: $horariosFormateados."
    );
    return limpiarTextoParaTTS(lecturaFormateada);
  }

  void _ttsCampoActual() {
    String lectura = "";
    try {
      switch (_modo) {
        
        // 🚨 ======================================================
        // 🚨 CAMBIO 1: INSTRUCCIÓN AL NAVEGAR (FIX 1)
        // 🚨 ======================================================
        case _ModoNav.menu:
          if (_idxMenu == 0) {
            lectura = "Buscar por Facultad. Presione OK para seleccionar.";
          } else {
            lectura = "Buscar por Nombre. Presione OK para activar el micrófono.";
          }
          break;
        // ======================================================

        case _ModoNav.listaFacultad:
          lectura = _listaFacultades[_idxFacultad].nombre;
          break;
        case _ModoNav.escuchandoBusqueda:
          // Este mensaje solo se oirá si el usuario
          // presiona Atrás/Sig *mientras* está escuchando
          lectura =
              "Micrófono activado. Hable y presione OK para buscar.";
          break;
        case _ModoNav.listaMateria:
          lectura = _listaMaterias[_idxMateria].nombre;
          break;
        case _ModoNav.listaParalelo:
          final paraleloCompleto = _listaParalelos[_idxParalelo];
          lectura = _formatarLecturaParalelo(paraleloCompleto);
          break;
      }
    } catch (e) {
      lectura = "Error de índice. Por favor, vuelva atrás.";
    }
    
    if (_modo != _ModoNav.listaParalelo) {
      tts.hablar(limpiarTextoParaTTS(lectura));
    } else {
      tts.hablar(lectura); // Ya está limpia
    }
  }

  void _navegar(int direccion) {
    bool habilitado = false;
    setState(() {
      _haHabladoBienvenidaLista = true;
      
      switch (_modo) {
        case _ModoNav.menu:
          _idxMenu = (_idxMenu + direccion + 2) % 2;
          habilitado = true;
          break;
        case _ModoNav.listaFacultad:
          if (_listaFacultades.isNotEmpty) {
            _idxFacultad =
                (_idxFacultad + direccion + _listaFacultades.length) %
                    _listaFacultades.length;
            habilitado = true;
          }
          break;
        case _ModoNav.listaMateria:
          if (_listaMaterias.isNotEmpty) {
            _idxMateria = (_idxMateria + direccion + _listaMaterias.length) %
                _listaMaterias.length;
            habilitado = true;
          }
          break;
        case _ModoNav.listaParalelo:
          if (_listaParalelos.isNotEmpty) {
            _idxParalelo =
                (_idxParalelo + direccion + _listaParalelos.length) %
                    _listaParalelos.length;
            habilitado = true;
          }
          break;
        case _ModoNav.escuchandoBusqueda:
          // Esta es la instrucción si intenta navegar mientras escucha
          tts.hablar(
              "Modo de escucha. Hable y presione OK para buscar, o Volver para cancelar.");
          break;
      }
    });

    if (habilitado) {
      _ttsCampoActual();
    }
  }

  void _ejecutarAccion() async {
    tts.detener();
    _haHabladoBienvenidaLista = false;

    switch (_modo) {
      case _ModoNav.menu:
        if (_idxMenu == 0) { // "Buscar por Facultad"
          setState(() {
            _modo = _ModoNav.listaFacultad;
            _idxFacultad = 0;
          });
          tts.hablar("Cargando facultades...");
        } else { // "Buscar por Nombre"
          if (!_speechInicializado) {
            tts.hablar("Error. El servicio de voz no pudo iniciarse.");
            return;
          }
          await speech.startListening();
          setState(() {
            _modo = _ModoNav.escuchandoBusqueda;
          });
          
          // 🚨 ======================================================
          // 🚨 CAMBIO 2: SILENCIO AL ACTIVAR EL MICRÓFONO (FIX 2)
          // 🚨 ======================================================
          // NO HABLAR. Solo activar el micrófono.
          // _ttsCampoActual(); // <- ESTA LÍNEA SE ELIMINÓ
          // ======================================================
        }
        break;

      case _ModoNav.listaFacultad:
        final facultad = _listaFacultades[_idxFacultad];
        setState(() {
          _modo = _ModoNav.listaMateria;
          _idFacultadSeleccionada = facultad.id_facultad;
          _queryBusqueda = "";
          _listaMaterias = [];
          _idxMateria = 0;
        });
        tts.hablar(
            "Facultad ${facultad.nombre} seleccionada. Cargando materias...");
        break;

      case _ModoNav.escuchandoBusqueda:
        final queryVoz = await speech.stopListening();
        if (queryVoz.trim().isEmpty) {
          tts.hablar("No se detectó ninguna voz. Intente de nuevo.");
          await speech.startListening();
          // _ttsCampoActual(); // No es necesario, la UI ya dice "Escuchando"
          return;
        }

        final queryNormalizada = normalizarQueryBusqueda(queryVoz);

        setState(() {
          _modo = _ModoNav.listaMateria;
          _idFacultadSeleccionada = null;
          _queryBusqueda = queryNormalizada;
          _listaMaterias = [];
          _idxMateria = 0;
        });
        tts.hablar(
            "Buscando materias para: ${limpiarTextoParaTTS(queryVoz)}. Cargando...");
        break;

      case _ModoNav.listaMateria:
        final materia = _listaMaterias[_idxMateria];
        setState(() {
          _modo = _ModoNav.listaParalelo;
          _idMateriaSeleccionada = materia.id_materia;
          _listaParalelos = [];
          _idxParalelo = 0;
        });
        tts.hablar(
            "Materia ${limpiarTextoParaTTS(materia.nombre)} seleccionada. Cargando paralelos...");
        break;

      case _ModoNav.listaParalelo:
        _haHabladoBienvenidaLista = true;
        final paralelo = _listaParalelos[_idxParalelo];
        
        tts.hablar("Procesando. Espere por favor...");
        try {
          final resultado = await ref
              .read(inscripcionServiceProvider.notifier)
              .inscribirOsolicitar(paralelo);
          
          tts.hablar(limpiarTextoParaTTS(resultado));

        } catch (e) {
          tts.hablar("Error inesperado: ${e.toString()}");
        }
        break;
    }
  }

  void _volver() {
    setState(() {
      tts.detener();
      _haHabladoBienvenidaLista = false;
      switch (_modo) {
        case _ModoNav.listaParalelo:
          _modo = _ModoNav.listaMateria;
          _idMateriaSeleccionada = null;
          _listaParalelos = [];
          tts.hablar("Volviendo a lista de materias.");
          break;
        case _ModoNav.listaMateria:
          _modo = _ModoNav.menu;
          _idFacultadSeleccionada = null;
          _queryBusqueda = "";
          _listaMaterias = [];
          tts.hablar("Volviendo al menú de inscripción.");
          break;
        case _ModoNav.listaFacultad:
          _modo = _ModoNav.menu;
          tts.hablar("Cancelado. Volviendo al menú de inscripción.");
          break;
        case _ModoNav.escuchandoBusqueda:
          speech.stopListening();
          _modo = _ModoNav.menu;
          tts.hablar("Búsqueda por voz cancelada.");
          break;
        case _ModoNav.menu:
          tts.hablar("Volviendo al menú principal.");
          Navigator.of(context).pop();
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Inscripción de Materias"),
        backgroundColor: Colors.grey[900],
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          _buildSelectorUI(),
          Expanded(
            child: _buildContenidoDinamico(),
          ),
          _buildBotonesAccesibles(),
        ],
      ),
    );
  }

  void _anunciarPrimeraVez(String texto) {
    if (!_haHabladoBienvenidaLista) {
      _haHabladoBienvenidaLista = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _ttsCampoActual();
      });
    }
  }

  Widget _buildContenidoDinamico() {
    if (_modo == _ModoNav.listaFacultad) {
      final asyncFacultades = ref.watch(facultadesProvider);
      return asyncFacultades.when(
        data: (facultades) {
          _listaFacultades = facultades;
          if (facultades.isEmpty) return _buildError("No se encontraron facultades.");
          _anunciarPrimeraVez(facultades[_idxFacultad].nombre);
          return _buildListaUI(
            itemCount: facultades.length,
            builder: (index) => _buildItemGenerico(
                facultades[index].nombre, Icons.school, index == _idxFacultad),
          );
        },
        loading: () => _buildLoader("Cargando facultades..."),
        error: (e, s) => _buildError(e.toString()),
      );
    }

    if (_modo == _ModoNav.escuchandoBusqueda) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mic, color: Colors.red.shade400, size: 100),
            const SizedBox(height: 20),
            const Text("Escuchando...",
                style: TextStyle(color: Colors.white, fontSize: 24)),
            const Text("Hable y presione OK para buscar",
                style: TextStyle(color: Colors.white70, fontSize: 18)),
          ],
        ),
      );
    }

    if (_modo == _ModoNav.listaMateria && _idFacultadSeleccionada != null) {
      final asyncMaterias =
          ref.watch(materiasPorFacultadProvider(_idFacultadSeleccionada!));
      return asyncMaterias.when(
        data: (materias) {
          _listaMaterias = materias;
          if (materias.isEmpty) {
            return _buildError("No se encontraron materias para esta facultad.");
          }
          _anunciarPrimeraVez(materias[_idxMateria].nombre);
          return _buildListaUI(
            itemCount: materias.length,
            builder: (index) => _buildItemGenerico(materias[index].nombre,
                Icons.book, index == _idxMateria),
          );
        },
        loading: () => _buildLoader("Cargando materias..."),
        error: (e, s) => _buildError(e.toString()),
      );
    }

    if (_modo == _ModoNav.listaMateria && _queryBusqueda.isNotEmpty) {
      final asyncMaterias = ref.watch(materiasPorBusquedaProvider(_queryBusqueda));
      return asyncMaterias.when(
        data: (materias) {
          _listaMaterias = materias;
          if (materias.isEmpty) {
            return _buildError(
                "No se encontraron materias con: '${limpiarTextoParaTTS(_queryBusqueda)}'.");
          }
          _anunciarPrimeraVez(materias[_idxMateria].nombre);
          return _buildListaUI(
            itemCount: materias.length,
            builder: (index) => _buildItemGenerico(materias[index].nombre,
                Icons.search, index == _idxMateria),
          );
        },
        loading: () => _buildLoader("Buscando materias..."),
        error: (e, s) => _buildError(e.toString()),
      );
    }

    if (_modo == _ModoNav.listaParalelo && _idMateriaSeleccionada != null) {
      final asyncParalelos =
          ref.watch(paralelosMateriaProvider(_idMateriaSeleccionada!));
      return asyncParalelos.when(
        data: (paralelos) {
          _listaParalelos = paralelos;
          if (paralelos.isEmpty) {
            return _buildError("No se encontraron paralelos para esta materia.");
          }
          _anunciarPrimeraVez(_listaParalelos[_idxParalelo].lecturaTts);

          return _buildListaUI(
            itemCount: paralelos.length,
            builder: (index) => _buildParaleloItem(paralelos[index], index == _idxParalelo),
          );
        },
        loading: () => _buildLoader("Cargando paralelos..."),
        error: (e, s) => _buildError(e.toString()),
      );
    }

    return const SizedBox.shrink();
  }

  // --- Widgets Genéricos de UI ---

  Widget _buildSelectorUI() {
    if (_modo != _ModoNav.menu) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() => _idxMenu = 0);
            _ttsCampoActual();
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _idxMenu == 0 ? Colors.blue.shade700 : Colors.blue.shade900,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row( children: [
                Icon(Icons.school, size: 30, color: Colors.white),
                SizedBox(width: 20),
                Text("Buscar por Facultad", style: TextStyle(color: Colors.white, fontSize: 24)),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() => _idxMenu = 1);
            _ttsCampoActual();
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _idxMenu == 1 ? Colors.green.shade700 : Colors.green.shade900,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row( children: [
                Icon(Icons.mic, size: 30, color: Colors.white),
                SizedBox(width: 20),
                Text("Buscar por Nombre", style: TextStyle(color: Colors.white, fontSize: 24)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListaUI(
      {required int itemCount, required Widget Function(int) builder}) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) => builder(index),
    );
  }

  Widget _buildItemGenerico(String texto, IconData icono, bool seleccionado) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 30),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: seleccionado ? Colors.indigo.shade700 : Colors.indigo.shade900,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icono, size: 24, color: Colors.white),
          const SizedBox(width: 15),
          Expanded(
            child: Text(limpiarTextoParaTTS(texto),
                style: const TextStyle(color: Colors.white, fontSize: 22)),
          ),
        ],
      ),
    );
  }

  Widget _buildParaleloItem(ParaleloDetalleCompleto paraleloInfo, bool seleccionado) {
    final paralelo = paraleloInfo.paralelo;
    Color colorEstado;
    switch (paralelo.estadoEstudiante) {
      case EstadoInscripcionParalelo.inscrito: colorEstado = Colors.green; break;
      case EstadoInscripcionParalelo.solicitado: colorEstado = Colors.yellow; break;
      case EstadoInscripcionParalelo.ninguno: colorEstado = Colors.grey; break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 30),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: seleccionado ? Colors.teal.shade700 : Colors.teal.shade900,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: seleccionado ? Colors.white : Colors.transparent, width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 12, height: 12,
            decoration: BoxDecoration(color: colorEstado, shape: BoxShape.circle),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Paralelo ${paralelo.nombreParalelo} - ${paralelo.docenteNombre} ${paralelo.docenteApellido}",
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Horarios: ${formatarHorariosParaTTS(paraleloInfo.horarios)}",
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                Text(
                  "Aula: ${paralelo.aula} - Créditos: ${paralelo.creditos}",
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
          if (seleccionado)
            const Icon(Icons.volume_up, color: Colors.white70),
        ],
      ),
    );
  }
  
  Widget _buildLoader(String texto) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(texto, style: const TextStyle(color: Colors.white, fontSize: 18)),
        ],
      ),
    );
  }
  
  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          limpiarTextoParaTTS(error),
          style: const TextStyle(color: Colors.yellow, fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildBotonesAccesibles() {
    bool navHabilitado = true;
    bool okHabilitado = true;

    if (_modo == _ModoNav.escuchandoBusqueda) {
      navHabilitado = false;
      okHabilitado = true;
    }
    if (_modo == _ModoNav.listaFacultad && _listaFacultades.isEmpty) {
      navHabilitado = false; okHabilitado = false;
    }
    if (_modo == _ModoNav.listaMateria && _listaMaterias.isEmpty) {
      navHabilitado = false; okHabilitado = false;
    }
     if (_modo == _ModoNav.listaParalelo && _listaParalelos.isEmpty) {
      navHabilitado = false; okHabilitado = false;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey[850],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: _botonGrande("Atrás", Icons.arrow_back, () => _navegar(-1),
                habilitado: navHabilitado),
          ),
          Expanded(
            child: _botonGrande("OK", Icons.check, _ejecutarAccion,
                habilitado: okHabilitado),
          ),
          Expanded(
            child: _botonGrande("Sig", Icons.arrow_forward, () => _navegar(1),
                habilitado: navHabilitado),
          ),
          Expanded(
            child: _botonGrande("Volver", Icons.arrow_upward, _volver),
          ),
        ],
      ),
    );
  }

  Widget _botonGrande(
      String texto, IconData icono, VoidCallback accion,
      {bool habilitado = true}) {
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