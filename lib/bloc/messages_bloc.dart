import 'dart:async';

//import 'package:async/async.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:irenti/model/messages.dart';
import 'package:irenti/model/user.dart';
import 'package:irenti/repository/messages_repository.dart';

export 'package:irenti/repository/messages_repository.dart' show UploadedImage;

class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  final MessagesRepository _messagesRepository;
  final Map<String, UserData> _userCache = Map();
  StreamSubscription _allSub;

  MessagesBloc({@required MessagesRepository messagesRepository})
      : assert(messagesRepository != null),
        _messagesRepository = messagesRepository;

  @override
  MessagesState get initialState => EmptyState();

  Future<MessagesLoadedState> _sortedLoaded(String uid, List<Conversation> dialogs) async {
    for (var c in dialogs) {
      for (String id in c.userIds)
        _userCache[id] ??= await _messagesRepository.getUserById(id);
    }
    dialogs = List.of(dialogs.map((on) => on.copyWith(
      users: on.users ?? [
        for (String id in on.userIds)
          _userCache[id],
      ],
      messages: on.messages.map((m) => m.copyWith(
        from: m.from ?? _userCache[m.fromId],
      )).toList(growable: false),
    )));
    dialogs.sort((a, b) {
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
    //final MessagesState state = currentState;
    try {
      if (event is MessagesInitEvent) {
        List<Conversation> chats = await _messagesRepository.fetchDialogs(event.userId);
        for (var chat in chats) {
          for (var user in chat.users) {
            _userCache[user.id] = user;
          }
        }
        yield await _sortedLoaded(event.userId, chats);
        _allSub = _messagesRepository.getStreams(event.userId).listen((data) {
          add(_MessagesSetEvent(event.userId, data));
        }, onDone: () {
          _allSub?.cancel();
          _allSub = null;
        });
      } else if (event is _MessagesSetEvent) {
        yield await _sortedLoaded(event.userId, event.dialogs);
      } else if (event is MessagesSendEvent) {
        _messagesRepository.sendMessage(event.chatId, event.userId, text: event.text, imageUrl: event.imageUrl);
      } else if (event is MessagesSendContactEvent) {
        _messagesRepository.sendContact(event.chatId, event.userId, event.phone);
      } else if (event is MessagesReadEvent) {
        _messagesRepository.readChat(event.chatId);
      }
    } on Error catch (e) {
      print(e);
      print(e.stackTrace);
      yield ErrorState(e);
    }
  }

  @override
  Future<void> close() async {
    _allSub?.cancel();
    await super.close();
  }

  Future<String> createChat(String userId, String opId, Map<String, dynamic> data) {
    return _messagesRepository.createDialog(userId, opId, data);
  }

  Future<UploadedImage> uploadImage(String dialogId, bool useCamera) {
    return _messagesRepository.uploadImage(dialogId, useCamera);
  }
}

@immutable
class MessagesState extends Equatable {
  final List<Object> props;

  MessagesState([List props]) : props = props ?? [];
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

  int get unreadCount => entries.fold(0, (i, c) => !c.messages.last.out(uid) && c.messages.last.timestamp > c.lastReadTime ? i + 1 : i);

  @override
  String toString() => 'LoadedState { entries: $entries }';

  @override
  int get hashCode => entries?.hashCode ?? 0;

  @override
  bool operator ==(Object other) => false;
}

@immutable
class MessagesEvent extends Equatable {
  final List<Object> props;

  MessagesEvent([List props]) : props = props ?? [];
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
  final String imageUrl;

  MessagesSendEvent(this.userId, this.chatId, {this.text, this.imageUrl}) : super([userId, chatId, text, imageUrl]);
}

@immutable
class MessagesSendContactEvent extends MessagesEvent {
  final String chatId;
  final String userId;
  final String phone;

  MessagesSendContactEvent(this.userId, this.chatId, this.phone) : super([userId, chatId, phone]);
}

@immutable
class MessagesCreateEvent extends MessagesEvent {
  final Conversation chat;

  MessagesCreateEvent(this.chat) : super([chat]);
}

@immutable
class MessagesReadEvent extends MessagesEvent {
  final String chatId;

  MessagesReadEvent(this.chatId) : super([chatId]);
}
