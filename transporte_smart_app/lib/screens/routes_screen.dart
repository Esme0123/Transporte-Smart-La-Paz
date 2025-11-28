import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:transporte_smart_app/theme/app_colors.dart';
import 'package:transporte_smart_app/models/route_model.dart';

class RoutesScreen extends StatefulWidget {
  // --- PARÁMETROS REQUERIDOS ---
  final List<String> favoriteRoutes;
  final Function(String) onToggleFavorite;
  final Function(AppRoute) onShowResult;

  const RoutesScreen({
    super.key,
    required this.favoriteRoutes,
    required this.onToggleFavorite,
    required this.onShowResult,
  });

  @override
  State<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> {
  List<AppRoute> _allRoutes = [];
  List<AppRoute> _filteredRoutes = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  // --- Carga de rutas a prueba de errores ---
  Future<void> _loadRoutes() async {
    try {
      final String data = await rootBundle.loadString('assets/rutas.json');
      final Map<String, dynamic> jsonMap = jsonDecode(data);
      final List<AppRoute> loadedRoutes = [];

      for (var entry in jsonMap.entries) {
        try {
          final route = AppRoute.fromJson(entry.key, entry.value as Map<String, dynamic>);
          loadedRoutes.add(route);
        } catch (e) {
          print("Error al cargar la ruta ${entry.key}: $e. Omitiendo.");
        }
      }

      setState(() {
        _allRoutes = loadedRoutes;
        _filteredRoutes = loadedRoutes;
        _isLoading = false;
      });
    } catch (e) {
      print("Error GIGANTE cargando rutas.json: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterRoutes(String query) {
    // ... (Esta función no cambia)
    if (query.isEmpty) {
      setState(() {
        _filteredRoutes = _allRoutes;
      });
      return;
    }

    final lowerQuery = query.toLowerCase();
    setState(() {
      _filteredRoutes = _allRoutes.where((route) {
        return route.lineNumber.contains(lowerQuery) ||
            route.routeName.toLowerCase().contains(lowerQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    @override
  Widget build(BuildContext context) {
    // CAMBIO 1: Quitamos el Scaffold, usamos un Container o SafeArea directamente
    return SafeArea( 
      bottom: false, // Dejar que el contenido fluya detrás del nav bar si es necesario
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20), // Ajustado espacio superior
            
            // Encabezados
            Text("Mis Rutas", 
                style: TextStyle(color: AppColors.textPrimary, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Recientes y favoritas", 
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
            const SizedBox(height: 24),
            
            // Barra de Búsqueda
            _buildSearchBar(),
            const SizedBox(height: 24),
            
            // Lista de Rutas
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredRoutes.isEmpty
                      ? Center(child: Text("No se encontraron rutas.", style: TextStyle(color: AppColors.textSecondary)))
                      : ListView.builder(
                          // CAMBIO 2: Padding inferior grande para que el último elemento 
                          // no quede tapado por la barra de navegación flotante.
                          padding: const EdgeInsets.only(bottom: 120),
                          itemCount: _filteredRoutes.length,
                          itemBuilder: (context, index) {
                            final route = _filteredRoutes[index];
                            final bool isFavorite = widget.favoriteRoutes.contains(route.lineNumber);

                            return _RouteCard(
                              route: route,
                              isFavorite: isFavorite,
                              onToggleFavorite: () {
                                widget.onToggleFavorite(route.lineNumber);
                              },
                              onShowResult: () {
                                // CAMBIO 3: Cerrar el teclado antes de navegar
                                FocusScope.of(context).unfocus();
                                widget.onShowResult(route);
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildSearchBar (Sin cambios)
  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: _filterRoutes,
      style: TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: "Buscar línea o ruta...",
        hintStyle: TextStyle(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surface,
        prefixIcon: Icon(LucideIcons.search, color: AppColors.textSecondary, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.primary)),
      ),
    );
  }
}

// --- WIDGET DE TARJETA DE RUTA (Actualizado) ---
class _RouteCard extends StatelessWidget {
  final AppRoute route;
  // --- PARÁMETROS REQUERIDOS ---
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
      // --- CAMBIO ---
      // Llama a la función para mostrar resultado
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
              // Ícono de Minibús (Sin cambios)
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(LucideIcons.bus, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 16),
              // Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Número de Línea (Sin cambios)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            route.lineNumber,
                            style: TextStyle(color: AppColors.background, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // --- CAMBIO ---
                        // Muestra la estrella solo si es favorita
                        if (isFavorite)
                          Icon(
                            LucideIcons.star,
                            color: AppColors.star,
                            size: 16,
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Nombre de la Ruta (Sin cambios)
                    Text(
                      route.routeName,
                      style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    // Destino (Sin cambios)
                    Text(
                      "→ ${route.destination}",
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // --- CAMBIO ---
              // Botón para (des)marcar favorito
              IconButton(
                icon: Icon(
                  LucideIcons.star, // El ícono es el mismo
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