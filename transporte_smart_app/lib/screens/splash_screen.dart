import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:transporte_smart_app/theme/app_colors.dart';
import 'package:transporte_smart_app/main.dart'; // Para navegar a AppShell

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  
  @override
  void initState() {
    super.initState();
    _iniciarCarga();
  }

  // Simulamos la carga de datos (Base de datos, IA, etc.)
  Future<void> _iniciarCarga() async {
    // Aquí podrías cargar tu RoutesBloc si quisieras esperar a que termine
    // Por ahora, usamos un retraso estético de 3 segundos
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      // Navegamos a la App Principal (AppShell) y borramos el historial para no volver atrás
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AppShell()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo o Ícono animado
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: 5,
                  )
                ],
              ),
              child: const Icon(
                LucideIcons.bus, // O tu logo si tienes imagen
                size: 64,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            
            // Texto de Título
            const Text(
              "Transporte Smart",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "La Paz, Bolivia",
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                letterSpacing: 2,
              ),
            ),
            
            const SizedBox(height: 64),
            
            // Indicador de Carga Personalizado
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}