import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:transporte_smart_app/models/route_model.dart';
import 'package:transporte_smart_app/data/demo_coordinates.dart';

class DataUploader {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> uploadJsonToFirebase() async {
    try {
      // 1. Cargar el JSON local
      final String data = await rootBundle.loadString('assets/rutas.json');
      final Map<String, dynamic> jsonMap = jsonDecode(data);

      print("--- INICIANDO CARGA MASIVA A FIREBASE ---");

      // 2. Recorrer cada ruta
      for (var entry in jsonMap.entries) {
        String routeId = entry.key.trim(); // ej: "265"
        
        AppRoute tempRoute = AppRoute.fromJson(routeId, entry.value);

        // 3. ENRIQUECIMIENTO: ¿Tenemos coordenadas para esta ruta?
        List<Map<String, double>> coordsForFirebase = [];
        
        if (demoCoordinates.containsKey(routeId)) {
          print(">> Agregando GPS real para ruta $routeId");
          coordsForFirebase = demoCoordinates[routeId]!
              .map((c) => {'lat': c.latitude, 'lng': c.longitude})
              .toList();
        }

        // 4. Preparar datos finales
        Map<String, dynamic> finalData = {
          'lineNumber': tempRoute.lineNumber,
          'routeName': tempRoute.routeName,
          'destination': tempRoute.destination,
          'stops': tempRoute.stops,
          'coordinates': coordsForFirebase, // Lista vacía o lista real
          'searchKeywords': _generateKeywords(tempRoute), // Extra: Para buscar mejor
        };

        // 5. Subir a Firestore (Usamos set para sobreescribir si ya existe)
        await _firestore.collection('rutas').doc(routeId).set(finalData);
      }
      
      print("--- CARGA COMPLETADA CON ÉXITO ---");
      
    } catch (e) {
      print("ERROR EN CARGA: $e");
    }
  }

  // Genera palabras clave para búsqueda simple en Firebase
  List<String> _generateKeywords(AppRoute route) {
    List<String> keywords = [];
    keywords.add(route.lineNumber.toLowerCase());
    keywords.addAll(route.routeName.toLowerCase().split(' '));
    return keywords;
  }
}