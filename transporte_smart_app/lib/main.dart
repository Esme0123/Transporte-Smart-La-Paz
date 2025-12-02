import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
          fontFamily: 'Inter', 
          useMaterial3: true,
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
  int _currentIndex = 0;
  AppRoute? _selectedRouteResult;
  AppRoute? _activeMapRoute;
  bool _isMapReturn = false; 

  void _onTabTapped(int index) {
    if (index == 2) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CameraScreen(onShowResult: _showRouteResult),
        ),
      );
    } else {
      setState(() {
        _currentIndex = index;
        _selectedRouteResult = null; 
      });
    }
  }

  void _showRouteResult(AppRoute route) {
    if (Navigator.canPop(context)) Navigator.pop(context);
    setState(() {
      _selectedRouteResult = route;
      _activeMapRoute = route; 
      _isMapReturn = false; // Por defecto ida al escanear
    });
  }

  // --- FUNCIÓN CLAVE PARA EL MAPA ---
  void _goToMapFromDetail(AppRoute route, bool isReturn) {
    setState(() {
      _selectedRouteResult = null; 
      _currentIndex = 0;           
      _activeMapRoute = route;     
      _isMapReturn = isReturn; // Actualiza la dirección
    });
  }

  void _closeResult() {
    setState(() {
      _selectedRouteResult = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedRouteResult != null) {
      return BlocBuilder<RoutesBloc, RoutesState>(
        builder: (context, state) {
          List<String> favs = [];
          if (state is RoutesLoaded) favs = state.favoriteIds;
          
          return ResultScreen(
            route: _selectedRouteResult!,
            favoriteRoutes: favs,
            onToggleFavorite: (id) => context.read<RoutesBloc>().add(ToggleFavoriteEvent(id)),
            onClose: _closeResult,
            onGoToMap: _goToMapFromDetail, 
          );
        },
      );
    }

    final List<Widget> screens = [
      MapScreen(activeRoute: _activeMapRoute, isReturn: _isMapReturn), 
      RoutesScreen(onShowResult: _showRouteResult),
      const SizedBox(), 
      const ProfileScreen(), // Ahora ProfileScreen tiene Login
    ];

    return Scaffold(
      extendBody: true,
      body: screens[_currentIndex],
      bottomNavigationBar: _buildCustomNavBar(),
    );
  }

   Widget _buildCustomNavBar() {
    return SafeArea(
      child: Container(
        height: 70, 
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
              children: [
                _buildNavItem(0, LucideIcons.map, "Mapa"),
                _buildNavItem(1, LucideIcons.bus, "Rutas"),
                _buildCameraItem(),
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
              Flexible( 
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