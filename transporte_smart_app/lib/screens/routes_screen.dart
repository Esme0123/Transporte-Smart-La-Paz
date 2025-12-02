import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:transporte_smart_app/theme/app_colors.dart';
import 'package:transporte_smart_app/models/route_model.dart';
import 'package:transporte_smart_app/blocs/routes/routes_bloc.dart';
import 'package:transporte_smart_app/blocs/routes/routes_state.dart';
import 'package:transporte_smart_app/blocs/routes/routes_event.dart';

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
            Text("Mis Rutas",
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold)),
            
            const SizedBox(height: 16),
            
            // --- BUSCADOR ---
            TextField(
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                // Dispara el evento al Bloc
                context.read<RoutesBloc>().add(SearchRoutesEvent(value));
              },
              decoration: InputDecoration(
                hintText: "Buscar línea (ej: 265, San Pedro...)",
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                prefixIcon: const Icon(LucideIcons.search, color: AppColors.primary),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Texto subtítulo
            const Text("Resultados",
                style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14)),
            
            const SizedBox(height: 10),

            // Lista de Rutas (BlocBuilder)
            Expanded(
              child: BlocBuilder<RoutesBloc, RoutesState>(
                builder: (context, state) {
                  if (state is RoutesLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is RoutesLoaded) {
                    if (state.filteredRoutes.isEmpty) {
                      return const Center(
                        child: Text("No se encontraron rutas", 
                        style: TextStyle(color: Colors.white))
                      );
                    }
                    
                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: state.filteredRoutes.length,
                      itemBuilder: (context, index) {
                        final route = state.filteredRoutes[index];
                        // Verificamos si esta ruta está en la lista de IDs favoritos
                        final isFav = state.favoriteIds.contains(route.lineNumber);
                        
                        return _RouteCard(
                          route: route,
                          isFavorite: isFav,
                          onTap: () => onShowResult(route),
                          onToggleFavorite: () {
                            context.read<RoutesBloc>().add(ToggleFavoriteEvent(route.lineNumber));
                          },
                        );
                      },
                    );
                  }
                  return const Text("Error al cargar", style: TextStyle(color: Colors.white));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- WIDGET TARJETA INDIVIDUAL (Faltaba esto) ---
class _RouteCard extends StatelessWidget {
  final AppRoute route;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const _RouteCard({
    required this.route,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Ícono de bus
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(LucideIcons.bus, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                
                // Textos
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "Línea ${route.lineNumber}",
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            ),
                          ),
                        ],
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
                
                // Botón Favorito
                IconButton(
                  icon: Icon(
                    isFavorite ? LucideIcons.star : LucideIcons.star, // Icono lleno si es favorito
                    fill: isFavorite ? 1.0 : 0.0, // Relleno visual (hack para Lucide) o usa Icons.star
                    color: isFavorite ? AppColors.star : AppColors.textSecondary.withOpacity(0.3),
                  ),
                  onPressed: onToggleFavorite,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}