import 'dart:io'; // Para manejar archivos
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; 
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:transporte_smart_app/theme/app_colors.dart';
import 'package:transporte_smart_app/models/route_model.dart';
import 'package:transporte_smart_app/services/ai_service.dart';

class CameraScreen extends StatefulWidget {
  final Function(AppRoute) onShowResult;

  const CameraScreen({
    super.key,
    required this.onShowResult,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  final ImagePicker _picker = ImagePicker(); // Instancia para la galería

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadModel();
  }

  Future<void> _loadModel() async {
    await AiService().loadModel();
  }

  Future<void> _initializeCamera() async {
    var status = await Permission.camera.request();
    if (status.isDenied) return;

    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _controller = CameraController(
      cameras[0],
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      if (!mounted) return;
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      print("Error cámara: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  // --- LÓGICA CENTRAL DE IA ---
  // Esta función recibe una ruta de imagen (sea de cámara o galería) y la procesa
  Future<void> _processImage(String imagePath) async {
    try {
      // Mostrar indicador de carga
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Analizando ruta..."),
            duration: Duration(milliseconds: 1000)),
      );

      final detections = await AiService().runDetection(imagePath);

      if (detections != null && detections.isNotEmpty) {
        final topResult = detections.first;
        final String detectedLabel = topResult['label'];
        final double confidence = topResult['confidence'];

        print("Detectado: $detectedLabel ($confidence)");

        if (confidence > 0.40) {
          _findAndShowRoute(detectedLabel);
        } else {
          _mostrarError("No estoy seguro qué número es.");
        }
      } else {
        _mostrarError("No detecté ningún número de línea.");
      }
    } catch (e) {
      print("Error en procesamiento: $e");
      _mostrarError("Error al procesar la imagen.");
    }
  }

  // 1. Usar Cámara
  Future<void> _onTapCamera() async {
    if (!_isCameraInitialized || _controller == null) return;
    try {
      final image = await _controller!.takePicture();
      await _processImage(image.path);
    } catch (e) {
      _mostrarError("Error al tomar foto.");
    }
  }

  // 2. Usar Galería (NUEVO)
  Future<void> _onTapGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        await _processImage(image.path);
      }
    } catch (e) {
      _mostrarError("Error al abrir galería.");
    }
  }

  void _findAndShowRoute(String label) {
    // Creamos una ruta temporal con el ID detectado
    // El Bloc/ResultScreen se encargará de buscar los detalles si existen en el JSON
    final detectedRoute = AppRoute(
      lineNumber: label,
      routeName: "Ruta Detectada", 
      destination: "Ver detalles",
      stops: {},
    );
    widget.onShowResult(detectedRoute);
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized || _controller == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_controller!),
          
          // Overlay decorativo
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.background.withOpacity(0.8),
                  Colors.transparent,
                  AppColors.background.withOpacity(0.8)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // Textos
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0)
                .copyWith(top: 60.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Detección de Ruta",
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Apunta o sube una foto",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
                Expanded(child: Center(child: _buildScannerArea())),
                const SizedBox(height: 120),
              ],
            ),
          ),

          // CONTROLES INFERIORES
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Botón Galería (Izquierda)
                _buildGalleryButton(),

                // Botón Zap / Cámara (Centro - Más grande)
                _buildZapButton(),

                // Espacio vacío a la derecha para equilibrar (o para flash en el futuro)
                const SizedBox(width: 60), 
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerArea() {
    return Container(
      width: 300,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Icon(LucideIcons.scanLine,
            color: Colors.white.withOpacity(0.5), size: 40),
      ),
    );
  }

  Widget _buildZapButton() {
    return InkWell(
      onTap: _onTapCamera,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.white.withOpacity(0.4), width: 4),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 5,
            )
          ],
        ),
        child: const Icon(
          LucideIcons.zap,
          color: Colors.white,
          size: 36,
        ),
      ),
    );
  }

  Widget _buildGalleryButton() {
    return InkWell(
      onTap: _onTapGallery,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.6),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        ),
        child: const Icon(
          LucideIcons.image, // Ícono de imagen/galería
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}