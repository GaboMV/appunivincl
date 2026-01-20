// lib/features/historial/pages/historial_academico_page.dart
import 'package:appuniv/core/tts_service.dart';
import 'package:appuniv/database/models/academic_models.dart';
import 'package:appuniv/features/historial/providers/historial_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



import 'package:appuniv/utils/date_utils.dart';
// lib/features/historial/pages/historial_academico_page.dart


enum _ModoSeleccion { focoEnSemestre, editandoSemestre, focoEnMateria }

class HistorialAcademicoPage extends ConsumerStatefulWidget {
  const HistorialAcademicoPage({super.key});

  @override
  ConsumerState<HistorialAcademicoPage> createState() =>
      _HistorialAcademicoPageState();
}

class _HistorialAcademicoPageState
    extends ConsumerState<HistorialAcademicoPage> {
  final tts = TtsService();

  _ModoSeleccion _modo = _ModoSeleccion.focoEnSemestre;
  int _idxSemestre = 0;
  int _idxMateria = 0;
  bool _semestreConfirmado = false;
  bool _haHabladoBienvenidaMaterias = false;

  List<Semestre> _listaSemestres = [];
  List<HistorialMateria> _listaMaterias = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _leerAyudaInicial();
    });
  }

  void _leerAyudaInicial() async {
    try {
      final semestres = await ref.read(historialSemestresProvider.future);
      if (semestres.isEmpty) {
        _listaSemestres = [];
        tts.hablar(
          "Historial Académico. No se encontraron semestres. Use el botón Volver.",
        );
        return;
      }
      _listaSemestres = semestres;

      final nombreLimpio = limpiarTextoParaTTS(
        _listaSemestres[_idxSemestre].nombre,
      );

      tts.hablar(
        "Historial Académico. Foco en selector de semestre. Semestre actual: $nombreLimpio. Presione OK para cambiar de semestre.",
      );
    } catch (e, s) {
      tts.hablar("Error al cargar el historial. $e. Use el botón Volver.");
    }
  }

  void _ttsCampoActual() {
    if (_modo == _ModoSeleccion.focoEnSemestre) {
      if (_listaSemestres.isEmpty) return;

      final nombreLimpio = limpiarTextoParaTTS(
        _listaSemestres[_idxSemestre].nombre,
      );

      tts.hablar(
        "Foco en selector de semestre. Semestre actual: $nombreLimpio. Presione OK para cambiar.",
      );
    } else if (_modo == _ModoSeleccion.editandoSemestre) {
      if (_listaSemestres.isEmpty) return;

      final nombreLimpio = limpiarTextoParaTTS(
        _listaSemestres[_idxSemestre].nombre,
      );

      tts.hablar(nombreLimpio);
    } else {
      if (_listaMaterias.isEmpty) return;

      final nombreOriginal = _listaMaterias[_idxMateria].nombreMateria;
      final nombreLimpio = limpiarTextoParaTTS(nombreOriginal);

      tts.hablar(nombreLimpio);
    }
  }

  void _ejecutarAccion() {
    switch (_modo) {
      case _ModoSeleccion.focoEnSemestre:
        if (_listaSemestres.isEmpty) {
          tts.hablar("No hay semestres para editar.");
          return;
        }
        setState(() {
          _modo = _ModoSeleccion.editandoSemestre;
        });
        tts.hablar(
          "Editando semestre. Use Atrás para ir a semestres anteriores y Siguiente para ir a semestres más recientes. Presione OK para confirmar.",
        );
        break;

      case _ModoSeleccion.editandoSemestre:
        setState(() {
          _modo = _ModoSeleccion.focoEnMateria;
          _idxMateria = 0;
          _semestreConfirmado = true;
          _haHabladoBienvenidaMaterias = false;
        });
        tts.hablar(
          "Semestre confirmado. Cargando materias... Espere por favor.",
        );
        break;

      case _ModoSeleccion.focoEnMateria:
        if (_listaMaterias.isEmpty) {
          tts.hablar("No hay notas para leer.");
          return;
        }

        final stringOriginal = _listaMaterias[_idxMateria].lecturaTts;
        final stringLimpio = limpiarTextoParaTTS(stringOriginal);

        tts.hablar(stringLimpio);
        break;
    }
  }

  void _navegar(int direccion) {
    if (_modo == _ModoSeleccion.focoEnSemestre) {
      tts.hablar("Presione OK para editar el semestre.");
      return;
    }

    if (_modo == _ModoSeleccion.editandoSemestre) {
      final int direccionCorregida = direccion * -1;
      if (_listaSemestres.isEmpty) return;
      setState(() {
        _idxSemestre =
            (_idxSemestre + direccionCorregida + _listaSemestres.length) %
                _listaSemestres.length;
        _idxMateria = 0;
        _semestreConfirmado = false;
        _haHabladoBienvenidaMaterias = false;
      });
    } else {
      if (_listaMaterias.isEmpty) return;
      setState(() {
        _idxMateria =
            (_idxMateria + direccion + _listaMaterias.length) %
                _listaMaterias.length;
      });
    }
    _ttsCampoActual();
  }

  void _volver() {
    switch (_modo) {
      case _ModoSeleccion.focoEnMateria:
        setState(() {
          _modo = _ModoSeleccion.focoEnSemestre;
          _semestreConfirmado = false;
          _haHabladoBienvenidaMaterias = false;
        });

        final nombreLimpio = limpiarTextoParaTTS(
          _listaSemestres[_idxSemestre].nombre,
        );
        tts.hablar(
          "Volviendo a selección de semestre. Foco en selector de semestre. Semestre actual: $nombreLimpio",
        );
        break;
      case _ModoSeleccion.editandoSemestre:
        setState(() {
          _modo = _ModoSeleccion.focoEnSemestre;
        });
        tts.hablar(
          "Edición de semestre cancelada. Foco en selector de semestre.",
        );
        break;
      case _ModoSeleccion.focoEnSemestre:
        tts.hablar("Volviendo al menú principal.");
        Navigator.of(context).pop();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncSemestres = ref.watch(historialSemestresProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final int? idSemestreSeleccionado =
        _listaSemestres.isNotEmpty
            ? _listaSemestres[_idxSemestre].id_semestre
            : null;

    final asyncMaterias =
        (idSemestreSeleccionado != null && _semestreConfirmado)
            ? ref.watch(historialMateriasProvider(idSemestreSeleccionado))
            : null;

    if (asyncMaterias != null) {
      asyncMaterias.whenData((materias) {
        _listaMaterias = materias;
        if (_modo == _ModoSeleccion.focoEnMateria &&
            !_haHabladoBienvenidaMaterias) {
          _haHabladoBienvenidaMaterias = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (materias.isNotEmpty) {
              final nombreLimpio = limpiarTextoParaTTS(
                materias[_idxMateria].nombreMateria,
              );
              tts.hablar(
                "Materias cargadas. Foco en lista de materias. Opción: $nombreLimpio",
              );
            } else {
              tts.hablar("No se encontraron materias para este semestre.");
            }
          });
        }
      });
    }

    return Scaffold(
      // Fondo blanco automático
      appBar: AppBar(
        title: const Text("Historial Académico"),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          asyncSemestres.when(
            data: (semestres) {
              if (semestres.isEmpty) {
                return Center(
                    child: Text("No hay semestres.",
                        style: TextStyle(color: colorScheme.onSurface, fontSize: 18)));
              }
              if (_listaSemestres.isEmpty) _listaSemestres = semestres;
              return _buildSemestreSelector(
                _listaSemestres[_idxSemestre].nombre,
                colorScheme,
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (e, s) => Text(
              "Error: $e",
              style: TextStyle(color: colorScheme.error),
            ),
          ),
          Expanded(child: _buildAreaDeMaterias(asyncMaterias, colorScheme)),
          _buildBotonesAccesibles(colorScheme),
        ],
      ),
    );
  }

  Widget _buildAreaDeMaterias(
    AsyncValue<List<HistorialMateria>>? asyncMaterias,
    ColorScheme colors,
  ) {
    if (!_semestreConfirmado) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Text(
            "Presione OK para cargar las materias del semestre seleccionado.",
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (asyncMaterias == null || asyncMaterias.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return asyncMaterias.when(
      data: (materias) {
        if (materias.isEmpty) {
          return Center(
            child: Text(
              "No hay materias para este semestre.",
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          );
        }
        return _buildListaMaterias(materias, colors);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) =>
          Text("Error: $e", style: TextStyle(color: colors.error)),
    );
  }

  Widget _buildSemestreSelector(String nombreSemestre, ColorScheme colors) {
    final bool focoEnWidget = _modo == _ModoSeleccion.focoEnSemestre;
    final bool editandoWidget = _modo == _ModoSeleccion.editandoSemestre;
    
    Color borderColor = Colors.grey[300]!;
    Color backgroundColor = Colors.grey[200]!;
    
    if (focoEnWidget) {
      borderColor = colors.primary;
      backgroundColor = colors.primary.withOpacity(0.1);
    } else if (editandoWidget) {
      borderColor = colors.secondary;
      backgroundColor = colors.secondary.withOpacity(0.1);
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 3),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (editandoWidget)
            Icon(Icons.edit, color: colors.secondary, size: 30)
          else
            Icon(Icons.school, size: 30, color: colors.primary),
          const SizedBox(width: 15),
        Expanded(
            child: Text(
              nombreSemestre,
              style: TextStyle(
                  color: colors.onSurface, // Negro
                  fontSize: 24, 
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          const SizedBox(width: 15),
          if (focoEnWidget)
            Icon(Icons.arrow_drop_down, color: colors.primary)
          else if (editandoWidget)
            Icon(Icons.check_circle_outline, color: colors.secondary)
          else
            const Icon(Icons.school, size: 30, color: Colors.transparent),
        ],
      ),
    );
  }

  Widget _buildListaMaterias(List<HistorialMateria> materias, ColorScheme colors) {
    return ListView.builder(
      itemCount: materias.length,
      itemBuilder: (context, index) {
        final materia = materias[index];
        final bool seleccionado =
            _modo == _ModoSeleccion.focoEnMateria && _idxMateria == index;
        return _buildBotonMateria(
          materia.nombreMateria,
          materia.estadoCalculado,
          seleccionado,
          colors,
        );
      },
    );
  }

  Widget _buildBotonMateria(String materia, String estado, bool seleccionado, ColorScheme colors) {
    Color colorEstado;
    Color colorFondoEstado;
    
    if (estado == "Aprobado") {
        colorEstado = Colors.green[700]!;
        colorFondoEstado = Colors.green[50]!;
    } else if (estado == "Reprobado") {
        colorEstado = colors.error;
        colorFondoEstado = Colors.red[50]!;
    } else {
        colorEstado = Colors.grey[600]!;
        colorFondoEstado = Colors.grey[200]!;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 30),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // Azul claro si seleccionado, o el color de fondo del estado si no
        color: seleccionado ? colors.primary.withOpacity(0.1) : colorFondoEstado,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: seleccionado ? colors.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: colorEstado,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  materia,
                  style: TextStyle(
                      color: colors.onSurface, // Negro
                      fontSize: 22, 
                      fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal),
                ),
                Text(
                  estado,
                  style: TextStyle(color: colorEstado, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          if (seleccionado) Icon(Icons.volume_up, color: colors.primary),
        ],
      ),
    );
  }

  Widget _buildBotonesAccesibles(ColorScheme colors) {
    bool puedeNavegar = true;
    bool puedeOK = true;
    if (_modo == _ModoSeleccion.focoEnSemestre) {
      puedeNavegar = false;
      if (_listaSemestres.isEmpty) puedeOK = false;
    } else if (_modo == _ModoSeleccion.editandoSemestre) {
      if (_listaSemestres.isEmpty) {
        puedeNavegar = false;
        puedeOK = false;
      }
    } else {
      if (!_semestreConfirmado || _listaMaterias.isEmpty) {
        puedeNavegar = false;
        puedeOK = false;
      }
    }
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey[100], // Fondo claro
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: _botonGrande("Atrás", Icons.arrow_back, () {
              _navegar(-1);
            }, colors, habilitado: puedeNavegar),
          ),
          Expanded(
            child: _botonGrande("OK", Icons.check, () {
              _ejecutarAccion();
            }, colors, habilitado: puedeOK),
          ),
          Expanded(
            child: _botonGrande("Sig", Icons.arrow_forward, () {
              _navegar(1);
            }, colors, habilitado: puedeNavegar),
          ),
          Expanded(child: _botonGrande("Volver", Icons.arrow_upward, _volver, colors)),
        ],
      ),
    );
  }

  Widget _botonGrande(
    String texto,
    IconData icono,
    VoidCallback accion,
    ColorScheme colors, {
    bool habilitado = true,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: habilitado ? colors.primary : Colors.grey[400],
        foregroundColor: colors.onPrimary, // Texto blanco
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
      onPressed: habilitado ? accion : null,
      child: Column(
        children: [
          Icon(
            icono, 
            size: 30, 
            color: colors.onPrimary.withOpacity(habilitado ? 1.0 : 0.5)
          ),
          const SizedBox(height: 8),
          Text(
            texto, 
            style: TextStyle(
              fontSize: 16,
              color: colors.onPrimary.withOpacity(habilitado ? 1.0 : 0.5)
            )
          ),
        ],
      ),
    );
  }
}