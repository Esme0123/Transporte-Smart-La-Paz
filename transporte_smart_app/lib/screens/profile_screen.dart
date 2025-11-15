import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:transporte_smart_app/theme/app_colors.dart';
import 'package:transporte_smart_app/screens/placeholder_screen.dart';
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Fondo de la app
      // Usamos ListView para que sea 'scrollable' si el contenido crece
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0).copyWith(top: 60.0, bottom: 120.0),
        children: [
          // --- Encabezado ---
          Text(
            "Perfil",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Tu cuenta y configuración",
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),

          // --- Estadísticas (Rutas y Favoritas) ---
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: "Rutas detectadas",
                  value: "47", // Puedes cambiar esto por una variable
                  icon: LucideIcons.mapPin,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  label: "Favoritas",
                  value: "8", // Puedes cambiar esto
                  icon: LucideIcons.star,
                  color: AppColors.star,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // --- Sección de Menú ---
          Text(
            "Menú",
            style: TextStyle(
              color: AppColors.textSecondary.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // --- Botones de Menú ---
          _MenuCard(
            label: "Configuración",
            icon: LucideIcons.settings,
            color: AppColors.textInactive,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => const PlaceholderScreen(title: "Configuración"),
              ));
            },
          ),
          _MenuCard(
            label: "Notificaciones",
            icon: LucideIcons.bell,
            color: AppColors.textInactive,
            badge: "3", // Añade un 'badge' como en tu diseño
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => const PlaceholderScreen(title: "Notificaciones"),
              ));
            },
          ),
          _MenuCard(
            label: "Ayuda y soporte",
            icon: LucideIcons.info,
            color: AppColors.textInactive,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => const PlaceholderScreen(title: "Ayuda y Soporte"),
              ));
            },
          ),
          const SizedBox(height: 16),
          // Botón de Cerrar Sesión (con color de error)
          _MenuCard(
            label: "Cerrar sesión",
            icon: LucideIcons.logOut,
            color: AppColors.error,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

// --- WIDGET PARA LAS TARJETAS DE ESTADÍSTICAS ---
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// --- WIDGET PARA LOS BOTONES DEL MENÚ ---
class _MenuCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final String? badge; // Opcional
  final VoidCallback onTap;

  const _MenuCard({
    required this.label,
    required this.icon,
    required this.color,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      // Usamos Material para el efecto 'ripple' al tocar
      child: Material(
        color: AppColors.surface.withOpacity(0.5), // bg-white/5
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          hoverColor: AppColors.surfaceLight, // hover:bg-white/10
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border), // border-white/10
            ),
            child: Row(
              children: [
                // Icono
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2), // Color de fondo del ícono
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 16),
                // Etiqueta
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: color == AppColors.error ? color : AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // Badge (si existe)
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.error, // bg-[#DC2626]
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badge!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (badge == null)
                  Icon(
                    LucideIcons.chevronRight,
                    color: AppColors.textInactive,
                    size: 16,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}