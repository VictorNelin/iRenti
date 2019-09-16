import 'package:meta/meta.dart';
import 'package:irenti/model/catalog.dart';
import 'package:irenti/model/user.dart';

@immutable
class Conversation {
  final String id;
  final List<String> userIds;
  final List<UserData> users;
  final String startedById;
  final int startedOn;
  final int lastReadTime;
  final List<CatalogEntry> data;
  final List<Message> messages;

  const Conversation({
    this.id,
    this.userIds,
    this.users,
    this.startedById,
    this.startedOn,
    this.lastReadTime,
    this.data,
    this.messages = const [],
  });

  factory Conversation.fromMap(String id, Map<String, dynamic> src) {
    return Conversation(
      id: id,
      userIds: List.from(src['userIds']),
      startedById: src['startedById'],
      startedOn: src['startedOn'],
      lastReadTime: src['lastReadTime'],
      data: List.from(src['data'].map((l) => CatalogEntry.fromMap(null, Map.from(l)))),
      messages: List.from(src['messages'].map((l) => Message.fromMap(Map.from(l)))),
    );
  }

  Conversation copyWith({
    String id,
    List<String> userIds,
    List<UserData> users,
    String startedById,
    int startedOn,
    int lastReadTime,
    List<CatalogEntry> data,
    List<Message> messages,
  }) => Conversation(
    id: id ?? this.id,
    userIds: userIds ?? this.userIds,
    users: users ?? this.users,
    startedById: startedById ?? this.startedById,
    startedOn: startedOn ?? this.startedOn,
    lastReadTime: lastReadTime ?? this.lastReadTime,
    data: data ?? this.data,
    messages : messages  ?? this.messages,
  );

  UserData get startedBy => users == null ? null : users.firstWhere((d) => d.id == startedById, orElse: () => null);

  UserData op(String userId) => users.firstWhere((u) => u.id != userId);
}

@immutable
class Message {
  final String fromId;
  final String chatId;
  final int timestamp;
  final String text;
  final int data;
  final String imageUrl;
  final UserData from;

  const Message({
    @required this.fromId,
    @required this.chatId,
    @required this.timestamp,
    this.text,
    this.data,
    this.imageUrl,
    this.from,
  });

  factory Message.fromMap(Map<String, dynamic> src) {
    return Message(
      fromId: src['fromId'],
      chatId: src['chatId'],
      timestamp: src['timestamp'],
      text: src['text'],
      data: src['data'],
      imageUrl: src['imageUrl'],
    );
  }

  Map<String, dynamic> toJSON() => {
    'fromId': fromId,
    'chatId': chatId,
    'timestamp': timestamp,
    'text': text,
    'data': data,
    'imageUrl': imageUrl,
  };

  Message copyWith({
    String fromId,
    String chatId,
    int timestamp,
    String text,
    int data,
    String imageUrl,
    UserData from,
  }) => Message(
    fromId: fromId ?? this.fromId,
    chatId: chatId ?? this.chatId,
    timestamp: timestamp ?? this.timestamp,
    text: text ?? this.text,
    data: data ?? this.data,
    imageUrl: imageUrl ?? this.imageUrl,
    from: from ?? this.from,
  );

  bool out(String selfId) => fromId == selfId;
}
