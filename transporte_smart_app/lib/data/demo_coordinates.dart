import 'package:latlong2/latlong.dart';

// Mapa de Línea -> Lista de Coordenadas
final Map<String, List<LatLng>> demoCoordinates = {
  "200": [
    const LatLng(-16.50550, -68.14700), // Av. 9 de Abril (Inicio)
    const LatLng(-16.50300, -68.14200), // Bajando por Faro Murillo
    const LatLng(-16.50050, -68.13800), // San Pedro
    const LatLng(-16.50200, -68.13300), // El Prado (Centro)
    const LatLng(-16.50800, -68.12600), // Estadio Hernando Siles (Miraflores)
    const LatLng(-16.51800, -68.11800), // Curva de Holguín (Teleférico)
    const LatLng(-16.52500, -68.11200), // Obrajes (Calle 10)
    const LatLng(-16.53200, -68.10500), // Obrajes (Calle 17)
    const LatLng(-16.54000, -68.09500), // Calacoto / San Miguel
    const LatLng(-16.54800, -68.08500), // Cota Cota
    const LatLng(-16.55500, -68.07000), // Laguna Cota Cota
    const LatLng(-16.56000, -68.06000), // El Vergel (Fin)
  ],

  // --- RUTA 265: Llojeta -> Villa Salomé (Cruce transversal) ---
  // Pasa por: Cementerio Jardín -> Sopocachi -> Pza España -> Estadio -> Villa Copacabana
  "265": [
    const LatLng(-16.51500, -68.14500), // Llojeta (Cementerio Jardín)
    const LatLng(-16.51200, -68.13800), // Sopocachi Alto
    const LatLng(-16.50800, -68.13200), // Plaza España
    const LatLng(-16.50500, -68.12800), // Av. 6 de Agosto
    const LatLng(-16.50200, -68.12500), // Puente de las Américas
    const LatLng(-16.49800, -68.12000), // Estadio (Lado Norte)
    const LatLng(-16.49500, -68.11500), // Villa Copacabana (Pza del Minero)
    const LatLng(-16.49000, -68.11000), // San Antonio
    const LatLng(-16.48800, -68.10500), // Villa Salomé (Fin)
  ],

  // --- RUTA 260: Cementerio -> Villa Copacabana (Ruta Corta) ---
  "260": [
    const LatLng(-16.48200, -68.15500), // Av. Gral Juan José Torres (Inicio Periférica)
    const LatLng(-16.49000, -68.14800), // Bajando por Chacaltaya
    const LatLng(-16.49500, -68.14200), // Av. Manco Kapac (Vita/San Sebastián)
    const LatLng(-16.50300, -68.13600), // San Pedro / Calle México
    const LatLng(-16.50900, -68.12800), // Av. 6 de Agosto (Sopocachi)
    const LatLng(-16.51500, -68.12200), // San Jorge / Puente de las Américas
    const LatLng(-16.52200, -68.11800), // Av. Héctor Ormachea (Obrajes Residencial)
    const LatLng(-16.53000, -68.11000), // Calle 14 Obrajes
    const LatLng(-16.53800, -68.10000), // Av. Roma / Mecapaca
    const LatLng(-16.54500, -68.09200), // Av. José Ballivián (Calacoto)
    const LatLng(-16.55000, -68.08500), // Av. Costanera
    const LatLng(-16.55500, -68.08000), // Los Rosales (Fin)
  ],
};