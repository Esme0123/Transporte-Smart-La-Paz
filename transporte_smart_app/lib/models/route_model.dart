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

  factory AppRoute.fromJson(String number, Map<String, dynamic> json) {
    // 1. PROTECCIÓN: Si no hay paradas, usamos un mapa vacío
    final paradasMap = json['paradas'] is Map<String, dynamic> 
        ? json['paradas'] as Map<String, dynamic> 
        : <String, dynamic>{};

    // 2. PROTECCIÓN: Si 'ida' es null, usamos lista vacía []
    final rawIda = paradasMap['ida'];
    final List<String> paradasIda = (rawIda is List) 
        ? rawIda.map((e) => e.toString()).toList() 
        : [];

    // 3. PROTECCIÓN: Si 'vuelta' es null, usamos lista vacía []
    final rawVuelta = paradasMap['vuelta'];
    final List<String> paradasVuelta = (rawVuelta is List) 
        ? rawVuelta.map((e) => e.toString()).toList() 
        : [];
    
    // Calculamos destino seguro
    final String dest = paradasIda.isNotEmpty 
        ? paradasIda.last 
        : (json['nombre'] ?? "Sin destino"); // Fallback al nombre si no hay paradas

    return AppRoute(
      lineNumber: number,
      routeName: json['nombre']?.toString() ?? "Ruta Desconocida", // Protección nombre null
      destination: dest,
      stops: {
        'ida': paradasIda,
        'vuelta': paradasVuelta,
      },
    );
  }
}