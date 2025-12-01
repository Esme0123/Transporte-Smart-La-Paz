import 'package:flutter_vision/flutter_vision.dart';
import 'dart:typed_data'; // Necesario para manejar bytes de imagen

class AiService {
  static final AiService _instance = AiService._internal();
  factory AiService() => _instance;
  AiService._internal();

  late FlutterVision _vision;
  bool _isModelLoaded = false;

  // 1. Cargar el Modelo
  Future<void> loadModel() async {
    if (_isModelLoaded) return;
    _vision = FlutterVision();

    try {
      await _vision.loadYoloModel(
        modelPath: "assets/model/yolov8n.tflite", 
        labels: "assets/model/labels.txt",
        modelVersion: "yolov8", // Le decimos explícitamente que es YOLOv8
        quantization: false,    // Usamos float16 (lo que bajaste de Colab), no int8
        numThreads: 2,
        useGpu: false,
      );
      print("Modelo YOLOv8 cargado correctamente");
      _isModelLoaded = true;
    } catch (e) {
      print("Error al cargar modelo: $e");
    }
  }

  // 2. Ejecutar detección (Ahora recibe bytes de imagen, es más rápido)
  Future<List<Map<String, dynamic>>?> runDetection(Uint8List imageBytes, int height, int width) async {
    if (!_isModelLoaded) return null;

    try {
      final result = await _vision.yoloOnImage(
        bytesList: imageBytes,
        imageHeight: height,
        imageWidth: width,
        iouThreshold: 0.4, // Sensibilidad de superposición
        confThreshold: 0.4, // Confianza mínima (40%)
        classThreshold: 0.4,
      );
      return result;
    } catch (e) {
      print("Error en detección: $e");
      return null;
    }
  }

  void dispose() async {
    await _vision.closeYoloModel();
    _isModelLoaded = false;
  }
}