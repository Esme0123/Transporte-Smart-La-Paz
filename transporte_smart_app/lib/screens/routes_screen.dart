import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:transporte_smart_app/theme/app_colors.dart';
import 'package:transporte_smart_app/models/route_model.dart';
import 'package:transporte_smart_app/blocs/routes/routes_bloc.dart';
import 'package:transporte_smart_app/blocs/routes/routes_state.dart';
import 'package:transporte_smart_app/blocs/routes/routes_event.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:transporte_smart_app/screens/login_screen.dart';

class RoutesScreen extends StatelessWidget {
  final Function(AppRoute) onShowResult;

  const RoutesScreen({
    super.key,
    required this.onShowResult,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            // Título
            const Text("Mis Rutas",
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold)),
            
            const SizedBox(height: 16),
            
            // --- BUSCADOR ---
            TextField(
              onChanged: (value) {
                context.read<RoutesBloc>().add(SearchRoutesEvent(value));
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Buscar línea o calle...",
                hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.5)),
                prefixIcon: const Icon(LucideIcons.search, color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // --- LISTA DE RUTAS ---
            Expanded(
              child: BlocBuilder<RoutesBloc, RoutesState>(
                builder: (context, state) {
                  if (state is RoutesLoading) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  } else if (state is RoutesLoaded) {
                    if (state.filteredRoutes.isEmpty) {
                      return const Center(child: Text("No se encontraron rutas", style: TextStyle(color: Colors.white)));
                    }

                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: state.filteredRoutes.length,
                      itemBuilder: (context, index) {
                        final route = state.filteredRoutes[index];
                        final isFavorite = state.favoriteIds.contains(route.lineNumber);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isFavorite ? AppColors.primary.withOpacity(0.5) : Colors.transparent,
                            ),
                          ),
                          child: InkWell(
                            onTap: () => onShowResult(route),
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  // Icono Bus
                                  Container(
                                    width: 40, height: 40,
                                    decoration: BoxDecoration(
                                      color: isFavorite ? AppColors.primary : AppColors.surfaceLight,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(LucideIcons.bus, color: Colors.black, size: 20),
                                  ),
                                  const SizedBox(width: 16),
                                  
                                  // Textos
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Línea ${route.lineNumber}",
                                          style: const TextStyle(
                                            color: AppColors.primary, 
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          route.routeName,
                                          style: const TextStyle(
                                              color: AppColors.textPrimary,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          "Destino: ${route.destination}",
                                          style: const TextStyle(
                                              color: AppColors.textSecondary, fontSize: 12),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // --- BOTÓN FAVORITO CON RESTRICCIÓN DE LOGIN ---
                                  IconButton(
                                    icon: Icon(
                                      isFavorite ? LucideIcons.star : LucideIcons.star,
                                      fill: isFavorite ? 1.0 : 0.0,
                                      color: isFavorite ? AppColors.star : AppColors.textSecondary.withOpacity(0.3),
                                    ),
                                    onPressed: () {
                                      // 1. Verificamos Login
                                      final user = FirebaseAuth.instance.currentUser;
                                      
                                      if (user == null) {
                                        // 2. Si es invitado -> Alerta
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            backgroundColor: AppColors.surface,
                                            title: const Text("Inicia Sesión", style: TextStyle(color: AppColors.textPrimary)),
                                            content: const Text("Debes registrarte para guardar tus rutas favoritas.", style: TextStyle(color: AppColors.textSecondary)),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: const Text("Cancelar", style: TextStyle(color: AppColors.textSecondary)),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                                                },
                                                child: const Text("Ir al Login", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                                              ),
                                            ],
                                          ),
                                        );
                                      } else {
                                        // 3. Si está logueado -> Guardamos (Llamada al BLoC)
                                        context.read<RoutesBloc>().add(ToggleFavoriteEvent(route.lineNumber));
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}