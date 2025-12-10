import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class AppRoute {
  final String lineNumber;
  final String routeName;
  final String destination;
  final Map<String, List<String>> stops;
  final List<LatLng> coordinates;

  AppRoute({
    required this.lineNumber,
    required this.routeName,
    required this.destination,
    required this.stops,
    this.coordinates = const [],
  });

  // Constructor BLINDADO para Firebase
  factory AppRoute.fromFirestore(Map<String, dynamic> json) {
    
    // 1. Manejo seguro de Paradas (Stops)
    Map<String, List<String>> parsedStops = {};
    try {
      if (json['stops'] != null) {
        // Usamos Map.from para asegurar que Dart entienda el tipo
        final rawStops = Map<String, dynamic>.from(json['stops']);
        
        rawStops.forEach((key, value) {
          if (value is List) {
            // Convertimos cada elemento de la lista a String explícitamente
            parsedStops[key] = value.map((e) => e.toString()).toList();
          }
        });
      }
    } catch (e) {
      print("Error parseando paradas de ${json['lineNumber']}: $e");
    }

    // 2. Manejo seguro de Coordenadas
    List<LatLng> parsedCoords = [];
    try {
      if (json['coordinates'] != null && json['coordinates'] is List) {
        var coordsList = json['coordinates'] as List;
        for (var point in coordsList) {
          if (point is Map) {
            // Caso: se subió como Map {'lat': x, 'lng': y}
            parsedCoords.add(LatLng(
              (point['lat'] as num).toDouble(), 
              (point['lng'] as num).toDouble()
            ));
          } else if (point is GeoPoint) {
            // Caso: se subió como GeoPoint nativo de Firebase
            parsedCoords.add(LatLng(point.latitude, point.longitude));
          }
        }
      }
    } catch (e) {
      print("Error parseando coordenadas: $e");
    }

    return AppRoute(
      lineNumber: (json['lineNumber'] ?? '000').toString(),
      routeName: (json['routeName'] ?? 'Ruta Sin Nombre').toString(),
      destination: (json['destination'] ?? '').toString(),
      stops: parsedStops,
      coordinates: parsedCoords,
    );
  }

  // Convertir a Map para subir a Firebase (Usado por el script)
  Map<String, dynamic> toMap() {
    return {
      'lineNumber': lineNumber,
      'routeName': routeName,
      'destination': destination,
      'stops': stops,
      'coordinates': coordinates.map((c) => {'lat': c.latitude, 'lng': c.longitude}).toList(),
    };
  }

  // Helper para el JSON local (si alguna vez se necesita)
  factory AppRoute.fromJson(String number, Map<String, dynamic> json) {
    return AppRoute(
      lineNumber: number,
      routeName: json['nombre'] ?? '',
      destination: '',
      stops: {},
    );
  }
}