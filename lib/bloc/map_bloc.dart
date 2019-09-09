import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:irenti/repository/catalog_repository.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final CatalogRepository _catalogRepository;

  MapBloc({@required CatalogRepository catalogRepository})
      : assert(catalogRepository != null),
        _catalogRepository = catalogRepository;

  @override
  MapState get initialState => MapState(loading: true);

  @override
  Stream<MapState> mapEventToState(MapEvent event) async* {
    final state = currentState;
    try {
      if (event is MapLoadEvent) {
        yield MapState(entries: state.entries, loading: true);
        final data = await _catalogRepository.findNearby(
          event.left,
          event.top,
          event.right,
          event.bottom,
        );
        yield MapState(entries: data);
      } else if (event is MapResetEvent) {
        yield MapState();
      }
    } on Error catch (e) {
      print(e);
      print(e.stackTrace);
      yield ErrorState(e);
    }
  }
}

@immutable
class MapState extends Equatable {
  final List<CatalogEntry> entries;
  final bool loading;

  MapState({this.entries = const [], this.loading = false}) : super(<dynamic>[loading, ...entries]);

  @override
  String toString() => 'MapState { entries: ${entries.length}, loading: $loading ';
}

@immutable
class ErrorState extends MapState {
  final Error e;

  ErrorState(this.e);

  @override
  String toString() => 'ErrorState { error: $e }';

  @override
  int get hashCode => e?.hashCode ?? 0;

  @override
  bool operator ==(Object other) => false;
}

@immutable
class MapEvent {}

@immutable
class MapLoadEvent extends MapEvent {
  final double left;
  final double top;
  final double right;
  final double bottom;

  MapLoadEvent(this.left, this.top, this.right, this.bottom);
}

@immutable
class MapResetEvent extends MapEvent {

}
