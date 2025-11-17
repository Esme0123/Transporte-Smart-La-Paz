import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:transporte_smart_app/theme/app_colors.dart';

// --- WIDGET PARA EL PIN DEL MAPA ---
Widget buildMapPin(String label, Color color) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
        ),
      ),
      const SizedBox(height: 4),
      Icon(LucideIcons.mapPin, color: color, size: 32),
    ],
  );
}

// --- PAINTER PARA LA LÍNEA ---
class RouteLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AppColors.primary.withOpacity(0.8)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Offset start = Offset(
      (size.width * (-0.4 + 1) / 2),
      (size.height * (-0.35 + 1) / 2) + 35,
    );

    final Offset end = Offset(
      (size.width * (0.4 + 1) / 2),
      (size.height * (-0.15 + 1) / 2) + 35,
    );

    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}