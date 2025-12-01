import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:transporte_smart_app/theme/app_colors.dart';
import 'package:transporte_smart_app/models/route_model.dart'; // Importa tu modelo
import 'package:transporte_smart_app/screens/camera_screen.dart';
import 'package:transporte_smart_app/screens/routes_screen.dart';
import 'package:transporte_smart_app/screens/map_screen.dart';
import 'package:transporte_smart_app/screens/profile_screen.dart';
import 'package:transporte_smart_app/screens/result_screen.dart'; 
import 'package:transporte_smart_app/screens/splash_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppColors.background,
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            unselectedItemColor: AppColors.textInactive,
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  // --- ESTADO CENTRALIZADO --- // Ejemplo de favorito inicial
  AppRoute? _selectedRoute; // La ruta que se está viendo (null si no hay ninguna)

  // --- FUNCIONES DE MANEJO DE ESTADO ---
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showResult(AppRoute route) {
    setState(() {
      _selectedRoute = route;
    });
  }

  void _hideResult() {
    setState(() {
      _selectedRoute = null;
    });
  }

  // --- CONSTRUCTOR DE PANTALLAS ---
  List<Widget> _buildScreens() {
    return [
      CameraScreen(
        onShowResult: _showResult,
      ),
      RoutesScreen(
        onShowResult: _showResult,
      ),
      const MapScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true, 
      body: Stack(
        children: [
          // --- PANTALLAS DE NAVEGACIÓN ---
          IndexedStack(
            index: _selectedIndex,
            children: _buildScreens(),
          ),

          // --- BARRA DE NAVEGACIÓN ---
          // Solo mostrar si NO hay ruta seleccionada Y el teclado NO está visible
          if (_selectedRoute == null && !isKeyboardVisible)
            _buildCustomNavBar(),

          // --- PANTALLA DE RESULTADO ---
          if (_selectedRoute != null)
             // Necesitamos conectar el ResultScreen al BLoC también
             // para que la estrella de favoritos funcione
             BlocBuilder<RoutesBloc, RoutesState>(
               builder: (context, state) {
                 List<String> currentFavs = [];
                 if (state is RoutesLoaded) {
                   currentFavs = state.favoriteIds;
                 }
                 
                 return ResultScreen(
                    route: _selectedRoute!,
                    favoriteRoutes: currentFavs, // Viene del BLoC
                    onToggleFavorite: (id) {
                      // Enviamos evento al BLoC
                      context.read<RoutesBloc>().add(ToggleFavoriteEvent(id));
                    },
                    onClose: _hideResult,
                 );
               },
             ),
        ],
      ),
    );
  }

  // --- WIDGET DE NAVEGACIÓN PERSONALIZADO  ---
  Widget _buildCustomNavBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      //child: SafeArea( // <--- ESTO ARREGLA EL OVERFLOW EN IPHONE/ANDROID NUEVOS
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 30.0), // Margen manual
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32.0),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                decoration: BoxDecoration(
                  color: AppColors.surface.withOpacity(0.95),
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(32.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(icon: LucideIcons.camera, label: "Detectar", index: 0),
                    _buildNavItem(icon: LucideIcons.list, label: "Rutas", index: 1),
                    _buildNavItem(icon: LucideIcons.map, label: "Mapa", index: 2),
                    _buildNavItem(icon: LucideIcons.user, label: "Perfil", index: 3),
                  ],
                ),
              ),
            ),
          ),
        ),
      //),
    );
  }

  Widget _buildNavItem(
      {required IconData icon, required String label, required int index}) {
    final bool isActive = _selectedIndex == index;
    final Color activeColor = AppColors.primary;
    final Color inactiveColor = AppColors.textInactive;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.ease,
            width: isActive ? 75 : 60,
            height: 50,
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: isActive ? activeColor.withOpacity(0.2) : Colors.transparent,
              borderRadius: BorderRadius.circular(16.0),
              border: isActive
                  ? Border.all(color: AppColors.borderActive)
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
          if (isActive)
            Positioned(
              top: -8,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: activeColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}