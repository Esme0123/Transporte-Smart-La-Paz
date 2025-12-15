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
  late AnimationController _animController;
  
  // Posición inicial del bus (La Paz)
  LatLng _currentBusPos = const LatLng(-16.5000, -68.1193);
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    // Configura la duración del viaje simulado (20 segundos para la demo)
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
          const SnackBar(content: Text("Has llegado a tu destino")),
        );
      }
    });
  }

  // --- LÓGICA MATEMÁTICA PARA MOVER EL BUS ---
  void _updateBusPosition() {
    if (widget.activeRoute == null || widget.activeRoute!.coordinates.isEmpty) return;
    
    // Obtenemos los puntos reales de la ruta
    final List<LatLng> points = widget.isReturn 
        ? widget.activeRoute!.coordinates.reversed.toList() 
        : widget.activeRoute!.coordinates;

    if (points.isEmpty) return;

    final double value = _animController.value; // va de 0.0 a 1.0
    
    // Calcular en qué tramo de la línea estamos
    final int totalSegments = points.length - 1;
    final double currentStep = value * totalSegments; // ej: 4.5 (mitad del tramo 4)
    final int currentIndex = currentStep.floor();   
    final double segmentProgress = currentStep - currentIndex; 

    if (currentIndex < totalSegments) {
      final LatLng p1 = points[currentIndex];
      final LatLng p2 = points[currentIndex + 1];

      // Interpolación lineal (Matemática para hallar el punto medio)
      final double lat = p1.latitude + (p2.latitude - p1.latitude) * segmentProgress;
      final double lng = p1.longitude + (p2.longitude - p1.longitude) * segmentProgress;
      
      final newPos = LatLng(lat, lng);

      setState(() {
        _currentBusPos = newPos;
      });

      // Mover la cámara para seguir al bus
      _mapController.move(newPos, 15.0); 
    }
  }

  @override
  void didUpdateWidget(MapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si cambia la ruta, reseteamos
    if (widget.activeRoute != oldWidget.activeRoute) {
      _animController.reset();
      setState(() {
        _isNavigating = false;
        if (widget.activeRoute != null && widget.activeRoute!.coordinates.isNotEmpty) {
           _currentBusPos = widget.activeRoute!.coordinates.first;
           _mapController.move(_currentBusPos, 14.0);
        }
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _startSimulation() {
    if (widget.activeRoute != null && widget.activeRoute!.coordinates.isNotEmpty) {
       setState(() => _isNavigating = true);
       _animController.forward(from: 0.0);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Esta ruta no tiene mapa GPS")));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Definimos puntos a mostrar
    final hasCoords = widget.activeRoute != null && widget.activeRoute!.coordinates.isNotEmpty;
    final List<LatLng> pointsToShow = (hasCoords && widget.isReturn) 
        ? widget.activeRoute!.coordinates.reversed.toList()
        : (hasCoords ? widget.activeRoute!.coordinates : []);

    // Centro inicial
    final center = hasCoords ? pointsToShow.first : const LatLng(-16.5000, -68.1193);

    return Scaffold(
      body: Stack(
        children: [
          // 1. EL MAPA REAL
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 14.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png', 
                userAgentPackageName: 'com.example.transporte_smart_app',
                subdomains: const ['a', 'b', 'c'],
              ),
              
              if (hasCoords)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: pointsToShow,
                      strokeWidth: 6.0,
                      color: widget.isReturn ? AppColors.secondary : AppColors.primary,
                    ),
                  ],
                ),

              // BUS QUE SE MUEVE
              if (hasCoords)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentBusPos, // Esta variable se actualiza sola
                      width: 50,
                      height: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          color: widget.isReturn ? AppColors.secondary : AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10)
                          ]
                        ),
                        child: const Icon(LucideIcons.bus, color: Colors.black, size: 24),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // 2. PANEL DE INFORMACIÓN
          if (widget.activeRoute == null)
            _buildEmptyState()
          else if (!hasCoords)
             _buildErrorState()
          else
            _buildNavigationPanel(),
            
           // Botón Reset (Arriba derecha)
           if (hasCoords)
             Positioned(
               top: 50, right: 20,
               child: FloatingActionButton.small(
                 backgroundColor: AppColors.surface,
                 child: const Icon(LucideIcons.rotateCcw, color: Colors.white),
                 onPressed: () {
                   _animController.reset();
                   _mapController.move(pointsToShow.first, 14);
                   setState(() {
                     _isNavigating = false;
                     _currentBusPos = pointsToShow.first;
                   });
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
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: AppColors.surface.withOpacity(0.9), borderRadius: BorderRadius.circular(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(LucideIcons.map, size: 48, color: AppColors.textSecondary),
            Text("Mapa GPS", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
     return Positioned(
       bottom: 100, left: 20, right: 20,
       child: Container(
         padding: const EdgeInsets.all(16),
         decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
         child: const Text("Ruta sin datos de mapa.", style: TextStyle(color: Colors.white)),
       ),
     );
  }

  Widget _buildNavigationPanel() {
    final int minutesLeft = (45 * (1 - _animController.value)).round();
    final String labelIdaVuelta = widget.isReturn ? "VUELTA" : "IDA";

    return Positioned(
      bottom: 100, left: 16, right: 16,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.surfaceLight),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
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
                      Text("Hacia ${widget.activeRoute!.destination}", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                  child: Text(_isNavigating ? "$minutesLeft min" : "45 min", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
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
                  ),
                  icon: const Icon(LucideIcons.navigation),
                  label: const Text("INICIAR RASTREO"),
                ),
              )
            else
               const LinearProgressIndicator(color: AppColors.primary, backgroundColor: AppColors.surfaceLight),
          ],
        ),
      ),
    );
  }
}