import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Importante
import 'package:transporte_smart_app/models/route_model.dart';
import 'package:transporte_smart_app/repositories/routes_repository.dart';
import 'routes_event.dart';
import 'routes_state.dart';

class RoutesBloc extends Bloc<RoutesEvent, RoutesState> {
  final RoutesRepository repository;
  RoutesBloc({required this.repository}) : super(RoutesInitial()) {
    
    // 1. Cargar Rutas y Favoritos al inicio
    on<LoadRoutesEvent>((event, emit) async {
      emit(RoutesLoading());
      try {
        final routes = await repository.getAllRoutes();

        emit(RoutesLoaded(
          allRoutes: routes,
          filteredRoutes: routes,
          favoriteIds: [], // Esto luego lo conectamos con SharedPreferences
        ));
      } catch (e) {
        emit(RoutesError("Error de BD: $e"));
      }
    });

    // 2. Buscador Manual
    on<SearchRoutesEvent>((event, emit) {
      if (state is RoutesLoaded) {
        final currentState = state as RoutesLoaded;
        final query = event.query.toLowerCase().trim();

        final filtered = currentState.allRoutes.where((route) {
          return route.lineNumber.toLowerCase().contains(query) ||
                 route.routeName.toLowerCase().contains(query);
        }).toList();

        emit(currentState.copyWith(filteredRoutes: filtered));
      }
    });

    // 3. Toggle Favoritos (Guardar en disco)
    on<ToggleFavoriteEvent>((event, emit) async {
      if (state is RoutesLoaded) {
        final currentState = state as RoutesLoaded;
        final List<String> currentFavs = List.from(currentState.favoriteIds);

        if (currentFavs.contains(event.routeId)) {
          currentFavs.remove(event.routeId);
        } else {
          currentFavs.add(event.routeId);
        }

        // Guardar persistente
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList('favorite_routes', currentFavs);

        emit(currentState.copyWith(favoriteIds: currentFavs));
      }
    });
  }

  // MÉTODO EXTRA: Ayuda a buscar una ruta específica desde la Cámara
  AppRoute? findRouteByLabel(String label) {
    if (state is RoutesLoaded) {
      final currentState = state as RoutesLoaded;
      try {
        return currentState.allRoutes.firstWhere(
          (r) => r.lineNumber.trim().toLowerCase() == label.trim().toLowerCase()
        );
      } catch (e) {
        return null; // No encontrada
      }
    }
    return null;
  }
}