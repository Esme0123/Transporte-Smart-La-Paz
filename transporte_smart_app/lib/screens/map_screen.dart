import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:transporte_smart_app/theme/app_colors.dart';
import 'package:transporte_smart_app/models/route_model.dart';
import 'package:transporte_smart_app/painters/route_line_painter.dart'; // Asegúrate de tener esto o quítalo si da error

class MapScreen extends StatelessWidget {
  final AppRoute? activeRoute; // Aceptamos una ruta opcional

  const MapScreen({super.key, this.activeRoute});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. EL MAPA DE FONDO (Imagen)
          Image.asset(
            'assets/images/map_bg.jpg',
            fit: BoxFit.cover,
          ),
          
          // Capa oscura sutil para que resalten los controles
          Container(color: Colors.black.withOpacity(0.2)),

          // 2. PIN DE UBICACIÓN (Simulado en el centro)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
                  ),
                  child: const Text(
                    "Tú estás aquí", 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 4),
                const Icon(LucideIcons.mapPin, color: AppColors.secondary, size: 40),
              ],
            ),
          ),

          // 3. UI DINÁMICA: ¿Hay ruta activa?
          if (activeRoute == null)
            _buildEmptyState()
          else
            _buildNavigationPanel(context, activeRoute!),
        ],
      ),
    );
  }

  // ESTADO VACÍO: Cuando entras al mapa sin buscar nada
  Widget _buildEmptyState() {
    return Positioned(
      top: 60,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceLight),
        ),
        child: Row(
          children: const [
            Icon(LucideIcons.search, color: AppColors.textSecondary),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                "Escanea una ruta o busca en el menú para ver el recorrido.",
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ESTADO ACTIVO: Panel de navegación estilo Google Maps
  Widget _buildNavigationPanel(BuildContext context, AppRoute route) {
    return Positioned(
      bottom: 100, // Espacio para el BottomBar
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera: Línea y Tiempo estimado (Simulado)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Línea ${route.lineNumber}",
                    style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "En camino • 15 min",
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Nombre de la ruta
            Text(
              route.routeName,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              "Hacia: ${route.destination}",
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            
            const SizedBox(height: 16),
            
            // Botón de acción (Falso GPS)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                   ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(content: Text("Iniciando navegación GPS... (Simulación)"))
                   );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(LucideIcons.navigation),
                label: const Text("IR AHORA"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}