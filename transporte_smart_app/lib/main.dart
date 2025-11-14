// lib/main.dart
import 'package:flutter/material.dart';
import 'dart:ui'; // Necesario para BackdropFilter (el blur)
import 'package:lucide_flutter/lucide_flutter.dart';

// Importa las 4 pantallas que acabamos de crear
import 'package:transporte_smart_app/screens/camera_screen.dart';
import 'package:transporte_smart_app/screens/routes_screen.dart';
import 'package:transporte_smart_app/screens/map_screen.dart';
import 'package:transporte_smart_app/screens/profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transporte Smart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        // Color de fondo principal (bg-[#0C0A09] de tu App.tsx)
        scaffoldBackgroundColor: const Color(0xFF0C0A09),
      ),
      home: const AppShell(),
    );
  }
}

// Este widget es el contenedor principal, como tu App.tsx
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0; // 0: Detectar, 1: Rutas, 2: Mapa, 3: Perfil

  // Lista de las pantallas (las importamos arriba)
  static const List<Widget> _screens = <Widget>[
    CameraScreen(),
    RoutesScreen(),
    MapScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // IndexedStack mantiene el estado de las pantallas
          // cuando cambias de pestaña
          IndexedStack(
            index: _selectedIndex,
            children: _screens,
          ),

          // Aquí construimos nuestra barra de navegación personalizada
          _buildCustomNavBar(),
        ],
      ),
    );
  }

  // --- WIDGET DE NAVEGACIÓN PERSONALIZADO ---
  // (Traducción de tu NavigationBar.tsx)

  Widget _buildCustomNavBar() {
    // Usamos Positioned para que "flote" en la parte inferior
    // (Equivalente a 'fixed bottom-0 left-0 right-0' con 'mx-4 mb-6')
    return Positioned(
      bottom: 24.0, // mb-6
      left: 16.0,   // mx-4
      right: 16.0,  // mx-4
      child:
          // ClipRRect para las esquinas redondeadas (rounded-[2rem])
          ClipRRect(
        borderRadius: BorderRadius.circular(32.0),
        child:
            // BackdropFilter para el efecto de blur (backdrop-blur-2xl)
            BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child:
              // Container para el color y borde
              Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            decoration: BoxDecoration(
              // bg-[#1C1917]/95
              color: const Color(0xFF1C1917).withOpacity(0.95),
              // border border-white/10
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              borderRadius: BorderRadius.circular(32.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: LucideIcons.camera,
                  label: "Detectar",
                  index: 0,
                ),
                _buildNavItem(
                  icon: LucideIcons.list,
                  label: "Rutas",
                  index: 1,
                ),
                _buildNavItem(
                  icon: LucideIcons.map,
                  label: "Mapa",
                  index: 2,
                ),
                _buildNavItem(
                  icon: LucideIcons.user,
                  label: "Perfil",
                  index: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET PARA CADA BOTÓN DE NAVEGACIÓN ---
  // (Esto replica el ítem activo con su fondo y punto superior)

  Widget _buildNavItem(
      {required IconData icon, required String label, required int index}) {
    final bool isActive = _selectedIndex == index;

    // Colores basados en el estado 'isActive'
    final Color activeColor = const Color(0xFF2DD4BF); // text-[#2DD4BF]
    final Color inactiveColor = Colors.white.withOpacity(0.4); // text-white/40

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Stack(
        clipBehavior: Clip.none, // Permite que el punto se salga del 'Stack'
        alignment: Alignment.center,
        children: [
          // Fondo animado (El 'motion.div' con 'layoutId')
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.ease,
            width: isActive ? 75 : 60, // Ancho dinámico
            height: 50,
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              // bg-gradient-to-br from-[#2DD4BF]/20 ...
              color: isActive
                  ? activeColor.withOpacity(0.2)
                  : Colors.transparent,
              // rounded-2xl
              borderRadius: BorderRadius.circular(16.0),
              // border border-[#2DD4BF]/30
              border: isActive
                  ? Border.all(color: activeColor.withOpacity(0.3))
                  : Border.all(color: Colors.transparent),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isActive ? activeColor : inactiveColor,
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? activeColor : inactiveColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Punto indicador superior (absolute -top-1 ...)
          if (isActive)
            Positioned(
              top: -8, // -top-1 (ajustado para Flutter)
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: activeColor, // bg-[#2DD4BF]
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}