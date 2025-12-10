import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:transporte_smart_app/repositories/auth_repository.dart';
import 'package:transporte_smart_app/theme/app_colors.dart';
import 'package:transporte_smart_app/blocs/routes/routes_bloc.dart';
import 'package:transporte_smart_app/blocs/routes/routes_state.dart';
import 'package:transporte_smart_app/models/route_model.dart';
import 'package:transporte_smart_app/screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Configuración local
  bool _darkMode = true;
  bool _notifications = false;
  
  final AuthRepository _authRepo = AuthRepository();
  User? _currentUser; // Usuario real de Firebase

  @override
  void initState() {
    super.initState();
    // 1. Cargar usuario al inicio
    _currentUser = _authRepo.currentUser;
    
    // 2. Escuchar cambios (login/logout) en tiempo real
    _authRepo.authStateChanges.listen((user) {
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    });
  }

  void _goToLogin() {
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (_) => const LoginScreen())
    );
  }

  void _logout() async {
    await _authRepo.signOut();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sesión cerrada")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Si _currentUser no es null, estamos logueados
    final bool isLoggedIn = _currentUser != null;
    final String displayName = isLoggedIn ? (_currentUser!.email ?? "Usuario") : "Invitado";
    final String userLevel = isLoggedIn ? "Usuario Verificado" : "Turista";

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<RoutesBloc, RoutesState>(
        builder: (context, state) {
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
              // --- 1. CABECERA ---
              Row(
                children: [
                  Container(
                    width: 70, height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surface,
                      border: Border.all(
                        color: isLoggedIn ? AppColors.primary : AppColors.textSecondary, 
                        width: 2
                      ),
                      boxShadow: isLoggedIn 
                        ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 15)]
                        : [],
                    ),
                    child: Icon(
                      isLoggedIn ? LucideIcons.userCheck : LucideIcons.user, 
                      size: 30, 
                      color: isLoggedIn ? AppColors.primary : AppColors.textSecondary
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName, // Muestra el correo real
                          style: const TextStyle(
                            color: AppColors.textPrimary, 
                            fontSize: 18, 
                            fontWeight: FontWeight.bold
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (!isLoggedIn)
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
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)
                              ),
                            ),
                          )
                        else
                           Text(userLevel, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  )
                ],
              ),
              
              const SizedBox(height: 30),

              // --- 2. ESTADÍSTICAS ---
              Row(
                children: [
                  Expanded(child: _buildStatCard("Nivel", userLevel.split(" ").last, LucideIcons.medal)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard("Guardados", "$favCount", LucideIcons.heart)),
                ],
              ),

              const SizedBox(height: 30),
              
              // --- 3. FAVORITOS ---
              const Text("Mis Rutas Guardadas", 
                style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
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
              
              const SizedBox(height: 20),
              
              if (isLoggedIn)
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

  // --- WIDGETS AUXILIARES ---
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: const [
          Icon(LucideIcons.info, color: AppColors.textSecondary),
          SizedBox(width: 12),
          Expanded(child: Text("Sin favoritos.", style: TextStyle(color: AppColors.textSecondary))),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.surfaceLight)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildMiniRouteCard(AppRoute route) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.surfaceLight)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
            child: Text(route.lineNumber, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(route.routeName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textPrimary))),
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
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: AppColors.textPrimary, size: 20),
        ),
        title: Text(title, style: const TextStyle(color: AppColors.textPrimary)),
        trailing: Switch(
          value: value ?? false, 
          activeColor: AppColors.primary,
          trackColor: MaterialStateProperty.all(AppColors.surfaceLight),
          onChanged: onChanged,
        ),
      ),
    );
  }
}