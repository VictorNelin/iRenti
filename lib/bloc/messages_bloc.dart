import 'dart:async';

import 'package:async/async.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:irenti/model/messages.dart';
import 'package:irenti/repository/messages_repository.dart';

class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  final MessagesRepository _messagesRepository;
  StreamSubscription _allSub;

  MessagesBloc({@required MessagesRepository messagesRepository})
      : assert(messagesRepository != null),
        _messagesRepository = messagesRepository;

  @override
  MessagesState get initialState => EmptyState();

  MessagesLoadedState _sortedLoaded(String uid, List<Conversation> dialogs) {
    dialogs = List.from(dialogs)..sort((a, b) {
      int aLast, bLast;
      try {
        aLast = a.messages.last.timestamp;
      } catch (_) {
        aLast = a.startedOn ?? 0;
      }
      try {
        bLast = b.messages.last.timestamp;
      } catch (_) {
        bLast = b.startedOn ?? 0;
      }
      return bLast.compareTo(aLast);
    });
    return MessagesLoadedState(uid, dialogs);
  }

  @override
  Stream<MessagesState> mapEventToState(MessagesEvent event) async* {
    final MessagesState state = currentState;
    try {
      if (event is MessagesInitEvent) {
        List<Conversation> chats = await _messagesRepository.fetchDialogs(event.userId);
        yield _sortedLoaded(event.userId, chats);
        _allSub = StreamZip(_messagesRepository.getStreams(chats.map((c) => c.id))).listen((data) {
          dispatch(_MessagesSetEvent(event.userId, data));
        }, onDone: () {
          _allSub?.cancel();
          _allSub = null;
        });
      } else if (event is _MessagesSetEvent) {
        yield _sortedLoaded(event.userId, event.dialogs);
      } else if (event is MessagesSendEvent) {
        _messagesRepository.sendMessage(event.chatId, event.userId, event.text);
      } else if (event is MessagesCreateEvent && state is MessagesLoadedState) {
        List<Conversation> chats = state.entries + [event.chat];
        yield _sortedLoaded(event.chat.startedById, chats);
        _allSub?.cancel();
        _allSub = StreamZip(_messagesRepository.getStreams(chats.map((c) => c.id))).listen((data) {
          dispatch(_MessagesSetEvent(event.chat.startedById, data));
        }, onDone: () {
          _allSub?.cancel();
          _allSub = null;
        });
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

  Future<String> createChat(String userId, String opId, Map<String, dynamic> data) async {
    Conversation chat = await _messagesRepository.createDialog(userId, opId, data);
    dispatch(MessagesCreateEvent(chat));
    return chat.id;
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
class MessagesLoadedState extends MessagesState {
  final String uid;
  final List<Conversation> entries;

  MessagesLoadedState(this.uid, this.entries) : super(<dynamic>[uid, ...entries]);

  int get unreadCount => entries.fold(0, (i, c) => c.messages.any((m) => !m.out(uid) && !m.read) ? i + 1 : i);

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
  final String userId;
  final List<Conversation> dialogs;

  _MessagesSetEvent(this.userId, this.dialogs) : super(<dynamic>[userId, ...dialogs]);
}

@immutable
class MessagesSendEvent extends MessagesEvent {
  final String chatId;
  final String userId;
  final String text;

  MessagesSendEvent(this.userId, this.chatId, this.text) : super([userId, chatId, text]);
}

@immutable
class MessagesCreateEvent extends MessagesEvent {
  final Conversation chat;

  MessagesCreateEvent(this.chat) : super([chat]);
}
