import 'package:flutter_tflite/flutter_tflite.dart';

class AiService {
  // Patrón Singleton (para tener una sola instancia del cerebro)
  static final AiService _instance = AiService._internal();
  factory AiService() => _instance;
  AiService._internal();

  bool _isModelLoaded = false;

  // 1. Cargar el Modelo (Llamaremos a esto al iniciar la app)
  Future<void> loadModel() async {
    if (_isModelLoaded) return;

    try {
      String? res = await Tflite.loadModel(
        model: "assets/model/yolov8n.tflite", // El archivo que bajaremos de Roboflow
        labels: "assets/model/labels.txt",     // Las etiquetas (273, 212, etc.)
        numThreads: 1, // Usa 1 o 2 núcleos del celular
        isAsset: true,
        useGpuDelegate: false,
      );
      
      print("Modelo cargado: $res");
      _isModelLoaded = true;
    } catch (e) {
      print("Error al cargar modelo: $e");
    }
  }

  // 2. Ejecutar detección en una imagen
  Future<List<dynamic>?> runDetection(String imagePath) async {
    if (!_isModelLoaded) return null;

    try {
      var recognitions = await Tflite.detectObjectOnImage(
        path: imagePath,
        model: "YOLO", // Importante para YOLO
        threshold: 0.5, // Confianza mínima (50%)
        imageMean: 0.0,
        imageStd: 255.0,
        numResultsPerClass: 1,
      );
      return recognitions;
    } catch (e) {
      print("Error en detección: $e");
      return null;
    }
  }

  // Liberar memoria
  void dispose() {
    Tflite.close();
    _isModelLoaded = false;
  }
}