import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Imports de tus pantallas y lógica
import 'package:transporte_smart_app/theme/app_colors.dart';
import 'package:transporte_smart_app/models/route_model.dart'; 
import 'package:transporte_smart_app/screens/camera_screen.dart';
import 'package:transporte_smart_app/screens/routes_screen.dart';
import 'package:transporte_smart_app/screens/map_screen.dart';
import 'package:transporte_smart_app/screens/profile_screen.dart';
import 'package:transporte_smart_app/screens/result_screen.dart'; 
import 'package:transporte_smart_app/screens/splash_screen.dart';
import 'package:transporte_smart_app/blocs/routes/routes_bloc.dart';
import 'package:transporte_smart_app/blocs/routes/routes_event.dart';
import 'package:transporte_smart_app/blocs/routes/routes_state.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RoutesBloc()..add(LoadRoutesEvent()),
      child: MaterialApp(
        title: 'Transporte Smart',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.background,
          fontFamily: 'Inter', // Si no tienes la fuente, usará la defecto
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

// Estructura Principal con Navegación
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  
  // Variable para controlar si mostramos la pantalla de Resultado a pantalla completa
  AppRoute? _selectedRouteResult;
  AppRoute? _activeMapRoute;
  void _onTabTapped(int index) {
    if (index == 2) {
      // Si toca la cámara (índice 2), abrimos la pantalla completa
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CameraScreen(
            onShowResult: _showRouteResult,
          ),
        ),
      );
    } else {
      setState(() {
        _currentIndex = index;
        _selectedRouteResult = null; // Limpiar resultado si cambiamos de tab
      });
    }
  }

  // Método para mostrar el resultado (llamado desde Cámara o Lista)
  void _showRouteResult(AppRoute route) {
    // Si vienes de cámara, cerramos cámara primero
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    
    setState(() {
      _selectedRouteResult = route;
      _activeMapRoute = route;
    });
  }

  void _closeResult() {
    setState(() {
      _selectedRouteResult = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Si hay una ruta seleccionada, mostramos ResultScreen encima de todo
    if (_selectedRouteResult != null) {
      // Necesitamos pasar los favoritos actuales a la pantalla de resultados
      return BlocBuilder<RoutesBloc, RoutesState>(
        builder: (context, state) {
          List<String> favs = [];
          if (state is RoutesLoaded) {
            favs = state.favoriteIds;
          }
          
          return ResultScreen(
            route: _selectedRouteResult!,
            favoriteRoutes: favs,
            onToggleFavorite: (id) {
               context.read<RoutesBloc>().add(ToggleFavoriteEvent(id));
            },
            onClose: _closeResult,
          );
        },
      );
    }

    // Pantallas principales
    final List<Widget> screens = [
      MapScreen(activeRoute: _activeMapRoute),
      RoutesScreen(onShowResult: _showRouteResult),
      const SizedBox(), // Placeholder cámara (se abre modal)
      const ProfileScreen(),
    ];

    return Scaffold(
      extendBody: true, // Permite que el contenido vaya detrás de la barra
      body: screens[_currentIndex],
      bottomNavigationBar: _buildCustomNavBar(),
    );
  }

  Widget _buildCustomNavBar() {
    return SafeArea(
      child: Container(
        height: 70, // Altura un poco mayor para comodidad
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.9),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.surfaceLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribución equitativa
              children: [
                _buildCameraItem(),
                _buildNavItem(0, LucideIcons.map, "Mapa"),
                _buildNavItem(1, LucideIcons.bus, "Rutas"),
                // Botón central (Cámara) diferente
                _buildNavItem(3, LucideIcons.user, "Perfil"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isActive = _currentIndex == index;
    final Color activeColor = AppColors.primary;
    final Color inactiveColor = AppColors.textSecondary;

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        // padding reducido para evitar overflow
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), 
        decoration: BoxDecoration(
          color: isActive ? activeColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? activeColor : inactiveColor,
              size: 22,
            ),
            if (isActive) ...[
              const SizedBox(width: 6),
              Flexible( // Flexible evita que el texto empuje demasiado si es largo
                child: Text(
                  label,
                  style: TextStyle(
                    color: activeColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildCameraItem() {
    return GestureDetector(
      onTap: () => _onTabTapped(2),
      child: Container(
        width: 50, 
        height: 50,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 10,
              spreadRadius: 2,
            )
          ],
        ),
        child: const Icon(LucideIcons.scan, color: Colors.white, size: 24),
      ),
    );
  }
}