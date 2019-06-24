import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:irenti/repository/catalog_repository.dart';

const int _kCount = 20;

class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  final String userId;
  final CatalogRepository _catalogRepository;

  CatalogBloc({@required CatalogRepository catalogRepository, this.userId})
      : assert(catalogRepository != null),
        _catalogRepository = catalogRepository;

  @override
  CatalogState get initialState => EmptyState();

  @override
  Stream<CatalogState> mapEventToState(CatalogEvent event) async* {
    if (event is CatalogEvent) {
      try {
        final state = currentState;
        if (state is LoadedState && !state.hasMore) return;
        final data = await _catalogRepository.fetchData(
          uid: userId,
          ids: event.ids,
          offset: state is LoadedState && event.ids == null ? state.entries.length : 0,
          count: _kCount,
        );
        yield LoadedState(
          state is LoadedState && event.ids == null ? state.entries + data : data,
          event.ids != null || data.length == _kCount,
        );
      } on Error catch (e) {
        print(e);
        print(e.stackTrace);
        yield ErrorState(e);
      }
    }
  }
}

@immutable
class CatalogState extends Equatable {
  CatalogState([List props]) : super(props ?? []);
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

  LoadedState(this.entries, [this.hasMore = true]) : super(<dynamic>[...entries, hasMore]);

  @override
  String toString() => 'LoadedState { entries: $entries }';
}

@immutable
class CatalogEvent extends Equatable {
  final List<String> ids;

  CatalogEvent([this.ids]) : super(ids ?? []);
}
