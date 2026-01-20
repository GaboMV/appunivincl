// lib/features/inscripciones/pages/inscripcion_page.dart
// (¡¡¡LA PUTA VERSIÓN FINAL CON LÓGICA DE BOTÓN OK ARREGLADA!!!)

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

  String _formatarLecturaParalelo(ParaleloDetalleCompleto p) {
    final lecturaBase = p.lecturaTts;
    final horariosFormateados = formatarHorariosParaTTS(p.horarios);
    final lecturaFormateada = lecturaBase.replaceFirst(
        "Horarios: ${p.horarios}.", "Horarios: $horariosFormateados.");
    return limpiarTextoParaTTS(lecturaFormateada);
  }

  void _ttsCampoActual() {
    String lectura = "";
    try {
      switch (_modo) {
        case _ModoNav.menu:
          if (_idxMenu == 0) {
            lectura = "Buscar por Facultad. Presione OK para seleccionar.";
          } else {
            lectura = "Buscar por Nombre. Presione OK para activar el micrófono.";
          }
          break;
        case _ModoNav.listaFacultad:
          if (_listaFacultades.isNotEmpty)
            lectura = _listaFacultades[_idxFacultad].nombre;
          break;
        case _ModoNav.escuchandoBusqueda:
          lectura = "Micrófono activado. Hable y presione OK para buscar.";
          break;
        case _ModoNav.listaMateria:
          if (_listaMaterias.isNotEmpty)
            lectura = _listaMaterias[_idxMateria].nombre;
          break;
        case _ModoNav.listaParalelo:
          if (_listaParalelos.isNotEmpty) {
            final paraleloCompleto = _listaParalelos[_idxParalelo];
            lectura = _formatarLecturaParalelo(paraleloCompleto);
          }
          break;
      }
    } catch (e) {
      lectura = "Error de índice. Por favor, vuelva atrás.";
    }

    if (_modo != _ModoNav.listaParalelo) {
      tts.hablar(limpiarTextoParaTTS(lectura));
    } else {
      tts.hablar(lectura);
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
            _idxFacultad = (_idxFacultad + direccion + _listaFacultades.length) % _listaFacultades.length;
            habilitado = true;
          }
          break;
        case _ModoNav.listaMateria:
          if (_listaMaterias.isNotEmpty) {
            _idxMateria = (_idxMateria + direccion + _listaMaterias.length) % _listaMaterias.length;
            habilitado = true;
          }
          break;
        case _ModoNav.listaParalelo:
          if (_listaParalelos.isNotEmpty) {
            _idxParalelo = (_idxParalelo + direccion + _listaParalelos.length) % _listaParalelos.length;
            habilitado = true;
          }
          break;
        case _ModoNav.escuchandoBusqueda:
          tts.hablar("Modo de escucha. Hable y presione OK para buscar, o Volver para cancelar.");
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
        if (_idxMenu == 0) {
          setState(() {
            _modo = _ModoNav.listaFacultad;
            _idxFacultad = 0;
          });
          tts.hablar("Cargando facultades...");
        } else {
          if (!_speechInicializado) {
            tts.hablar("Error. El servicio de voz no pudo iniciarse.");
            return;
          }
          await speech.startListening();
          setState(() {
            _modo = _ModoNav.escuchandoBusqueda;
          });
        }
        break;

      case _ModoNav.listaFacultad:
        if (_listaFacultades.isEmpty) return;
        final facultad = _listaFacultades[_idxFacultad];
        setState(() {
          _modo = _ModoNav.listaMateria;
          _idFacultadSeleccionada = facultad.id_facultad;
          _queryBusqueda = "";
          _listaMaterias = [];
          _idxMateria = 0;
        });
        tts.hablar("Facultad ${facultad.nombre} seleccionada. Cargando materias...");
        break;

      case _ModoNav.escuchandoBusqueda:
        final queryVoz = await speech.stopListening();
        if (queryVoz.trim().isEmpty) {
          tts.hablar("No se detectó ninguna voz. Intente de nuevo.");
          await speech.startListening();
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
        tts.hablar("Buscando materias para: ${limpiarTextoParaTTS(queryVoz)}. Cargando...");
        break;

      case _ModoNav.listaMateria:
        if (_listaMaterias.isEmpty) return;
        final materia = _listaMaterias[_idxMateria];
        setState(() {
          _modo = _ModoNav.listaParalelo;
          _idMateriaSeleccionada = materia.id_materia;
          _listaParalelos = [];
          _idxParalelo = 0;
        });
        tts.hablar("Materia ${limpiarTextoParaTTS(materia.nombre)} seleccionada. Cargando paralelos...");
        break;

      case _ModoNav.listaParalelo:
        if (_listaParalelos.isEmpty) return;
        _haHabladoBienvenidaLista = true;
        final paralelo = _listaParalelos[_idxParalelo];
        
        tts.hablar("Procesando. Espere por favor...");
        try {
          final resultado = await ref.read(inscripcionServiceProvider.notifier).inscribirOsolicitar(paralelo);
          tts.hablar(limpiarTextoParaTTS(resultado));
          
          ref.invalidate(paralelosMateriaProvider(paralelo.idMateria));
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // Sin color forzado, usa el tema (Blanco)
      appBar: AppBar(
        title: const Text("Inscripción de Materias"),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          _buildSelectorUI(colorScheme),
          Expanded(child: _buildContenidoDinamico(colorScheme)),
          _buildBotonesAccesibles(colorScheme),
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

  Widget _buildContenidoDinamico(ColorScheme colors) {
    if (_modo == _ModoNav.listaFacultad) {
      final asyncFacultades = ref.watch(facultadesProvider);
      return asyncFacultades.when(
        data: (facultades) {
          _listaFacultades = facultades;
          if (facultades.isEmpty) {
            tts.hablar("No se encontraron facultades.");
            return _buildError("No se encontraron facultades.", colors);
          }
          _anunciarPrimeraVez(facultades[_idxFacultad].nombre);
          return _buildListaUI(
            itemCount: facultades.length,
            builder: (index) => _buildItemGenerico(
                facultades[index].nombre, Icons.school, index == _idxFacultad, colors),
          );
        },
        loading: () => _buildLoader("Cargando facultades...", colors),
        error: (e, s) => _buildError(e.toString(), colors),
      );
    }

    if (_modo == _ModoNav.escuchandoBusqueda) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mic, color: colors.error, size: 100), // Rojo
            const SizedBox(height: 20),
            Text("Escuchando...",
                style: TextStyle(color: colors.onSurface, fontSize: 24)),
            Text("Hable y presione OK para buscar",
                style: TextStyle(color: Colors.grey[700], fontSize: 18)),
          ],
        ),
      );
    }

    if (_modo == _ModoNav.listaMateria && _idFacultadSeleccionada != null) {
      final asyncMaterias = ref.watch(materiasPorFacultadProvider(_idFacultadSeleccionada!));
      return asyncMaterias.when(
        data: (materias) {
          _listaMaterias = materias;
          if (materias.isEmpty) {
            tts.hablar("No se encontraron materias para esta facultad.");
            return _buildError("No se encontraron materias para esta facultad.", colors);
          }
          _anunciarPrimeraVez(materias[_idxMateria].nombre);
          return _buildListaUI(
            itemCount: materias.length,
            builder: (index) => _buildItemGenerico(
                materias[index].nombre, Icons.book, index == _idxMateria, colors),
          );
        },
        loading: () => _buildLoader("Cargando materias...", colors),
        error: (e, s) => _buildError(e.toString(), colors),
      );
    }

    if (_modo == _ModoNav.listaMateria && _queryBusqueda.isNotEmpty) {
      final asyncMaterias = ref.watch(materiasPorBusquedaProvider(_queryBusqueda));
      return asyncMaterias.when(
        data: (materias) {
          _listaMaterias = materias;
          if (materias.isEmpty) {
            tts.hablar("No se encontraron materias con esa búsqueda.");
            return _buildError("No se encontraron materias con: '${limpiarTextoParaTTS(_queryBusqueda)}'.", colors);
          }
          _anunciarPrimeraVez(materias[_idxMateria].nombre);
          return _buildListaUI(
            itemCount: materias.length,
            builder: (index) => _buildItemGenerico(
                materias[index].nombre, Icons.search, index == _idxMateria, colors),
          );
        },
        loading: () => _buildLoader("Buscando materias...", colors),
        error: (e, s) => _buildError(e.toString(), colors),
      );
    }

    if (_modo == _ModoNav.listaParalelo && _idMateriaSeleccionada != null) {
      final asyncParalelos = ref.watch(paralelosMateriaProvider(_idMateriaSeleccionada!));
      return asyncParalelos.when(
        data: (paralelos) {
          _listaParalelos = paralelos;
          if (paralelos.isEmpty) {
            tts.hablar("No se encontraron paralelos disponibles.");
            return _buildError("No se encontraron paralelos para esta materia.", colors);
          }
          _anunciarPrimeraVez(_listaParalelos[_idxParalelo].lecturaTts);
          return _buildListaUI(
            itemCount: paralelos.length,
            builder: (index) => _buildParaleloItem(paralelos[index], index == _idxParalelo, colors),
          );
        },
        loading: () => _buildLoader("Cargando paralelos...", colors),
        error: (e, s) => _buildError(e.toString(), colors),
      );
    }

    return const SizedBox.shrink();
  }

  // --- Widgets Genéricos de UI ---

  Widget _buildSelectorUI(ColorScheme colors) {
    if (_modo != _ModoNav.menu) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        _buildMenuItem("Buscar por Facultad", Icons.school, _idxMenu == 0, colors, 0),
        _buildMenuItem("Buscar por Nombre", Icons.mic, _idxMenu == 1, colors, 1),
      ],
    );
  }

  Widget _buildMenuItem(String texto, IconData icono, bool seleccionado, ColorScheme colors, int index) {
    return GestureDetector(
      onTap: () {
        setState(() => _idxMenu = index);
        _ttsCampoActual();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          // Azul claro si seleccionado, Gris claro si no
          color: seleccionado ? colors.primary.withOpacity(0.1) : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
          // Borde azul grueso si seleccionado
          border: seleccionado 
              ? Border.all(color: colors.primary, width: 3) 
              : Border.all(color: Colors.grey[400]!),
        ),
        child: Row(
          children: [
            Icon(icono, size: 30, color: seleccionado ? colors.primary : Colors.grey[800]),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                texto, 
                style: TextStyle(
                  color: colors.onSurface, // Negro
                  fontSize: 24,
                  fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal
                )
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListaUI({required int itemCount, required Widget Function(int) builder}) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) => builder(index),
    );
  }

  Widget _buildItemGenerico(String texto, IconData icono, bool seleccionado, ColorScheme colors) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 30),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: seleccionado ? colors.primary.withOpacity(0.1) : Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
        border: seleccionado ? Border.all(color: colors.primary, width: 2) : null,
      ),
      child: Row(
        children: [
          Icon(icono, size: 24, color: seleccionado ? colors.primary : Colors.grey[800]),
          const SizedBox(width: 15),
          Expanded(
            child: Text(limpiarTextoParaTTS(texto),
                style: TextStyle(color: colors.onSurface, fontSize: 22)),
          ),
        ],
      ),
    );
  }

  Widget _buildParaleloItem(ParaleloDetalleCompleto paraleloInfo, bool seleccionado, ColorScheme colors) {
    final paralelo = paraleloInfo.paralelo;
    Color colorBorde;
    Color colorFondo;
    
    switch (paralelo.estadoEstudiante) {
      case EstadoInscripcionParalelo.inscrito:
        colorBorde = Colors.green;
        colorFondo = Colors.green[50]!;
        break;
      case EstadoInscripcionParalelo.solicitado:
        colorBorde = Colors.yellow[800]!; // Amarillo más oscuro para que se vea en blanco
        colorFondo = Colors.orange[50]!;
        break;
      case EstadoInscripcionParalelo.ninguno:
        colorBorde = Colors.grey;
        colorFondo = Colors.white;
        break;
      default:
        colorBorde = Colors.grey;
        colorFondo = Colors.white;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 30),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: seleccionado ? colors.primary.withOpacity(0.05) : colorFondo,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: seleccionado ? colors.primary : colorBorde,
          width: seleccionado ? 3 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12, height: 12,
            decoration: BoxDecoration(color: colorBorde, shape: BoxShape.circle),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Paralelo ${paralelo.nombreParalelo} - ${paralelo.docenteNombre} ${paralelo.docenteApellido}",
                  style: TextStyle(color: colors.onSurface, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Horarios: ${formatarHorariosParaTTS(paraleloInfo.horarios)}",
                  style: TextStyle(color: Colors.grey[800], fontSize: 16),
                ),
                Text(
                  "Aula: ${paralelo.aula} - Créditos: ${paralelo.creditos}",
                  style: TextStyle(color: Colors.grey[800], fontSize: 16),
                ),
              ],
            ),
          ),
          if (seleccionado) Icon(Icons.volume_up, color: colors.primary),
        ],
      ),
    );
  }

  Widget _buildLoader(String texto, ColorScheme colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(texto, style: TextStyle(color: colors.onSurface, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildError(String error, ColorScheme colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          limpiarTextoParaTTS(error),
          style: TextStyle(color: colors.error, fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildBotonesAccesibles(ColorScheme colors) {
    bool navHabilitado = true;
    bool okHabilitado = true;

    if (_modo == _ModoNav.escuchandoBusqueda) {
      navHabilitado = false;
      okHabilitado = true;
    }
    if (_modo == _ModoNav.listaFacultad && _listaFacultades.isEmpty) {
      navHabilitado = false;
      okHabilitado = false;
    }
    if (_modo == _ModoNav.listaMateria && _listaMaterias.isEmpty) {
      navHabilitado = false;
      okHabilitado = false;
    }
    if (_modo == _ModoNav.listaParalelo && _listaParalelos.isEmpty) {
      navHabilitado = false;
      okHabilitado = false;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey[100], // Fondo claro
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: _botonGrande("Atrás", Icons.arrow_back, () => _navegar(-1),
                colors, habilitado: navHabilitado),
          ),
          Expanded(
            child: _botonGrande("OK", Icons.check, _ejecutarAccion,
                colors, habilitado: okHabilitado),
          ),
          Expanded(
            child: _botonGrande("Sig", Icons.arrow_forward, () => _navegar(1),
                colors, habilitado: navHabilitado),
          ),
          Expanded(
            child: _botonGrande("Volver", Icons.arrow_upward, _volver, colors),
          ),
        ],
      ),
    );
  }

  Widget _botonGrande(
      String texto, IconData icono, VoidCallback accion, ColorScheme colors,
      {bool habilitado = true}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: habilitado ? colors.primary : Colors.grey[400],
        foregroundColor: colors.onPrimary, // Texto blanco
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      ),
      onPressed: habilitado ? accion : null,
      child: Column(
        children: [
          Icon(icono, size: 30, color: colors.onPrimary.withOpacity(habilitado ? 1.0 : 0.5)),
          const SizedBox(height: 4),
          Text(texto, style: TextStyle(fontSize: 14, color: colors.onPrimary.withOpacity(habilitado ? 1.0 : 0.5))),
        ],
      ),
    );
  }
}