import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  @override
  ProfileState get initialState => ProfileState.empty();

  @override
  Stream<ProfileState> mapEventToState(
    ProfileEvent event,
  ) async* {
    // TODO: Add Logic
  }
}

@immutable
class ProfileState extends Equatable {
  final List<dynamic> data;

  ProfileState({
    @required this.data,
  }) : super(data);

  factory ProfileState.empty() => ProfileState(data: List(7));
}

@immutable
abstract class ProfileEvent extends Equatable {
  ProfileEvent([List props = const []]) : super(props);
}
