import 'dart:async';

import 'package:async/async.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:irenti/model/messages.dart';
import 'package:irenti/repository/messages_repository.dart';

class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  final MessagesRepository _messagesRepository;
  Map<String, Stream<Conversation>> _chatStreams;
  StreamSubscription _allSub;

  MessagesBloc({@required MessagesRepository messagesRepository})
      : assert(messagesRepository != null),
        _messagesRepository = messagesRepository;

  @override
  MessagesState get initialState => EmptyState();

  LoadedState _sortedLoaded(List<Conversation> dialogs) {
    dialogs = List.from(dialogs)..sort((a, b) => b.messages.last.timestamp.compareTo(a.messages.last.timestamp));
    return LoadedState(dialogs);
  }

  @override
  Stream<MessagesState> mapEventToState(MessagesEvent event) async* {
    try {
      if (event is MessagesInitEvent) {
        List<Conversation> chats = await _messagesRepository.fetchDialogs(event.userId);
        yield _sortedLoaded(chats);
        _chatStreams = _messagesRepository.getStreams(chats.map((c) => c.id));
        _allSub = StreamZip(_chatStreams.values).listen((data) {
          dispatch(_MessagesSetEvent(data));
        }, onDone: () {
          _allSub?.cancel();
          _allSub = null;
        });
      } else if (event is _MessagesSetEvent) {
        yield _sortedLoaded(event.dialogs);
      } else if (event is MessagesSendEvent) {
        _messagesRepository.sendMessage(event.chatId, event.userId, event.text);
      }
    } on Error catch (e) {
      print(e);
      print(e.stackTrace);
      yield ErrorState(e);
    }
  }

  @override
  void dispose() {
    _allSub?.cancel();
    super.dispose();
  }
}

@immutable
class MessagesState extends Equatable {
  MessagesState([List props]) : super(props ?? []);
}

@immutable
class EmptyState extends MessagesState {
  @override
  String toString() => 'EmptyState {}';
}

@immutable
class ErrorState extends MessagesState {
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
class LoadedState extends MessagesState {
  final List<Conversation> entries;

  LoadedState(this.entries) : super(entries);

  @override
  String toString() => 'LoadedState { entries: $entries }';

  @override
  int get hashCode => entries?.hashCode ?? 0;

  @override
  bool operator ==(Object other) => false;
}

@immutable
class MessagesEvent extends Equatable {
  MessagesEvent([List props]) : super(props ?? []);
}

@immutable
class MessagesInitEvent extends MessagesEvent {
  final String userId;

  MessagesInitEvent(this.userId) : super([userId]);
}

@immutable
class _MessagesSetEvent extends MessagesEvent {
  final List<Conversation> dialogs;

  _MessagesSetEvent(this.dialogs) : super(dialogs.toList(growable: false));
}

@immutable
class MessagesSendEvent extends MessagesEvent {
  final String chatId;
  final String userId;
  final String text;

  MessagesSendEvent(this.userId, this.chatId, this.text) : super([userId, chatId, text]);
}
