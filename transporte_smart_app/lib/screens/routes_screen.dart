import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Importante
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
            Text("Mis Rutas",
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Recientes y favoritas",
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 16)),
            const SizedBox(height: 24),

            // Barra de búsqueda
            _buildSearchBar(context),
            const SizedBox(height: 24),

            // --- AQUÍ CONECTAMOS EL BLoC ---
            Expanded(
              child: BlocBuilder<RoutesBloc, RoutesState>(
                builder: (context, state) {
                  // 1. Estado Cargando
                  if (state is RoutesLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  // 2. Estado Cargado (Éxito)
                  if (state is RoutesLoaded) {
                    if (state.filteredRoutes.isEmpty) {
                      return Center(
                        child: Text("No se encontraron rutas.",
                            style: TextStyle(color: AppColors.textSecondary)),
                      );
                    }

                    return ListView.builder(
                      itemCount: state.filteredRoutes.length,
                      padding: const EdgeInsets.only(bottom: 120),
                      itemBuilder: (context, index) {
                        final route = state.filteredRoutes[index];
                        // Verificamos si es favorito mirando el estado del BLoC
                        final isFavorite = state.favoriteIds.contains(route.lineNumber);

                        return _RouteCard(
                          route: route,
                          isFavorite: isFavorite,
                          onToggleFavorite: () {
                            // ENVIAMOS EL EVENTO AL BLoC
                            context.read<RoutesBloc>().add(ToggleFavoriteEvent(route.lineNumber));
                          },
                          onShowResult: () => onShowResult(route),
                        );
                      },
                    );
                  }

                  // 3. Estado de Error
                  if (state is RoutesError) {
                    return Center(child: Text(state.message, style: TextStyle(color: Colors.red)));
                  }

                  // Estado inicial
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return TextField(
      // Ya no necesitamos controller, usamos onChanged directo al BLoC
      onChanged: (value) {
        context.read<RoutesBloc>().add(SearchRoutesEvent(value));
      },
      style: TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: "Buscar línea o ruta...",
        hintStyle: TextStyle(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surface,
        prefixIcon: Icon(LucideIcons.search,
            color: AppColors.textSecondary, size: 20),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.primary)),
      ),
    );
  }
}

// Tarjeta de Ruta (Esta queda casi igual, solo simplificada)
class _RouteCard extends StatelessWidget {
  final AppRoute route;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onShowResult;

  const _RouteCard({
    required this.route,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onShowResult,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onShowResult,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child:
                    Icon(LucideIcons.bus, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            route.lineNumber,
                            style: TextStyle(
                                color: AppColors.background,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (isFavorite)
                          Icon(LucideIcons.star,
                              color: AppColors.star, size: 16),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      route.routeName,
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "→ ${route.destination}",
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  LucideIcons.star,
                  color: isFavorite ? AppColors.star : AppColors.textInactive,
                ),
                onPressed: onToggleFavorite,
              ),
            ],
          ),
        ),
      ),
    );
  }
}