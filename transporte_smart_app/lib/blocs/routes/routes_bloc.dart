import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transporte_smart_app/models/route_model.dart';
import 'routes_event.dart';
import 'routes_state.dart';

class RoutesBloc extends Bloc<RoutesEvent, RoutesState> {
  
  RoutesBloc() : super(RoutesInitial()) {
    
    // 1. Manejar carga de rutas
    on<LoadRoutesEvent>((event, emit) async {
      emit(RoutesLoading());
      try {
        // Tu lógica de carga de JSON
        final String data = await rootBundle.loadString('assets/rutas.json');
        final Map<String, dynamic> jsonMap = jsonDecode(data);
        final List<AppRoute> loadedRoutes = [];

        for (var entry in jsonMap.entries) {
          try {
            final route = AppRoute.fromJson(entry.key, entry.value as Map<String, dynamic>);
            loadedRoutes.add(route);
          } catch (e) {
            print("Error parsing route ${entry.key}: $e");
          }
        }

        // Emitimos el estado "Cargado" con lista completa y filtrada iguales
        emit(RoutesLoaded(
          allRoutes: loadedRoutes,
          filteredRoutes: loadedRoutes,
          favoriteIds: const [], // Empieza sin favoritos (o carga de memoria si tienes)
        ));
      } catch (e) {
        emit(RoutesError("Error cargando rutas: $e"));
      }
    });

    // 2. Manejar búsqueda
    on<SearchRoutesEvent>((event, emit) {
      if (state is RoutesLoaded) {
        final currentState = state as RoutesLoaded;
        final query = event.query.toLowerCase();

        final filtered = currentState.allRoutes.where((route) {
          return route.lineNumber.contains(query) ||
              route.routeName.toLowerCase().contains(query);
        }).toList();

        emit(currentState.copyWith(filteredRoutes: filtered));
      }
    });

    // 3. Manejar favoritos
    on<ToggleFavoriteEvent>((event, emit) {
      if (state is RoutesLoaded) {
        final currentState = state as RoutesLoaded;
        final List<String> currentFavs = List.from(currentState.favoriteIds);

        if (currentFavs.contains(event.routeId)) {
          currentFavs.remove(event.routeId);
        } else {
          currentFavs.add(event.routeId);
        }

        emit(currentState.copyWith(favoriteIds: currentFavs));
      }
    });
  }
}