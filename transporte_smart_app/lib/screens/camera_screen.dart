import 'package:camera/camera.dart'; // Importante
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:transporte_smart_app/theme/app_colors.dart';
import 'package:transporte_smart_app/models/route_model.dart';
// Importaremos el servicio de IA luego

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

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  // Inicializar la cámara real
  Future<void> _initializeCamera() async {
    // 1. Pedir permisos
    var status = await Permission.camera.request();
    if (status.isDenied) return;

    // 2. Buscar cámaras
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    // 3. Configurar el controlador (Resolución media es suficiente para IA)
    _controller = CameraController(
      cameras[0], // Cámara trasera
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

  // --- FUNCIÓN DE DETECCIÓN (Pronto conectaremos la IA aquí) ---
  void _onTapDetect() {
    // POR AHORA: Sigue simulando para no romper la app mientras entrenas
    _simulateDetection();
    
    // FUTURO:
    // 1. Tomar foto con _controller.takePicture()
    // 2. Enviarla a AiService.runDetection()
    // 3. Buscar el resultado en el JSON
  }

  void _simulateDetection() {
    final Map<String, dynamic> fakeJson = {
      "nombre": "C. Chuquiaguillo - San Pedro",
      "paradas": {
        "ida": ["Plaza Villarroel", "Av. Busch", "Estadio", "Plaza San Pedro"],
        "vuelta": ["Plaza San Pedro", "Plaza Eguino", "Miraflores", "Av. Busch"]
      }
    };
    final AppRoute testRoute = AppRoute.fromJson("273", fakeJson);
    widget.onShowResult(testRoute);
  }

  @override
  Widget build(BuildContext context) {
    // Si la cámara no está lista, mostramos pantalla negra o loading
    if (!_isCameraInitialized || _controller == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    // Si está lista, mostramos la vista previa (CameraPreview)
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. VISTA PREVIA DE LA CÁMARA REAL
          CameraPreview(_controller!),

          // 2. Overlay Oscuro y Diseño (Igual que antes)
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

          // 3. Textos e Interfaz
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0).copyWith(top: 60.0),
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
                  "Apunta la cámara al letrero",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
                Expanded(
                  child: Center(
                    child: _buildScannerArea(),
                  ),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),

          // 4. Botón Zap
          _buildZapButton(),
        ],
      ),
    );
  }

  Widget _buildScannerArea() {
    return Container(
      width: 300,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1), // Un poco más transparente
        border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Icon(LucideIcons.scanLine, color: Colors.white.withOpacity(0.5), size: 40),
      ),
    );
  }

  Widget _buildZapButton() {
    return Positioned(
      bottom: 120,
      right: 24,
      child: InkWell(
        onTap: _onTapDetect, // Llama a la nueva función
        borderRadius: BorderRadius.circular(32),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              )
            ],
          ),
          child: const Icon(
            LucideIcons.zap,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}