import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:transporte_smart_app/theme/app_colors.dart';
import 'package:transporte_smart_app/blocs/routes/routes_bloc.dart';
import 'package:transporte_smart_app/blocs/routes/routes_state.dart';
import 'package:transporte_smart_app/models/route_model.dart';
import 'package:transporte_smart_app/screens/login_screen.dart'; // Asegúrate de tener este import

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // --- ESTADO LOCAL PARA LA DEMO ---
  bool _darkMode = true;
  bool _notifications = false;
  
  // Estado de sesión (Simulado)
  bool _isLoggedIn = false; 
  String _userName = "Invitado";
  String _userCity = "La Paz, Bolivia";
  String _userLevel = "Turista";

  // Función para ir al Login y esperar resultado
  void _goToLogin() async {
    // Navegamos y esperamos a que LoginScreen nos devuelva un valor (true/false)
    final result = await Navigator.push(
      context, 
      MaterialPageRoute(builder: (_) => const LoginScreen())
    );
    
    // Si el Login fue exitoso (simulado)
    if (result == true) {
      setState(() {
        _isLoggedIn = true;
        _userName = "Juan Pérez"; // Usuario inventado para la demo
        _userLevel = "Experto en Rutas";
        _notifications = true; // Activamos notificaciones mágicamente
      });
      
      // Feedback visual
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("¡Bienvenido de nuevo, Juan!"),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }
  }

  void _logout() {
    setState(() {
      _isLoggedIn = false;
      _userName = "Invitado";
      _userLevel = "Turista";
      _notifications = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Sesión cerrada correctamente")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<RoutesBloc, RoutesState>(
        builder: (context, state) {
          // Calculamos favoritos reales del Bloc
          int favCount = 0;
          List<AppRoute> favoriteRoutesList = [];

          if (state is RoutesLoaded) {
            favCount = state.favoriteIds.length;
            favoriteRoutesList = state.allRoutes
                .where((r) => state.favoriteIds.contains(r.lineNumber))
                .toList();
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0).copyWith(top: 60.0, bottom: 120.0),
            children: [
              // --- 1. CABECERA DE PERFIL ---
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 70, height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surface,
                      border: Border.all(
                        color: _isLoggedIn ? AppColors.primary : AppColors.textSecondary, 
                        width: 2
                      ),
                      boxShadow: _isLoggedIn 
                        ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 15)]
                        : [],
                    ),
                    child: Icon(
                      _isLoggedIn ? LucideIcons.userCheck : LucideIcons.user, 
                      size: 30, 
                      color: _isLoggedIn ? AppColors.primary : AppColors.textSecondary
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Textos
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userName, 
                          style: const TextStyle(
                            color: AppColors.textPrimary, 
                            fontSize: 22, 
                            fontWeight: FontWeight.bold
                          )
                        ),
                        if (!_isLoggedIn)
                          GestureDetector(
                            onTap: _goToLogin,
                            child: Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                "Iniciar Sesión", 
                                style: TextStyle(
                                  color: Colors.black, 
                                  fontWeight: FontWeight.bold, 
                                  fontSize: 12
                                )
                              ),
                            ),
                          )
                        else
                           Text(_userCity, style: const TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  )
                ],
              ),
              
              const SizedBox(height: 30),

              // --- 2. ESTADÍSTICAS ---
              Row(
                children: [
                  Expanded(child: _buildStatCard("Nivel", _userLevel, LucideIcons.medal)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard("Guardados", "$favCount", LucideIcons.heart)),
                ],
              ),

              const SizedBox(height: 30),
              
              // --- 3. LISTA DE FAVORITOS ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Mis Favoritos", 
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                  if (!_isLoggedIn && favoriteRoutesList.isNotEmpty)
                    GestureDetector(
                      onTap: _goToLogin,
                      child: const Text("Guardar en nube", style: TextStyle(color: AppColors.secondary, fontSize: 12)),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              if (favoriteRoutesList.isEmpty)
                _buildEmptyState()
              else
                ...favoriteRoutesList.map((route) => _buildMiniRouteCard(route)),

              const SizedBox(height: 30),

              // --- 4. CONFIGURACIÓN ---
               const Text("Configuración", 
                style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              
              _buildSettingsTile("Modo Oscuro", LucideIcons.moon, _darkMode, (v) => setState(() => _darkMode = v)),
              _buildSettingsTile("Notificaciones", LucideIcons.bell, _notifications, (v) => setState(() => _notifications = v)),
              _buildSettingsTile("Ayuda y Soporte", LucideIcons.info , null, null),
              
              const SizedBox(height: 20),
              
              // Botón de Cerrar Sesión (Solo si está logueado)
              if (_isLoggedIn)
                TextButton.icon(
                  onPressed: _logout,
                  icon: const Icon(LucideIcons.logOut, size: 18, color: AppColors.error),
                  label: const Text("Cerrar Sesión", style: TextStyle(color: AppColors.error)),
                )
            ],
          );
        },
      ),
    );
  }

  // --- Widgets Auxiliares ---

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Row(
        children: const [
          Icon(LucideIcons.info, color: AppColors.textSecondary),
          SizedBox(width: 12),
          Expanded(child: Text("Aún no tienes rutas favoritas.", 
            style: TextStyle(color: AppColors.textSecondary))),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildMiniRouteCard(AppRoute route) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              route.lineNumber, 
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              route.routeName, 
              maxLines: 1, 
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textPrimary)
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(String title, IconData icon, bool? value, Function(bool)? onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8)
          ),
          child: Icon(icon, color: AppColors.textPrimary, size: 20),
        ),
        title: Text(title, style: const TextStyle(color: AppColors.textPrimary)),
        trailing: value != null 
          ? Switch(
              value: value, 
              activeColor: AppColors.primary,
              trackColor: MaterialStateProperty.all(AppColors.surfaceLight),
              onChanged: onChanged,
            )
          : const Icon(LucideIcons.chevronRight, color: AppColors.textSecondary),
      ),
    );
  }
}