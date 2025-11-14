class AppRoute {
  final String lineNumber;
  final String routeName;
  final String destination; 
  final Map<String, List<String>> stops;

  AppRoute({
    required this.lineNumber,
    required this.routeName,
    required this.destination,
    required this.stops,
  });

  // Un 'factory constructor' para crear una ruta desde tu JSON
  factory AppRoute.fromJson(String number, Map<String, dynamic> json) {
    // Asumimos que el JSON tiene la estructura que definimos
    final paradas = json['paradas'] as Map<String, dynamic>;
    final paradasIda = (paradas['ida'] as List).map((e) => e.toString()).toList();
    final paradasVuelta = (paradas['vuelta'] as List).map((e) => e.toString()).toList();
    
    final String dest = paradasIda.isNotEmpty ? paradasIda.last : "Sin destino";

    return AppRoute(
      lineNumber: number,
      routeName: json['nombre'] as String,
      destination: dest,
      stops: {
        'ida': paradasIda,
        'vuelta': paradasVuelta,
      },
    );
  }
}