import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:irenti/repository/user_repository.dart';
import 'package:meta/meta.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository _userRepository;
  StreamController<String> _phoneStream;

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
    } else if (event is ToggleFave) {
      yield* _mapToggleFaveToState(event.id);
    } else if (event is UpdateName) {
      yield* _mapUpdateNameToState(event.name);
    } else if (event is UpdatePhone) {
      yield* _mapUpdatePhoneToState(event.data);
    }
  }

  Stream<AuthenticationState> _mapAppStartedToState() async* {
    try {
      final isSignedIn = await _userRepository.isSignedIn();
      if (isSignedIn) {
        final name = await _userRepository.getUser();
        final data = await _userRepository.getProfileData();
        final fave = await _userRepository.getFaves();
        yield Authenticated(name, data, fave);
      } else {
        yield Unauthenticated();
      }
    } catch (_) {
      yield Unauthenticated();
    }
  }

  Stream<AuthenticationState> _mapLoggedInToState() async* {
    final name = await _userRepository.getUser();
    final data = await _userRepository.getProfileData();
    final fave = await _userRepository.getFaves();
    yield Authenticated(name, data, fave);
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
        yield Authenticated(state.user, data, state.fave);
      } catch (_) {}
    }
  }

  Stream<AuthenticationState> _mapUploadAvatarToState(bool useCamera) async* {
    final state = currentState;
    if (state is Authenticated) {
      try {
        await _userRepository.uploadAvatar(useCamera);
        yield Authenticated(await _userRepository.getUser(), state.data, state.fave);
      } catch (_) {}
    }
  }

  Stream<AuthenticationState> _mapToggleFaveToState(String id) async* {
    final state = currentState;
    if (state is Authenticated) {
      try {
        List<String> faves = await _userRepository.toggleFave(state.fave, id);
        yield Authenticated(state.user, state.data, faves);
      } catch (_) {}
    }
  }

  Stream<AuthenticationState> _mapUpdateNameToState(String name) async* {
    final state = currentState;
    if (state is Authenticated) {
      try {
        final user = await _userRepository.updateName(name);
        yield Authenticated(user, state.data, state.fave);
      } catch (_) {}
    }
  }

  Stream<AuthenticationState> _mapUpdatePhoneToState(Stream<String> data) async* {
    final state = currentState;
    if (state is Authenticated) {
      try {
        final user = await _userRepository.updatePhone(data: data);
        yield Authenticated(user, state.data, state.fave);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _phoneStream?.close();
    _userRepository.getUser().then((user) {
      if (user != null && (user.email == null || user.email.isEmpty)) {
        _userRepository.signOut();
      }
    });
    super.dispose();
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
  final List data;
  final List<String> fave;

  Authenticated(this.user, [this.data, this.fave]) : super([user, ...data, ...fave]);

  @override
  String toString() => 'Authenticated { displayName: ${user.displayName}, email: ${user.email}, data: $data, fave: $fave }';
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

class ToggleFave extends AuthenticationEvent {
  final String id;

  ToggleFave(this.id);

  @override
  String toString() => 'ToggleFave { id: $id }';
}

class UpdateName extends AuthenticationEvent {
  final String name;

  UpdateName(this.name);

  @override
  String toString() => 'UpdateName { name: $name }';
}

class UpdatePhone extends AuthenticationEvent {
  final Stream<String> data;

  UpdatePhone(this.data);

  @override
  String toString() => 'UpdatePhone { data: $data }';
}
