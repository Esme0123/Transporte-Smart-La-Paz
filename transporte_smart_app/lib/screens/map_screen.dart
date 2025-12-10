import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; 
import 'package:latlong2/latlong.dart';      
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:transporte_smart_app/theme/app_colors.dart';
import 'package:transporte_smart_app/models/route_model.dart';

class MapScreen extends StatefulWidget {
  final AppRoute? activeRoute;
  final bool isReturn;

  const MapScreen({
    super.key,
    this.activeRoute,
    this.isReturn = false,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  
  // Centro por defecto: La Paz
  LatLng _center = const LatLng(-16.5000, -68.1193);

  @override
  void didUpdateWidget(MapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si cambia la ruta y tiene coordenadas, centrar el mapa
    if (widget.activeRoute != null && 
        widget.activeRoute!.coordinates.isNotEmpty && 
        widget.activeRoute != oldWidget.activeRoute) {
      _mapController.move(widget.activeRoute!.coordinates.first, 14.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. VERIFICACIÓN DE DATOS 
    final hasCoords = widget.activeRoute != null && widget.activeRoute!.coordinates.isNotEmpty;
    
    final List<LatLng> pointsToShow = (hasCoords && widget.isReturn) 
        ? widget.activeRoute!.coordinates.reversed.toList()
        : (hasCoords ? widget.activeRoute!.coordinates : []);

    return Scaffold(
      body: Stack(
        children: [
          // --- CAPA 1: EL MAPA REAL ---
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              // Si hay puntos, centramos en el primero; si no, en La Paz general
              initialCenter: hasCoords ? pointsToShow.first : _center,
              initialZoom: 13.5,
            ),
            children: [
              // Tiles (El diseño visual del mapa - Gratis)
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                userAgentPackageName: 'com.tu_nombre.transporte_app', 
              ),
              
              // Dibujo de la Ruta (Línea Azul/Naranja)
              if (hasCoords)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: pointsToShow, // Aquí usamos la variable arreglada
                      strokeWidth: 5.0,
                      color: widget.isReturn ? AppColors.secondary : AppColors.primary,
                    ),
                  ],
                ),

              // Marcadores (Inicio y Fin)
              if (hasCoords && pointsToShow.isNotEmpty)
                MarkerLayer(
                  markers: [
                    // Inicio
                    Marker(
                      point: pointsToShow.first,
                      width: 40, height: 40,
                      child: const Icon(LucideIcons.mapPin, color: Colors.green, size: 30),
                    ),
                    // Fin
                    Marker(
                      point: pointsToShow.last,
                      width: 40, height: 40,
                      child: const Icon(LucideIcons.flag, color: Colors.red, size: 30),
                    ),
                  ],
                ),
            ],
          ),

          // --- CAPA 2: PANELES INFORMATIVOS ---
          
          // Caso A: No hay GPS para esta ruta
          if (widget.activeRoute != null && !hasCoords)
             Positioned(
               bottom: 100, left: 20, right: 20,
               child: Container(
                 padding: const EdgeInsets.all(16),
                 decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
                 child: Row(
                   children: const [
                     Icon(LucideIcons.triangleAlert, color: AppColors.secondary),
                     SizedBox(width: 12),
                     Expanded(child: Text("Sin GPS activo para esta ruta.", style: TextStyle(color: Colors.white))),
                   ],
                 ),
               ),
             ),

          // Caso B: Sí hay GPS -> Panel de Navegación
          if (hasCoords)
            Positioned(
              bottom: 100, left: 20, right: 20,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.surfaceLight),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Línea ${widget.activeRoute!.lineNumber}", 
                         style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18)),
                    Text(widget.activeRoute!.routeName, style: const TextStyle(color: Colors.white)),
                    const SizedBox(height: 10),
                    Row(
                      children: const [
                        Icon(LucideIcons.bus, color: Colors.white, size: 16),
                        SizedBox(width: 8),
                        Text("Rastreo GPS (OpenStreetMaps)", 
                             style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    )
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}