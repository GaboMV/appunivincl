import 'package:appuniv/database/database_service.dart';
import 'package:appuniv/features/login/presentation/login.dart';
import 'package:appuniv/widgets/start_up_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializamos la app con Riverpod
  runApp(const ProviderScope(child: AppAccesible()));
}

class AppAccesible extends StatelessWidget {
  const AppAccesible({super.key}); 

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Inclusiva',
      debugShowCheckedModeBanner: false,
      
      // 🎨 TEMA DE ALTO CONTRASTE (Estándar WCAG AA)
      theme: ThemeData(
        useMaterial3: true, // Usamos Material 3 para mejores componentes
        
        // 1. Colores base
        scaffoldBackgroundColor: const Color(0xFFFFFFFF), // Fondo Blanco Puro
        
        colorScheme: const ColorScheme.light(
          // Principal: Azul Intenso (Contraste 6.9:1 sobre blanco)
          primary: Color(0xFF0052CC), 
          onPrimary: Colors.white, // Texto sobre el azul
          
          // Secundario: Verde Azulado (Teal)
          secondary: Color(0xFF00695C), 
          onSecondary: Colors.white,
          
          // Error: Rojo Oscuro (El rojo estándar suele fallar, este no)
          error: Color(0xFFD32F2F), 
          onError: Colors.white,
          
          // Superficies (Tarjetas, Diálogos)
          surface: Color(0xFFFFFFFF),
          onSurface: Color(0xFF121212), // Texto casi negro para máximo contraste
        ),

        // 2. Configuración de la Barra Superior (AppBar)
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0052CC), // Azul
          foregroundColor: Colors.white,      // Iconos y texto blancos
          centerTitle: true,
          elevation: 0,
        ),

        // 3. Configuración de Botones Elevados
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0052CC), // Botón Azul
            foregroundColor: Colors.white,            // Texto Blanco
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.bold
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // Bordes ligeramente redondeados
            ),
          ),
        ),

        // 4. Configuración de Textos (Tipografía legible)
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF121212), fontSize: 18),
          bodyMedium: TextStyle(color: Color(0xFF121212), fontSize: 16),
          titleLarge: TextStyle(color: Color(0xFF121212), fontWeight: FontWeight.bold),
        ),
        
        // 5. Inputs (Campos de texto) - Muy importante para accesibilidad
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF5F5F5), // Gris muy claro para diferenciar el campo
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF000000)), // Borde negro visible
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF0052CC), width: 2), // Borde azul al enfocar
          ),
          labelStyle: const TextStyle(color: Color(0xFF424242)), // Gris oscuro
        ),
      ),
      
      home:  AppStartUpWidget(),
    );
  }
}