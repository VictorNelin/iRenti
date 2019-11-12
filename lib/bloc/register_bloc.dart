import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:irenti/repository/user_repository.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final UserRepository _userRepository;

  RegisterBloc({@required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository;

  @override
  RegisterState get initialState => RegisterState.empty();

  @override
  Stream<RegisterState> mapEventToState(
      RegisterEvent event,
      ) async* {
    if (event is SubmittedPhone) {
      yield* _mapFormSubmittedToState(event.phone);
    } else if (event is SubmittedCode) {
      yield* _mapCodeSubmittedToState(state.vId, event.code);
    } else if (event is SubmittedData) {
      yield* _mapDataSubmittedToState(event.name, event.email, event.password);
    }
  }

  Stream<RegisterState> _mapFormSubmittedToState(
      String phone,
      ) async* {
    yield RegisterState.loading();
    try {
      String vId = await _userRepository.signUp(
        phone: phone,
      );
      _userRepository.verifyState?.then((_) => add(SubmittedCode(code: null)));
      yield RegisterState.awaitingCode(vId);
    } catch (_) {
      yield RegisterState.failure();
    }
  }

  Stream<RegisterState> _mapCodeSubmittedToState([
      String vId,
      String code,
      ]) async* {
    if (code == null) {
      yield RegisterState.awaitingData();
      return;
    }
    yield RegisterState.loading();
    try {
      await _userRepository.verify(
        vId: vId,
        code: code,
      );
      yield RegisterState.awaitingData();
    } catch (e) {
      print(e);
      yield RegisterState.failure();
    }
  }

  Stream<RegisterState> _mapDataSubmittedToState(
      String name,
      String email,
      String password,
      ) async* {
    yield RegisterState.loading();
    try {
      await _userRepository.setData(
        name: name,
        email: email,
        password: password,
      );
      yield RegisterState.success();
    } catch (e) {
      print(e);
      yield RegisterState.failure();
    }
  }
}

@immutable
class RegisterState {
  final bool isSubmitting;
  final bool isAwaitingCode;
  final bool isAwaitingData;
  final bool isSuccess;
  final bool isFailure;
  final String vId;

  RegisterState({
    @required this.isSubmitting,
    @required this.isAwaitingCode,
    @required this.isAwaitingData,
    @required this.isSuccess,
    @required this.isFailure,
    this.vId,
  });

  factory RegisterState.empty() {
    return RegisterState(
      isSubmitting: false,
      isAwaitingCode: false,
      isAwaitingData: false,
      isSuccess: false,
      isFailure: false,
    );
  }

  factory RegisterState.loading() {
    return RegisterState(
      isSubmitting: true,
      isAwaitingCode: false,
      isAwaitingData: false,
      isSuccess: false,
      isFailure: false,
    );
  }

  factory RegisterState.awaitingCode(String vId) {
    return RegisterState(
      isSubmitting: false,
      isAwaitingCode: true,
      isAwaitingData: false,
      isSuccess: false,
      isFailure: false,
      vId: vId,
    );
  }

  factory RegisterState.awaitingData() {
    return RegisterState(
      isSubmitting: false,
      isAwaitingCode: false,
      isAwaitingData: true,
      isSuccess: false,
      isFailure: false,
    );
  }

  factory RegisterState.failure() {
    return RegisterState(
      isSubmitting: false,
      isAwaitingCode: false,
      isAwaitingData: false,
      isSuccess: false,
      isFailure: true,
    );
  }

  factory RegisterState.success() {
    return RegisterState(
      isSubmitting: false,
      isAwaitingCode: false,
      isAwaitingData: false,
      isSuccess: true,
      isFailure: false,
    );
  }

  RegisterState copyWith({
    bool isPhoneValid,
    bool isSubmitEnabled,
    bool isSubmitting,
    bool isAwaitingCode,
    bool isAwaitingData,
    bool isSuccess,
    bool isFailure,
  }) {
    return RegisterState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isAwaitingCode: isAwaitingCode ?? this.isAwaitingCode,
      isAwaitingData: isAwaitingData ?? this.isAwaitingData,
      isSuccess: isSuccess ?? this.isSuccess,
      isFailure: isFailure ?? this.isFailure,
    );
  }

  @override
  String toString() {
    return '''RegisterState {
      isSubmitting: $isSubmitting,
      isAwaitingCode: $isAwaitingCode,
      isAwaitingData: $isAwaitingData,
      isSuccess: $isSuccess,
      isFailure: $isFailure,
    }''';
  }
}

@immutable
abstract class RegisterEvent extends Equatable {
  final List<Object> props;

  RegisterEvent([this.props = const []]);
}

class SubmittedPhone extends RegisterEvent {
  final String phone;

  SubmittedPhone({@required this.phone})
      : super([phone]);

  @override
  String toString() {
    return 'SubmittedPhone { phone: $phone }';
  }
}

class SubmittedCode extends RegisterEvent {
  final String code;

  SubmittedCode({@required this.code})
      : super([code]);

  @override
  String toString() {
    return 'SubmittedCode { code: $code }';
  }
}

class SubmittedData extends RegisterEvent {
  final String name;
  final String email;
  final String password;

  SubmittedData({@required this.name, @required this.email, @required this.password})
      : super([name, email, password]);

  @override
  String toString() {
    return 'SubmittedData { name: $name, email: $email, password: $password }';
  }
}
