import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Imports de tu proyecto
import 'package:transporte_smart_app/theme/app_colors.dart';
import 'package:transporte_smart_app/models/route_model.dart';
import 'package:transporte_smart_app/services/ai_service.dart';
import 'package:transporte_smart_app/blocs/routes/routes_bloc.dart';

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
  bool _isAnalyzing = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initCamera();
    // Cargamos el modelo al entrar
    AiService().loadModel();
  }

  Future<void> _initCamera() async {
    var status = await Permission.camera.request();
    if (status.isGranted) {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _controller = CameraController(
          cameras[0],
          ResolutionPreset.medium, // Medium es suficiente para YOLO y rápido
          enableAudio: false,
        );
        await _controller!.initialize();
        if (!mounted) return;
        setState(() {
          _isCameraInitialized = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------
  // 1. LÓGICA REAL (IA)
  // ---------------------------------------------------------
  Future<void> _onTapCamera() async {
    if (!_isCameraInitialized || _controller == null || _isAnalyzing) return;
    
    setState(() => _isAnalyzing = true);
    
    try {
      // A. Mostrar feedback visual
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Analizando..."),
          duration: Duration(seconds: 1),
          backgroundColor: AppColors.primary,
        ),
      );

      // B. Tomar foto
      final XFile image = await _controller!.takePicture();
      final File imageFile = File(image.path);
      final Uint8List imageBytes = await imageFile.readAsBytes();
      final decodedImage = await decodeImageFromList(imageBytes);

      // C. Ejecutar IA
      final detections = await AiService().runDetection(
        imageBytes, 
        decodedImage.height, 
        decodedImage.width
      );

      if (!mounted) return;

      // D. Procesar resultados
      if (detections != null && detections.isNotEmpty) {
        // Tomamos la primera detección (la de mayor confianza)
        // Ajusta la clave 'tag' según devuelva tu modelo (puede ser 'tag', 'label', 'class')
        final String detectedLabel = detections.first['tag'].toString(); 
        
        print("IA Detectó: $detectedLabel");

        final foundRoute = context.read<RoutesBloc>().findRouteByLabel(detectedLabel);

        if (foundRoute != null) {
          widget.onShowResult(foundRoute);
        } else {
          _showError("Ruta '$detectedLabel' detectada, pero no está en la base de datos.");
        }
      } else {
        _showError("No se detectó ningún número de ruta claro.");
      }

    } catch (e) {
      print("Error cámara: $e");
      _showError("Error al procesar la imagen.");
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  Future<void> _onTapGallery() async {
     // Aquí iría la lógica similar pero con _picker.pickImage
     _showError("Galería deshabilitada en demo.");
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  // ---------------------------------------------------------
  // 2. LÓGICA DEMO (HACK PARA PRESENTACIÓN)
  // ---------------------------------------------------------
  void _simularDemo() {
    // Forzamos la búsqueda de la ruta 200 o 265
    // Asegúrate que "200" o "265" exista en tu rutas.json
    final route = context.read<RoutesBloc>().findRouteByLabel("200"); 
    
    if (route != null) {
      widget.onShowResult(route);
    } else {
      _showError("Error Demo: La ruta '200' no existe en el JSON.");
    }
  }

  // ---------------------------------------------------------
  // 3. INTERFAZ GRÁFICA
  // ---------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Vista de la Cámara
          CameraPreview(_controller!),
          
          // 2. Capa oscura inferior (Controles)
          Column(
            children: [
              const Spacer(),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Botón Galería
                    IconButton(
                      icon: const Icon(LucideIcons.image, color: Colors.white, size: 30),
                      onPressed: _onTapGallery, 
                    ),
                    
                    // BOTÓN PRINCIPAL (SCAN REAL)
                    InkWell(
                      onTap: _onTapCamera,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isAnalyzing ? Colors.grey : AppColors.primary,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 5,
                            )
                          ],
                        ),
                        child: _isAnalyzing 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Icon(LucideIcons.scan, size: 40, color: Colors.black),
                      ),
                    ),

                    // Botón Girar Cámara (Visual)
                    IconButton(
                      icon: const Icon(LucideIcons.rotateCcw, color: Colors.white, size: 30),
                      onPressed: () {}, 
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 3. BOTÓN DEMO FLOTANTE (Arriba a la derecha)
          Positioned(
            top: 50,
            right: 20,
            child: FloatingActionButton.extended(
              onPressed: _simularDemo,
              backgroundColor: AppColors.secondary,
              icon: const Icon(LucideIcons.play),
              label: const Text("DEMO"),
            ),
          ),
          
          // 4. Botón Atrás
           Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}