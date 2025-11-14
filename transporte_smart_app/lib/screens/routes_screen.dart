import 'dart:convert'; // Para jsonDecode
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:transporte_smart_app/theme/app_colors.dart';
import 'package:transporte_smart_app/models/route_model.dart';

class RoutesScreen extends StatefulWidget {
  const RoutesScreen({super.key});

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

  // 1. Cargar las rutas desde tu 'rutas.json'
  Future<void> _loadRoutes() async {
    try {
      final String data = await rootBundle.loadString('assets/rutas.json');
      final Map<String, dynamic> jsonMap = jsonDecode(data);

      final List<AppRoute> loadedRoutes = jsonMap.entries.map((entry) {
        // Usamos el 'factory constructor' que creamos en el modelo
        return AppRoute.fromJson(entry.key, entry.value as Map<String, dynamic>);
      }).toList();

      setState(() {
        _allRoutes = loadedRoutes;
        _filteredRoutes = loadedRoutes;
        _isLoading = false;
      });
    } catch (e) {
      print("Error cargando rutas: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 2. Lógica de filtro (como en tu RoutesScreen.tsx)
  void _filterRoutes(String query) {
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
    return Scaffold(
      backgroundColor: Colors.transparent, // El fondo ya está en main.dart
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 3. Encabezado (Traducción de tu 'motion.div') ---
            const SizedBox(height: 60), // Espacio para la barra de estado
            Text(
              "Mis Rutas",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Recientes y favoritas",
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),

            // --- 4. Barra de Búsqueda (Traducción de tu 'motion.div') ---
            _buildSearchBar(),
            const SizedBox(height: 24),

            // --- 5. Lista de Rutas (Traducción de tu 'filteredRoutes.map') ---
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredRoutes.isEmpty
                      ? Center(
                          child: Text(
                            "No se encontraron rutas.",
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredRoutes.length,
                          padding: const EdgeInsets.only(bottom: 120), // Para la barra de nav
                          itemBuilder: (context, index) {
                            return _RouteCard(route: _filteredRoutes[index]);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para la barra de búsqueda estilizada
  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: _filterRoutes, // Llama a la función de filtro
      style: TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: "Buscar línea o ruta...",
        hintStyle: TextStyle(color: AppColors.textSecondary),
        // Relleno y color de fondo
        filled: true,
        fillColor: AppColors.surface, // bg-white/5
        // Icono de búsqueda
        prefixIcon: Icon(
          LucideIcons.search,
          color: AppColors.textSecondary,
          size: 20,
        ),
        // Bordes
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.border), // border-white/10
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.primary), // Borde activo
        ),
      ),
    );
  }
}

// --- WIDGET DE TARJETA DE RUTA (Traducción de tu RouteItem) ---
class _RouteCard extends StatelessWidget {
  final AppRoute route;
  const _RouteCard({required this.route});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface, // bg-white/5
          border: Border.all(color: AppColors.border), // border-white/10
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Ícono de Minibús
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                // bg-gradient-to-br from-[#2DD4BF]/20...
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
                      // Número de Línea
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          // bg-gradient-to-r from-[#2DD4BF]...
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          route.lineNumber,
                          style: TextStyle(
                            color: AppColors.background,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Estrella de Favorito (como en tu diseño)
                      Icon(
                        LucideIcons.star,
                        color: AppColors.star,
                        size: 16,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Nombre de la Ruta
                  Text(
                    route.routeName,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  // Destino
                  Text(
                    "→ ${route.destination}",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}