import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:transporte_smart_app/theme/app_colors.dart';
import 'package:transporte_smart_app/models/route_model.dart';
// ¡Ya no necesitamos importar ResultScreen aquí!

class CameraScreen extends StatelessWidget {
  // --- PARÁMETRO REQUERIDO ---
  final Function(AppRoute) onShowResult;

  const CameraScreen({
    super.key,
    required this.onShowResult,
  });

  // --- FUNCIÓN DE NAVEGACIÓN SIMULADA ---
  void _simulateDetection(BuildContext context) {
    // 1. Creamos una ruta de prueba
    final Map<String, dynamic> fakeJson = {
      "nombre": "C. Chuquiaguillo - San Pedro",
      "paradas": {
        "ida": [
          "Plaza Villarroel",
          "Av. Busch",
          "Estadio",
          "Plaza San Pedro"
        ],
        "vuelta": [
          "Plaza San Pedro",
          "Plaza Eguino",
          "Miraflores",
          "Av. Busch"
        ]
      }
    };
    final AppRoute testRoute = AppRoute.fromJson("273", fakeJson);

    // 2. --- CAMBIO ---
    // Ya no usamos Navigator.push. Llamamos a la función del padre.
    onShowResult(testRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // --- Fondo de Cámara Simulado ---
          Image.asset(
            'assets/images/camera_bg.jpg',
            fit: BoxFit.cover,
          ),
          Container(
            color: AppColors.background.withOpacity(0.4),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.background.withOpacity(0.8),
                  Colors.transparent,
                  AppColors.background.withOpacity(0.8)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // --- Contenido Principal ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0).copyWith(top: 60.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- CAMBIO DE TEXTO (Paso anterior) ---
                Text(
                  "Detección de Ruta",
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Apunta la cámara al letrero",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
                Expanded(
                  child: Center(
                    child: _buildScannerArea(),
                  ),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),

          // --- Botón de "Zap" (Detección) ---
          _buildZapButton(context),
        ],
      ),
    );
  }

  // Widget para el área de escaneo (Sin cambios)
  Widget _buildScannerArea() {
    return Container(
      width: 300,
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          "Enfoca el letrero del minibús",
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }

  // Widget para el botón "Zap" (Sin cambios)
  Widget _buildZapButton(BuildContext context) {
    return Positioned(
      bottom: 120,
      right: 24,
      child: InkWell(
        onTap: () => _simulateDetection(context), // Llama a la simulación
        borderRadius: BorderRadius.circular(32),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              )
            ],
          ),
          child: const Icon(
            LucideIcons.zap,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}