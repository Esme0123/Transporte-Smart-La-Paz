import 'dart:io';
import 'dart:typed_data'; // Necesario para manejar bytes
import 'dart:ui' as ui;   // Necesario para decodificar imagen y sacar tamaño
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Importante para BLoC

// Imports de tu proyecto
import 'package:transporte_smart_app/theme/app_colors.dart';
import 'package:transporte_smart_app/models/route_model.dart';
import 'package:transporte_smart_app/services/ai_service.dart';
import 'package:transporte_smart_app/blocs/routes/routes_bloc.dart';
import 'package:transporte_smart_app/blocs/routes/routes_state.dart';

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
  final ImagePicker _picker = ImagePicker();

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

  // --- LÓGICA DE PROCESAMIENTO DE IMAGEN (IA) ---
  Future<void> _processImage(XFile imageFile) async {
    try {
      // 1. Mostrar feedback visual
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Analizando imagen..."),
            duration: Duration(milliseconds: 800)),
      );

      // 2. Leer bytes (Requisito de flutter_vision)
      final Uint8List imageBytes = await File(imageFile.path).readAsBytes();

      // 3. Obtener dimensiones reales de la imagen
      final ui.Image decodedImage = await decodeImageFromList(imageBytes);

      // 4. Enviar a la IA
      final detections = await AiService().runDetection(
        imageBytes,
        decodedImage.height,
        decodedImage.width,
      );

      // 5. Analizar resultados
      if (detections != null && detections.isNotEmpty) {
        // La librería devuelve una lista, tomamos el mejor resultado
        final topResult = detections.first;
        
        // NOTA: flutter_vision usa la clave 'tag' para la clase detectada
        final String detectedLabel = topResult['tag']; 
        
        // La confianza ya viene filtrada por el servicio (0.4), así que confiamos.
        print("Detectado: $detectedLabel");
        
        // BUSCAR LA RUTA EN LA BASE DE DATOS (BLoC)
        _findAndShowRoute(detectedLabel);
        
      } else {
        _mostrarError("No detecté ningún número de línea claro.");
      }
    } catch (e) {
      print("Error procesando imagen: $e");
      _mostrarError("Error técnico al analizar la imagen.");
    }
  }

  // --- BUSCAR EN EL BLOC (Base de Datos JSON) ---
  void _findAndShowRoute(String label) {
    print("Buscando en BLoC la línea: $label");

    // 1. Obtenemos el estado actual de las rutas
    final state = context.read<RoutesBloc>().state;
    AppRoute? rutaEncontrada;

    // 2. Buscamos en la lista cargada
    if (state is RoutesLoaded) {
      try {
        // Buscamos coincidencia exacta (ej. "200" == "200")
        // Ojo: asegúrate que tu labels.txt coincida con las claves del JSON
        rutaEncontrada = state.allRoutes.firstWhere(
          (route) => route.lineNumber == label,
        );
      } catch (e) {
        print("El número $label no existe en el JSON.");
      }
    }

    // 3. Mostramos el resultado
    if (rutaEncontrada != null) {
      // ¡Éxito! Tenemos la ruta completa con paradas
      widget.onShowResult(rutaEncontrada);
    } else {
      // Fallo parcial: La IA vio un número, pero no tenemos info de él
      // Creamos una ruta temporal para mostrar algo al usuario
      final rutaDesconocida = AppRoute(
        lineNumber: label,
        routeName: "Ruta no registrada",
        destination: "Sin información",
        stops: {}, // Lista vacía
      );
      widget.onShowResult(rutaDesconocida);
      _mostrarError("Línea $label detectada, pero no hay datos de ruta.");
    }
  }

  // --- BOTONES ---
  Future<void> _onTapCamera() async {
    if (!_isCameraInitialized || _controller == null) return;
    try {
      final image = await _controller!.takePicture();
      await _processImage(image);
    } catch (e) {
      _mostrarError("Error al tomar foto.");
    }
  }

  Future<void> _onTapGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        await _processImage(image);
      }
    } catch (e) {
      _mostrarError("Error al abrir galería.");
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: AppColors.error),
    );
  }

  // --- INTERFAZ GRÁFICA ---
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
          // 1. Vista de Cámara
          CameraPreview(_controller!),

          // 2. Overlay Oscuro
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

          // 3. Textos Superiores
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

          // 4. Botones Inferiores
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildGalleryButton(),
                _buildZapButton(),
                const SizedBox(width: 60), // Espacio para equilibrar
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
        child: Icon(LucideIcons.scanLine, color: Colors.white.withOpacity(0.5), size: 40),
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
          LucideIcons.image,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}