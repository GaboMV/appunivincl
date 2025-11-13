// lib/features/historial/pages/historial_academico_page.dart
import 'package:appuniv/core/tts_service.dart';
import 'package:appuniv/database/models/academic_models.dart';
import 'package:appuniv/features/historial/providers/historial_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:appuniv/core/tts_service.dart';

import 'package:appuniv/features/historial/providers/historial_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:appuniv/utils/date_utils.dart';

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

  // 🚨 2. FUNCIONES DE LIMPIEZA LOCALES ELIMINADAS
  // (Ya no se necesitan _limpiarNombreSemestre ni _limpiarNumerales)

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

      // 🚨 3. USAR LA FUNCIÓN DE UTILS
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

      // 🚨 3. USAR LA FUNCIÓN DE UTILS
      final nombreLimpio = limpiarTextoParaTTS(
        _listaSemestres[_idxSemestre].nombre,
      );

      tts.hablar(
        "Foco en selector de semestre. Semestre actual: $nombreLimpio. Presione OK para cambiar.",
      );
    } else if (_modo == _ModoSeleccion.editandoSemestre) {
      if (_listaSemestres.isEmpty) return;

      // 🚨 3. USAR LA FUNCIÓN DE UTILS
      final nombreLimpio = limpiarTextoParaTTS(
        _listaSemestres[_idxSemestre].nombre,
      );

      tts.hablar(nombreLimpio);
    } else {
      if (_listaMaterias.isEmpty) return;

      // 🚨 3. USAR LA FUNCIÓN DE UTILS
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

        // 🚨 3. USAR LA FUNCIÓN DE UTILS
        // El modelo da el texto "sucio"
        final stringOriginal = _listaMaterias[_idxMateria].lecturaTts;
        // Lo limpiamos antes de hablar
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

        // 🚨 3. USAR LA FUNCIÓN DE UTILS
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

    final int? idSemestreSeleccionado =
        _listaSemestres.isNotEmpty ? _listaSemestres[_idxSemestre].id_semestre : null;

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
              // 🚨 3. USAR LA FUNCIÓN DE UTILS
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Historial Académico"),
        backgroundColor: Colors.grey[900],
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          asyncSemestres.when(
            data: (semestres) {
              if (semestres.isEmpty) {
                return const Center(child: Text("No hay semestres."));
              }
              if (_listaSemestres.isEmpty) _listaSemestres = semestres;
              return _buildSemestreSelector(
                _listaSemestres[_idxSemestre].nombre,
              );
            },
            loading: () => const LinearProgressIndicator(),
            error:
                (e, s) => Text(
                  "Error: $e",
                  style: const TextStyle(color: Colors.red),
                ),
          ),
          Expanded(child: _buildAreaDeMaterias(asyncMaterias)),
          _buildBotonesAccesibles(),
        ],
      ),
    );
  }

  Widget _buildAreaDeMaterias(
    AsyncValue<List<HistorialMateria>>? asyncMaterias,
  ) {
    if (!_semestreConfirmado) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(30.0),
          child: Text(
            "Presione OK para cargar las materias del semestre seleccionado.",
            style: TextStyle(fontSize: 18, color: Colors.white70),
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
          return const Center(
            child: Text(
              "No hay materias para este semestre.",
              style: TextStyle(fontSize: 18, color: Colors.white70),
            ),
          );
        }
        return _buildListaMaterias(materias);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (e, s) =>
              Text("Error: $e", style: const TextStyle(color: Colors.red)),
    );
  }

  Widget _buildSemestreSelector(String nombreSemestre) {
    final bool focoEnWidget = _modo == _ModoSeleccion.focoEnSemestre;
    final bool editandoWidget = _modo == _ModoSeleccion.editandoSemestre;
    Color borderColor = Colors.blue.shade900;
    if (focoEnWidget) {
      borderColor = Colors.white;
    } else if (editandoWidget) {
      borderColor = Colors.yellow;
    }
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade900,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 3),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (editandoWidget)
            const Icon(Icons.edit, color: Colors.yellow, size: 30)
          else
            const Icon(Icons.school, size: 30, color: Colors.white),
          const SizedBox(width: 15),
          Text(
            nombreSemestre,
            style: const TextStyle(color: Colors.white, fontSize: 24),
          ),
          const SizedBox(width: 15),
          if (focoEnWidget)
            const Icon(Icons.arrow_drop_down, color: Colors.white70)
          else if (editandoWidget)
            const Icon(Icons.check_circle_outline, color: Colors.yellow)
          else
            const Icon(Icons.school, size: 30, color: Colors.transparent),
        ],
      ),
    );
  }

  Widget _buildListaMaterias(List<HistorialMateria> materias) {
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
        );
      },
    );
  }

  Widget _buildBotonMateria(String materia, String estado, bool seleccionado) {
    final Color colorEstado =
        (estado == "Aprobado")
            ? Colors.green
            : (estado == "Reprobado" ? Colors.red : Colors.grey);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 30),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: seleccionado ? Colors.teal.shade700 : Colors.teal.shade900,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: seleccionado ? Colors.white : Colors.transparent,
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
                  style: const TextStyle(color: Colors.white, fontSize: 22),
                ),
                Text(
                  estado,
                  style: TextStyle(color: colorEstado, fontSize: 18),
                ),
              ],
            ),
          ),
          if (seleccionado) const Icon(Icons.volume_up, color: Colors.white70),
        ],
      ),
    );
  }

  Widget _buildBotonesAccesibles() {
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
      color: Colors.grey[850],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: _botonGrande("Atrás", Icons.arrow_back, () {
              _navegar(-1);
            }, habilitado: puedeNavegar),
          ),
          Expanded(
            child: _botonGrande("OK", Icons.check, () {
              _ejecutarAccion();
            }, habilitado: puedeOK),
          ),
          Expanded(
            child: _botonGrande("Sig", Icons.arrow_forward, () {
              _navegar(1);
            }, habilitado: puedeNavegar),
          ),
          Expanded(child: _botonGrande("Volver", Icons.arrow_upward, _volver)),
        ],
      ),
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
}
