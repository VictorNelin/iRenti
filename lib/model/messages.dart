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

  const Conversation({this.id, this.userIds, this.startedById, this.startedOn, this.lastReadTime, this.data, this.messages = const [], this.users});

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

  UserData get startedBy => users == null ? null : users.firstWhere((d) => d.id == startedById, orElse: () => null);

  UserData op(String userId) => users.firstWhere((u) => u.id != userId);
}

@immutable
class Message {
  final String fromId;
  final UserData from;
  final String chatId;
  final String text;
  final int data;
  final int timestamp;

  const Message({
    @required this.fromId,
    @required this.chatId,
    @required this.timestamp,
    this.text,
    this.data,
    this.from,
  });

  factory Message.fromMap(Map<String, dynamic> src) {
    return Message(
      fromId: src['fromId'],
      chatId: src['chatId'],
      timestamp: src['timestamp'],
      text: src['text'],
      data: src['data'],
    );
  }

  Map<String, dynamic> toJSON() => {
    'fromId': fromId,
    'chatId': chatId,
    'timestamp': timestamp,
    'text': text,
    'data': data,
  };

  bool out(String selfId) => fromId == selfId;
}
