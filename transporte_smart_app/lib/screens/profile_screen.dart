import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:transporte_smart_app/theme/app_colors.dart';
import 'package:transporte_smart_app/blocs/routes/routes_bloc.dart';
import 'package:transporte_smart_app/blocs/routes/routes_state.dart';
import 'package:transporte_smart_app/models/route_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Estado local para los interruptores
  bool _darkMode = true;
  bool _notifications = false;

  @override
  Widget build(BuildContext context) {
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
              Row(
                children: [
                  Container(
                    width: 70, height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: const Icon(LucideIcons.user, size: 30, color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Usuario Invitado", 
                        style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
                      Text("La Paz, Bolivia", 
                        style: TextStyle(color: AppColors.textPrimary.withOpacity(0.6), fontSize: 14)),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(child: _buildStatCard("Nivel", "Explorador", LucideIcons.medal)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard("Favoritos", "$favCount", LucideIcons.heart)),
                ],
              ),
              const SizedBox(height: 30),
              const Text("Mis Rutas Guardadas", 
                style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (favoriteRoutesList.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: const [
                      Icon(LucideIcons.info, color: AppColors.textSecondary),
                      SizedBox(width: 12),
                      Expanded(child: Text("Sin favoritos aún.", style: TextStyle(color: AppColors.textSecondary))),
                    ],
                  ),
                )
              else
                ...favoriteRoutesList.map((route) => _buildMiniRouteCard(route)),

              const SizedBox(height: 30),
               const Text("Configuración", 
                style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              
              // Interruptores ahora funcionan (visualmente)
              _buildSettingsTile("Modo Oscuro", LucideIcons.moon, _darkMode, (v) => setState(() => _darkMode = v)),
              _buildSettingsTile("Notificaciones", LucideIcons.bell, _notifications, (v) => setState(() => _notifications = v)),
              _buildSettingsTile("Ayuda y Soporte", LucideIcons.info, null, null),
              
              const SizedBox(height: 20),
              TextButton(onPressed: () {}, child: const Text("Cerrar Sesión", style: TextStyle(color: AppColors.error))),
            ],
          );
        },
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
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
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
          const Icon(LucideIcons.chevronRight, color: AppColors.textSecondary, size: 16),
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