// lib/features/horarios/presentation/horarios_page_accesible.dart
import 'package:appuniv/core/tts_service.dart';
import 'package:appuniv/features/horarios/providers/horarios_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🚨 1. IMPORTAR UTILS
import 'package:appuniv/utils/date_utils.dart';

// lib/features/horarios/presentation/horarios_page_accesible.dart

class HorariosPageAccesible extends ConsumerStatefulWidget {
  const HorariosPageAccesible({super.key});

  @override
  ConsumerState<HorariosPageAccesible> createState() =>
      _HorariosPageAccesibleState();
}

class _HorariosPageAccesibleState extends ConsumerState<HorariosPageAccesible> {
  final tts = TtsService();
  int _campoActual = 0;
  final List<String> _dias = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final String nombreSemestre = getNombreSemestreActual();
      final String nombreLimpio = limpiarTextoParaTTS(nombreSemestre);

      tts.hablar(
        "Mis horarios del semestre actual. Semestre actual: $nombreLimpio. Selecciona un día.",
      );
    });
  }

  void _ttsCampoActual() {
    tts.hablar(_dias[_campoActual]);
  }

  void _ejecutarAccionOk(Map<String, String> horarioData) {
    final diaSeleccionado = _dias[_campoActual];
    final lectura =
        horarioData[diaSeleccionado] ?? "No se encontró horario para este día.";

    tts.hablar("$diaSeleccionado: ${limpiarTextoParaTTS(lectura)}");
  }

  @override
  Widget build(BuildContext context) {
    final horarioAsync = ref.watch(horarioProcesadoProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // Fondo blanco automático por el main.dart
      appBar: AppBar(
        title: const Text("Mi Horario (Semestre Actual)"),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: horarioAsync.when(
              data: (horarioData) {
                return ListView.builder(
                  itemCount: _dias.length,
                  itemBuilder: (context, index) {
                    return _buildDiaItem(
                      _dias[index],
                      horarioData[_dias[index]] ?? "...",
                      index == _campoActual,
                      index,
                      colorScheme,
                    );
                  },
                );
              },
              loading: () => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      "Cargando horario...",
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                  ],
                ),
              ),
              error: (e, s) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    "Error al cargar el horario: ${e.toString()}",
                    style: TextStyle(color: colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          _buildBotonesAccesibles(horarioAsync, colorScheme),
        ],
      ),
    );
  }

  Widget _buildDiaItem(
    String dia,
    String resumen,
    bool seleccionado,
    int index,
    ColorScheme colors,
  ) {
    String resumenUI;
    if (resumen == "Sin clases programadas.") {
      resumenUI = "Libre";
    } else if (resumen.contains("Luego...")) {
      resumenUI = "Varias clases";
    } else {
      resumenUI = resumen
          .split(' ')
          .firstWhere((s) => s.isNotEmpty, orElse: () => "Ver detalles");
      if (resumenUI.length > 10)
        resumenUI = "${resumenUI.substring(0, 10)}...";
    }

    return GestureDetector(
      onTap: () {
        setState(() => _campoActual = index);
        _ttsCampoActual();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          // Azul claro si seleccionado, Gris claro si no
          color:
              seleccionado ? colors.primary.withOpacity(0.1) : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
          border: seleccionado
              ? Border.all(color: colors.primary, width: 3) // Borde grueso azul
              : Border.all(color: Colors.grey[400]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              dia,
              style: TextStyle(
                color: colors.onSurface, // Negro
                fontSize: 24,
                fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            Text(
              resumenUI,
              style: TextStyle(color: Colors.grey[800], fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotonesAccesibles(
      AsyncValue<Map<String, String>> horarioAsync, ColorScheme colors) {
    final bool habilitado = horarioAsync.hasValue;

    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey[100], // Fondo claro
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: _botonGrande("Atrás", Icons.arrow_back, () {
              setState(() {
                _campoActual = (_campoActual - 1 + _dias.length) % _dias.length;
              });
              _ttsCampoActual();
            }, colors, habilitado: habilitado),
          ),
          Expanded(
            child: _botonGrande("OK", Icons.check, () {
              if (horarioAsync.value != null) {
                _ejecutarAccionOk(horarioAsync.value!);
              }
            }, colors, habilitado: habilitado),
          ),
          Expanded(
            child: _botonGrande("Sig", Icons.arrow_forward, () {
              setState(() {
                _campoActual = (_campoActual + 1) % _dias.length;
              });
              _ttsCampoActual();
            }, colors, habilitado: habilitado),
          ),
          Expanded(
            child: _botonGrande("Volver", Icons.exit_to_app, () {
              tts.hablar("Volviendo al menú principal.");
              Navigator.of(context).pop();
            }, colors),
          ),
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
        // Azul si habilitado, gris si no
        backgroundColor: habilitado ? colors.primary : Colors.grey[400],
        foregroundColor: colors.onPrimary, // Texto blanco
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        elevation: 4,
      ),
      onPressed: habilitado ? accion : null,
      child: Column(
        children: [
          Icon(
            icono,
            size: 32,
            color: colors.onPrimary.withOpacity(habilitado ? 1.0 : 0.5),
          ),
          const SizedBox(height: 8),
          Text(
            texto,
            style: TextStyle(
              fontSize: 18,
              color: colors.onPrimary.withOpacity(habilitado ? 1.0 : 0.5),
            ),
          ),
        ],
      ),
    );
  }
}