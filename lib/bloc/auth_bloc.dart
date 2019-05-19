import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:irenti/repository/user_repository.dart';
import 'package:meta/meta.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository _userRepository;

  AuthenticationBloc({@required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository;

  @override
  AuthenticationState get initialState => Uninitialized();

  @override
  Stream<AuthenticationState> mapEventToState(AuthenticationEvent event) async* {
    if (event is AppStarted) {
      yield* _mapAppStartedToState();
    } else if (event is LoggedIn) {
      yield* _mapLoggedInToState();
    } else if (event is LoggedOut) {
      yield* _mapLoggedOutToState();
    } else if (event is UpdateProfile) {
      yield* _mapUpdateDataToState(event.data);
    } else if (event is UploadAvatar) {
      yield* _mapUploadAvatarToState(event.useCamera);
    }
  }

  Stream<AuthenticationState> _mapAppStartedToState() async* {
    try {
      final isSignedIn = await _userRepository.isSignedIn();
      if (isSignedIn) {
        final name = await _userRepository.getUser();
        final data = await _userRepository.getProfileData();
        yield Authenticated(name, data);
      } else {
        yield Unauthenticated();
      }
    } catch (_) {
      yield Unauthenticated();
    }
  }

  Stream<AuthenticationState> _mapLoggedInToState() async* {
    yield Authenticated(await _userRepository.getUser());
  }

  Stream<AuthenticationState> _mapLoggedOutToState() async* {
    yield Unauthenticated();
    _userRepository.signOut();
  }

  Stream<AuthenticationState> _mapUpdateDataToState(List data) async* {
    final state = currentState;
    if (state is Authenticated) {
      try {
        await _userRepository.updateProfileData(data);
        yield Authenticated(state.user, data);
      } catch (_) {}
    }
  }

  Stream<AuthenticationState> _mapUploadAvatarToState(bool useCamera) async* {
    final state = currentState;
    if (state is Authenticated) {
      try {
        await _userRepository.uploadAvatar(useCamera);
        yield Authenticated(await _userRepository.getUser(), state.data);
      } catch (_) {}
    }
  }
}

@immutable
abstract class AuthenticationState extends Equatable {
  AuthenticationState([List props = const []]) : super(props);
}

class Uninitialized extends AuthenticationState {
  @override
  String toString() => 'Uninitialized';
}

class Authenticated extends AuthenticationState {
  final FirebaseUser user;
  final List<dynamic> data;

  Authenticated(this.user, [this.data]) : super([user, ...data]);

  @override
  String toString() => 'Authenticated { displayName: ${user.displayName}, email: ${user.email}, data: $data }';
}

class Unauthenticated extends AuthenticationState {
  @override
  String toString() => 'Unauthenticated';
}

@immutable
abstract class AuthenticationEvent extends Equatable {
  AuthenticationEvent([List props = const []]) : super(props);
}

class AppStarted extends AuthenticationEvent {
  @override
  String toString() => 'AppStarted';
}

class LoggedIn extends AuthenticationEvent {
  @override
  String toString() => 'LoggedIn';
}

class LoggedOut extends AuthenticationEvent {
  @override
  String toString() => 'LoggedOut';
}

class UpdateProfile extends AuthenticationEvent {
  final List data;

  UpdateProfile(this.data);

  @override
  String toString() => 'UpdateProfile { data: $data }';
}

class UploadAvatar extends AuthenticationEvent {
  final bool useCamera;

  UploadAvatar(this.useCamera);

  @override
  String toString() => 'UploadAvatar';
}
