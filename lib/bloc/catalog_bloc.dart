import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:irenti/repository/catalog_repository.dart';

const int _kCount = 20;

class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  final String userId;
  final CatalogRepository _catalogRepository;
  int _rooms;
  double _priceLow;
  double _priceHigh;
  List<dynamic> _profile;
  List<String> _metro;

  CatalogBloc({@required CatalogRepository catalogRepository, this.userId})
      : assert(catalogRepository != null),
        _catalogRepository = catalogRepository;

  @override
  CatalogState get initialState => EmptyState();

  int get roomsFilter => _rooms;
  double get priceLowFilter => _priceLow;
  double get priceHighFilter => _priceHigh;
  List<String> get metroFilter => _metro;

  Future<List<double>> get minMaxPrice => _catalogRepository.getMinMax();

  void clearFilters() {
    _rooms = null;
    _priceLow = null;
    _priceHigh = null;
    _metro = null;
  }

  @override
  Stream<CatalogState> mapEventToState(CatalogEvent event) async* {
    final state = this.state;
    try {
      if (event is CatalogFetch) {
        if (state is LoadedState && !state.hasMore) return;
        final data = await _catalogRepository.fetchData(
          uid: userId,
          profile: event.profile,
          ids: event.ids,
          offset: state is LoadedState && event.ids == null && !event.reload ? state.entries.length : 0,
          count: _kCount,
          roomCol: _rooms,
          priceLow: _priceLow,
          priceHigh: _priceHigh,
        );
        _profile = event.profile;
        yield LoadedState(
          state is LoadedState && event.ids == null && !event.reload ? state.entries + data : data,
          event.ids != null || data.length == _kCount,
        );
      } else if (event is CatalogReload) {
        yield EmptyState();
        final data = await _catalogRepository.fetchData(
          uid: userId,
          profile: _profile,
          offset: 0,
          count: _kCount,
          roomCol: _rooms,
          priceLow: _priceLow,
          priceHigh: _priceHigh,
          metro: _metro,
        );
        yield LoadedState(
          data,
          event.ids != null || data.length == _kCount,
        );
      } else if (event is CatalogCountWith && state is LoadedState) {
        yield LoadedState(
          state.entries,
          state.hasMore,
          true,
        );
        _rooms = event.rooms;
        _priceLow = event.priceLow;
        _priceHigh = event.priceHigh;
        _metro = event.metro != null ? List.of(event.metro) : null;
        final data = await _catalogRepository.countWith(
          roomCol: event.rooms,
          priceLow: event.priceLow,
          priceHigh: event.priceHigh,
          metro: event.metro,
        );
        yield LoadedState(
          state.entries,
          state.hasMore,
          false,
          data,
        );
      }
    } on Error catch (e) {
      print(e);
      print(e.stackTrace);
      yield ErrorState(e);
    }
  }
}

@immutable
class CatalogState extends Equatable {
  final List<Object> props;

  CatalogState([List props]) : props = props ?? [];
}

@immutable
class EmptyState extends CatalogState {
  @override
  String toString() => 'EmptyState {}';
}

@immutable
class ErrorState extends CatalogState {
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
class LoadedState extends CatalogState {
  final List<CatalogEntry> entries;
  final bool hasMore;
  final bool countLoading;
  final int count;

  LoadedState(this.entries, [this.hasMore = true, this.countLoading = false, this.count]) : super(<dynamic>[...entries, hasMore, countLoading, count]);

  @override
  String toString() => 'LoadedState { entries: $entries }';
}

@immutable
class CatalogEvent {}

@immutable
class CatalogFetch extends CatalogEvent {
  final List<dynamic> profile;
  final List<String> ids;
  final bool reload;

  CatalogFetch({this.profile, this.ids, this.reload = false});
}

@immutable
class CatalogReload extends CatalogEvent {
  final List<dynamic> profile;
  final List<String> ids;

  CatalogReload({this.profile, this.ids});
}

@immutable
class CatalogCountWith extends CatalogEvent {
  final int rooms;
  final double priceLow;
  final double priceHigh;
  final List<String> metro;

  CatalogCountWith({this.rooms, this.priceLow, this.priceHigh, this.metro});
}
