import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:irenti/model/messages.dart';
import 'package:irenti/model/user.dart';

export 'package:irenti/model/messages.dart';
export 'package:irenti/model/user.dart';

class MessagesRepository {
  final Firestore _firestore;

  MessagesRepository({Firestore firestore})
      : _firestore = firestore ?? Firestore.instance;

  Future<List<Conversation>> fetchDialogs(String userId) async {
    QuerySnapshot q = await _firestore.collection('chats').getDocuments();
    List<Conversation> entries = [
      for (DocumentSnapshot doc in q.documents)
        Conversation.fromMap(doc.reference.path.split('/').last, doc.data),
    ];
    return await Future.wait(entries
        .where((c) => c.userIds.contains(userId))
        .map((entry) => _loadedConversation(entry, _firestore)));
  }

  Map<String, Stream<Conversation>> getStreams(Iterable<String> dialogIds) {
    Map<String, Stream<Conversation>> streams = Map();
    for (String s in dialogIds) {
      streams[s] = (_firestore.collection('chats').document(s).snapshots().transform(
        StreamTransformer.fromHandlers(
          handleData: (DocumentSnapshot doc, sink) async {
            sink.add(await _loadedConversation(
              Conversation.fromMap(doc.reference.path.split('/').last, doc.data),
              _firestore,
            ));
          },
          handleDone: (sink) => sink.close(),
        ),
      ));
    }
    return streams;
  }

  Future<void> sendMessage(String dialogId, String userId, String text) async {
    DocumentReference doc = _firestore.collection('chats').document(dialogId);
    Message newMsg = Message(
      fromId: userId,
      chatId: dialogId,
      text: text,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    Map<String, dynamic> data = (await doc.get()).data;
    data['messages'] = List.from(data['messages'] + [newMsg.toJSON()]);
    await doc.setData(data, merge: true);
  }

  Future<Conversation> _loadedConversation(Conversation on, Firestore firestore) async {
    List<DocumentSnapshot> snaps = await Future.wait(on.userIds.map((ref) => firestore.collection('users').document(ref).get()));
    List<UserData> users = [
      for (DocumentSnapshot doc in snaps)
        UserData(
          id: doc.reference.path.split('/').last,
          displayName: doc.data['display_name'],
          photoUrl: doc.data['ava_url'],
          data: doc.data['profile'].map((v) => v is Timestamp ? v.toDate() : v).toList(growable: false),
        ),
    ];
    return Conversation(
      id: on.id,
      userIds: on.userIds,
      users: users,
      startedById: on.startedById,
      data: on.data,
      messages: on.messages.map((m) => Message(
        fromId: m.fromId,
        chatId: m.chatId,
        text: m.text,
        timestamp: m.timestamp,
        from: m.from ?? users.singleWhere((u) => u.id == m.fromId, orElse: () => null),
        read: m.read,
      )).toList(growable: false),
    );
  }
}
