import 'package:equatable/equatable.dart';
import 'package:transporte_smart_app/models/route_model.dart';

abstract class RoutesState extends Equatable {
  const RoutesState();
  
  @override
  List<Object> get props => [];
}

class RoutesInitial extends RoutesState {}

class RoutesLoading extends RoutesState {}

class RoutesLoaded extends RoutesState {
  final List<AppRoute> allRoutes;      // Todas las rutas del JSON
  final List<AppRoute> filteredRoutes; // Las que mostramos (si hay filtro)
  final List<String> favoriteIds;      // IDs de las favoritas

  const RoutesLoaded({
    required this.allRoutes,
    required this.filteredRoutes,
    required this.favoriteIds,
  });

  // Un método helper para copiar el estado y cambiar solo lo necesario
  RoutesLoaded copyWith({
    List<AppRoute>? allRoutes,
    List<AppRoute>? filteredRoutes,
    List<String>? favoriteIds,
  }) {
    return RoutesLoaded(
      allRoutes: allRoutes ?? this.allRoutes,
      filteredRoutes: filteredRoutes ?? this.filteredRoutes,
      favoriteIds: favoriteIds ?? this.favoriteIds,
    );
  }

  @override
  List<Object> get props => [allRoutes, filteredRoutes, favoriteIds];
}

class RoutesError extends RoutesState {
  final String message;
  const RoutesError(this.message);
}