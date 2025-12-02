import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:transporte_smart_app/theme/app_colors.dart';
import 'package:transporte_smart_app/models/route_model.dart';
import 'dart:ui';

class MapScreen extends StatefulWidget {
  final AppRoute? activeRoute;
  final bool isReturn; // Esto controla la dirección del bus

  const MapScreen({
    super.key, 
    this.activeRoute,
    this.isReturn = false, 
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _isNavigating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("¡Has llegado a tu destino!")),
        );
      }
    });
  }

  // Esto es vital: Si cambia la ruta o la dirección (Ida/Vuelta), reseteamos
  @override
  void didUpdateWidget(MapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeRoute != oldWidget.activeRoute || widget.isReturn != oldWidget.isReturn) {
      _controller.reset();
      setState(() => _isNavigating = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startNavigation() {
    setState(() => _isNavigating = true);
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/map_bg.jpg', fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.2)),

          if (widget.activeRoute != null)
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  painter: _RouteSimulationPainter(
                    progress: _animation.value,
                    color: widget.isReturn ? AppColors.secondary : AppColors.primary,
                    isReturn: widget.isReturn, // Pasamos el dato clave
                  ),
                  size: Size.infinite,
                );
              },
            ),

          if (widget.activeRoute == null)
            _buildEmptyState()
          else
            _buildNavigationPanel(),
            
           if (widget.activeRoute != null)
             Positioned(
               top: 50, right: 20,
               child: IconButton(
                 icon: const Icon(LucideIcons.rotateCcw, color: Colors.black),
                 style: IconButton.styleFrom(backgroundColor: Colors.white),
                 onPressed: () {
                   _controller.reset();
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
          color: AppColors.surface.withOpacity(0.95),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(LucideIcons.map, size: 48, color: AppColors.textSecondary),
            SizedBox(height: 16),
            Text("Sin ruta activa", style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Escanea o busca una ruta.", textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationPanel() {
    final int minutesLeft = (15 * (1 - _animation.value)).round();
    final String labelIdaVuelta = widget.isReturn ? "VUELTA" : "IDA";

    return Positioned(
      bottom: 100, left: 16, right: 16,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 20)],
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
                      Text(widget.activeRoute!.destination, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                  child: Text(_isNavigating ? "$minutesLeft min" : "15 min", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                )
              ],
            ),
            const SizedBox(height: 16),
            if (!_isNavigating)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _startNavigation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(LucideIcons.navigation),
                  label: const Text("INICIAR VIAJE"),
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

class _RouteSimulationPainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool isReturn;

  _RouteSimulationPainter({required this.progress, required this.color, required this.isReturn});

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path();
    // Curva del mapa
    path.moveTo(size.width * 0.2, size.height * 0.7);
    path.quadraticBezierTo(size.width * 0.5, size.height * 0.5, size.width * 0.8, size.height * 0.3);

    final Paint linePaint = Paint()
      ..color = AppColors.textSecondary.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, linePaint);

    // --- MAGIA: Si es vuelta (isReturn=true), invertimos el progreso (1.0 - progress) ---
    // Esto hace que el bus vaya del final al inicio.
    final double effectiveProgress = isReturn ? (1.0 - progress) : progress;

    final PathMetrics pathMetrics = path.computeMetrics();
    final PathMetric metric = pathMetrics.first;
    final Tangent? tangent = metric.getTangentForOffset(metric.length * effectiveProgress);

    if (tangent != null) {
      final Offset busPos = tangent.position;
      canvas.drawCircle(busPos + const Offset(0,4), 12, Paint()..color = Colors.black45..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
      canvas.drawCircle(busPos, 10, Paint()..color = color);
      canvas.drawCircle(busPos, 10, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2);
    }
  }

  @override
  bool shouldRepaint(covariant _RouteSimulationPainter oldDelegate) => oldDelegate.progress != progress || oldDelegate.isReturn != isReturn;
}