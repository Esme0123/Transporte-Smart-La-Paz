import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // Mapa real
import 'package:latlong2/latlong.dart';      // Coordenadas
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:transporte_smart_app/theme/app_colors.dart';
import 'package:transporte_smart_app/models/route_model.dart';
import 'package:transporte_smart_app/data/demo_coords.dart'; // Importa las coords

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
  late final MapController _mapController;
  late AnimationController _animController;
  
  // Posición actual del bus simulado
  LatLng _currentBusPos = const LatLng(-16.50000, -68.15000); // Default La Paz
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    
    // Animación de 20 segundos para que se vea suave
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );

    _animController.addListener(() {
      _updateBusPosition();
    });

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _isNavigating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Has llegado a Chasquipampa", style: TextStyle(color: Colors.white))),
        );
      }
    });
  }

  // --- LÓGICA MATEMÁTICA PARA MOVER EL BUS ---
  void _updateBusPosition() {
    if (widget.activeRoute == null) return;
    
    // Usamos las coordenadas del archivo demo_coords.dart
    // Si es vuelta, invertimos la lista
    final List<LatLng> points = widget.isReturn 
        ? ruta265Coords.reversed.toList() 
        : ruta265Coords;

    final double value = _animController.value; // va de 0.0 a 1.0
    
    // Calcular índice basado en el progreso
    // Si hay 10 tramos, y vamos al 50% (0.5), estamos en el tramo 5.
    final int totalPoints = points.length - 1;
    final double currentStep = value * totalPoints; // ej: 4.5
    final int currentIndex = currentStep.floor();   // índice 4
    final double segmentProgress = currentStep - currentIndex; // 0.5 del tramo

    if (currentIndex < totalPoints) {
      final LatLng p1 = points[currentIndex];
      final LatLng p2 = points[currentIndex + 1];

      // Interpolación lineal entre dos puntos GPS
      final double lat = p1.latitude + (p2.latitude - p1.latitude) * segmentProgress;
      final double lng = p1.longitude + (p2.longitude - p1.longitude) * segmentProgress;
      
      final newPos = LatLng(lat, lng);

      setState(() {
        _currentBusPos = newPos;
      });

      // Mover la cámara del mapa para seguir al bus
      _mapController.move(newPos, 15.0); 
    }
  }

  @override
  void didUpdateWidget(MapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si cambia la ruta, reseteamos (solo funciona real para la 265/200 en esta demo)
    if (widget.activeRoute != oldWidget.activeRoute) {
      _animController.reset();
      setState(() => _isNavigating = false);
      
      // Centrar mapa en el inicio de la ruta demo
      if (widget.activeRoute != null) {
        _mapController.move(ruta265Coords.first, 14.0);
        _currentBusPos = ruta265Coords.first;
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _startSimulation() {
    setState(() => _isNavigating = true);
    _animController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    // Si no hay ruta, centramos en La Paz general
    final center = widget.activeRoute != null ? ruta265Coords.first : const LatLng(-16.5000, -68.1193);

    return Scaffold(
      body: Stack(
        children: [
          // 1. EL MAPA REAL
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 14.0,
              interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
            ),
            children: [
              // A. Capa de Mapa (Estilo Oscuro GRATIS de CartoDB)
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                userAgentPackageName: 'com.example.app',
              ),
              
              // B. Línea de la Ruta (Solo si hay ruta activa)
              if (widget.activeRoute != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: ruta265Coords,
                      strokeWidth: 5.0,
                      color: widget.isReturn ? AppColors.secondary : AppColors.primary,
                    ),
                  ],
                ),

              // C. Marcador del BUS (Se mueve)
              if (widget.activeRoute != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentBusPos,
                      width: 50,
                      height: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          color: widget.isReturn ? AppColors.secondary : AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: (widget.isReturn ? AppColors.secondary : AppColors.primary).withOpacity(0.6), blurRadius: 15)
                          ]
                        ),
                        child: const Icon(LucideIcons.bus, color: Colors.black, size: 24),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // 2. UI SUPERIOR (Botón atrás si venimos de detalle)
          // (Opcional, depende de tu flujo)

          // 3. PANELES INFERIORES
          if (widget.activeRoute == null)
            _buildEmptyState()
          else
            _buildNavigationPanel(),
            
          // Botón Reset Demo
           if (widget.activeRoute != null)
             Positioned(
               top: 50, right: 20,
               child: FloatingActionButton.small(
                 backgroundColor: AppColors.surface,
                 child: const Icon(LucideIcons.rotateCcw, color: Colors.white),
                 onPressed: () {
                   _animController.reset();
                   _mapController.move(ruta265Coords.first, 14);
                   setState(() => _isNavigating = false);
                 },
               ),
             )
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.9),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.surfaceLight),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(LucideIcons.map, size: 48, color: AppColors.textSecondary),
            SizedBox(height: 16),
            Text("Mapa Interactivo", style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Selecciona una ruta para ver su rastreo GPS en tiempo real.", textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationPanel() {
    final int minutesLeft = (20 * (1 - _animController.value)).round();
    final String labelIdaVuelta = widget.isReturn ? "VUELTA" : "IDA";

    return Positioned(
      bottom: 100, left: 16, right: 16,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20)],
          border: Border.all(color: AppColors.surfaceLight),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(LucideIcons.bus, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text("Línea ${widget.activeRoute!.lineNumber}", style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                                color: widget.isReturn ? AppColors.secondary : AppColors.primary,
                                borderRadius: BorderRadius.circular(4)),
                            child: Text(labelIdaVuelta, style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                      Text("En camino hacia ${widget.activeRoute!.destination}", 
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                  child: Text(_isNavigating ? "$minutesLeft min" : "GPS", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                )
              ],
            ),
            const SizedBox(height: 16),
            if (!_isNavigating)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _startSimulation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(LucideIcons.navigation),
                  label: const Text("SEGUIR BUS EN TIEMPO REAL"),
                ),
              )
            else
               Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   const Text("Actualizando ubicación...", style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                   const SizedBox(height: 6),
                   LinearProgressIndicator(
                     value: _animController.value,
                     color: widget.isReturn ? AppColors.secondary : AppColors.primary, 
                     backgroundColor: AppColors.surfaceLight,
                     borderRadius: BorderRadius.circular(4),
                    ),
                 ],
               ),
          ],
        ),
      ),
    );
  }
}