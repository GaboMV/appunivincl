// lib/features/horarios/presentation/horarios_page_accesible.dart
import 'package:appuniv/core/tts_service.dart';
import 'package:appuniv/features/horarios/providers/horarios_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🚨 1. IMPORTAR EL UTIlL DE FECHAS
import 'package:appuniv/utils/date_utils.dart';

class HorariosPageAccesible extends ConsumerStatefulWidget {
  const HorariosPageAccesible({super.key});

  @override
  ConsumerState<HorariosPageAccesible> createState() =>
      _HorariosPageAccesibleState();
}

class _HorariosPageAccesibleState
    extends ConsumerState<HorariosPageAccesible> {
  final tts = TtsService();
  int _campoActual = 0;
  final List<String> _dias = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];

  // 🚨 2. AÑADIR LA FUNCIÓN DE LIMPIEZA (para evitar "menos")
  /// Limpia el nombre del semestre para que el TTS lo lea bien.
  String _limpiarNombreSemestre(String nombre) {
    // Reemplaza "2025-4" por "2025 4" para que no diga "menos"
    return nombre.replaceAll('-', ' ');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 🚨 3. LÓGICA DE BIENVENIDA ACTUALIZADA
      
      // Obtenemos el nombre del semestre actual (ej: "2025-4 Semestre 2")
      final String nombreSemestre = getNombreSemestreActual(); 
      // Lo limpiamos para el TTS (ej: "2025 4 Semestre 2")
      final String nombreLimpio = _limpiarNombreSemestre(nombreSemestre);

      // Hablamos el nuevo mensaje
      tts.hablar(
        "Mis horarios del semestre actual. Semestre actual: $nombreLimpio. Selecciona un día."
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
    
    tts.hablar("$diaSeleccionado: $lectura");
  }

  @override
  Widget build(BuildContext context) {
    final horarioAsync = ref.watch(horarioProcesadoProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Mi Horario (Semestre Actual)"),
        backgroundColor: Colors.grey[900],
        automaticallyImplyLeading: false, 
      ),
      body: Column(
        children: [
          Expanded(
            child: horarioAsync.when(
              // ✅ Datos Cargados
              data: (horarioData) {
                return ListView.builder(
                  itemCount: _dias.length,
                  itemBuilder: (context, index) {
                    return _buildDiaItem(
                      _dias[index],
                      horarioData[_dias[index]] ?? "...",
                      index == _campoActual,
                      index,
                    );
                  },
                );
              },
              // ⏳ Cargando
              loading: () => const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.greenAccent),
                    SizedBox(height: 16),
                    Text("Cargando horario...", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              // ❌ Error
              error: (e, s) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    "Error al cargar el horario: ${e.toString()}",
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          // --- Panel de Navegación ---
          _buildBotonesAccesibles(horarioAsync),
        ],
      ),
    );
  }

  // --- Widgets de UI ---

  Widget _buildDiaItem(
    String dia,
    String resumen,
    bool seleccionado,
    int index,
  ) {
    String resumenUI = (resumen == "Sin clases programadas.")
        ? "Libre"
        : "Ver detalles...";

    return GestureDetector(
      onTap: () {
        setState(() => _campoActual = index);
        _ttsCampoActual();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: seleccionado ? Colors.teal[700] : Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
          border: seleccionado
              ? Border.all(color: Colors.tealAccent, width: 2)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              dia,
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
            Text(
              resumenUI,
              style: TextStyle(color: Colors.grey[400], fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotonesAccesibles(AsyncValue<Map<String, String>> horarioAsync) {
    final bool habilitado = horarioAsync.hasValue;

    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey[850],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: _botonGrande("Atrás", Icons.arrow_back, () {
              setState(() {
                _campoActual = (_campoActual - 1 + _dias.length) % _dias.length;
              });
              _ttsCampoActual();
            }, habilitado: habilitado),
          ),
          Expanded(
            child: _botonGrande("OK", Icons.check, () {
              if (horarioAsync.value != null) {
                _ejecutarAccionOk(horarioAsync.value!);
              }
            }, habilitado: habilitado),
          ),
          Expanded(
            child: _botonGrande("Sig", Icons.arrow_forward, () {
              setState(() {
                _campoActual = (_campoActual + 1) % _dias.length;
              });
              _ttsCampoActual();
            }, habilitado: habilitado),
          ),
          Expanded(
            child: _botonGrande("Volver", Icons.exit_to_app, () {
              tts.hablar("Volviendo al menú principal.");
              Navigator.of(context).pop();
            }),
          ),
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
        backgroundColor: habilitado ? Colors.blueGrey : Colors.grey[700],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
      onPressed: habilitado ? accion : null,
      child: Column(
        children: [
          Icon(icono, size: 32, color: Colors.white.withOpacity(habilitado ? 1.0 : 0.5)),
          const SizedBox(height: 8),
          Text(
            texto,
            style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(habilitado ? 1.0 : 0.5)),
          ),
        ],
      ),
    );
  }
}