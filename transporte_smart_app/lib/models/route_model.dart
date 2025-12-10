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

  // Constructor desde Firebase
  factory AppRoute.fromFirestore(Map<String, dynamic> json) {
    // 1. Manejo de Paradas
    Map<String, List<String>> parsedStops = {};
    if (json['stops'] != null) {
      Map<String, dynamic> rawStops = json['stops'];
      rawStops.forEach((key, value) {
        if (value is List) {
          parsedStops[key] = value.map((e) => e.toString()).toList();
        }
      });
    }

    // 2. Manejo de Coordenadas (GeoPoint a LatLng)
    List<LatLng> parsedCoords = [];
    if (json['coordinates'] != null) {
      var coordsList = json['coordinates'] as List;
      for (var point in coordsList) {
        if (point is GeoPoint) {
          parsedCoords.add(LatLng(point.latitude, point.longitude));
        } else if (point is Map) {
          // Por si subimos como Map simple
          parsedCoords.add(LatLng(point['lat'], point['lng']));
        }
      }
    }

    return AppRoute(
      lineNumber: json['lineNumber'] ?? '000',
      routeName: json['routeName'] ?? 'Sin Nombre',
      destination: json['destination'] ?? '',
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

  // Mantén tu fromJson antiguo si quieres, pero adáptalo para devolver AppRoute
  factory AppRoute.fromJson(String number, Map<String, dynamic> json) {

     final paradasMap = json['paradas'] is Map<String, dynamic> 
        ? json['paradas'] as Map<String, dynamic> 
        : <String, dynamic>{};

    final rawIda = paradasMap['ida'];
    final List<String> paradasIda = (rawIda is List) 
        ? rawIda.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList() 
        : [];
    
    final rawVuelta = paradasMap['vuelta'];
    final List<String> paradasVuelta = (rawVuelta is List) 
        ? rawVuelta.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList() 
        : [];

    return AppRoute(
      lineNumber: number,
      routeName: json['nombre'] ?? '',
      destination: paradasIda.isNotEmpty ? paradasIda.last : '',
      stops: {
        'ida': paradasIda,
        'vuelta': paradasVuelta
      },
    );
  }
}