import 'package:equatable/equatable.dart';

abstract class RoutesEvent extends Equatable {
  const RoutesEvent();

  @override
  List<Object> get props => [];
}

// Evento: Cuando la pantalla se abre y necesita cargar el JSON
class LoadRoutesEvent extends RoutesEvent {}

// Evento: Cuando el usuario escribe en el buscador
class SearchRoutesEvent extends RoutesEvent {
  final String query;
  const SearchRoutesEvent(this.query);

  @override
  List<Object> get props => [query];
}

// Evento: Cuando el usuario marca/desmarca favorito
class ToggleFavoriteEvent extends RoutesEvent {
  final String routeId;
  const ToggleFavoriteEvent(this.routeId);

  @override
  List<Object> get props => [routeId];
}