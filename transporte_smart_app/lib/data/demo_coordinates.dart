import 'package:latlong2/latlong.dart';

// Mapa de Línea -> Lista de Coordenadas
final Map<String, List<LatLng>> demoCoordinates = {
  // RUTA 265 (San Pedro - Chasquipampa)
  "265": [
    const LatLng(-16.50005, -68.13374), // Prado
    const LatLng(-16.50488, -68.12933), // UMSA
    const LatLng(-16.50900, -68.12500), // Estadio
    const LatLng(-16.51850, -68.11800), // Curva Holguin
    const LatLng(-16.52400, -68.11200), // Obrajes
    const LatLng(-16.53800, -68.09800), // Seguencoma
    const LatLng(-16.54500, -68.08500), // San Miguel
    const LatLng(-16.55500, -68.06500), // Chasquipampa
  ],
  // RUTA 200 (Av. 9 de Abril - Achumani)
  "200": [
    const LatLng(-16.50500, -68.14000), // San Pedro
    const LatLng(-16.51000, -68.13500), // Sopocachi
    const LatLng(-16.52000, -68.12000), // Kantutani
    const LatLng(-16.53500, -68.10000), // Costanera
    const LatLng(-16.54000, -68.09000), // Calacoto
    const LatLng(-16.54800, -68.07000), // Achumani
  ],
  // RUTA 260 (Minibus Trufi)
  "260": [
    const LatLng(-16.49500, -68.14500), // Cementerio
    const LatLng(-16.50000, -68.13800), // Perez Velasco
    const LatLng(-16.50500, -68.13000), // Camacho
    const LatLng(-16.51500, -68.12500), // Miraflores
    const LatLng(-16.52500, -68.11500), // Villa Copacabana
  ]
};