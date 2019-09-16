import 'dart:async';
import 'dart:io' show File;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:irenti/model/messages.dart';
import 'package:irenti/model/user.dart';

export 'package:irenti/model/messages.dart';
export 'package:irenti/model/user.dart';

class MessagesRepository {
  final Firestore _firestore;
  final FirebaseStorage _storage;

  MessagesRepository({
    Firestore firestore,
    FirebaseStorage storage,
  }) :  _firestore = firestore ?? Firestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  Future<List<Conversation>> fetchDialogs(String userId) async {
    QuerySnapshot q = await _firestore.collection('chats').where('userIds', arrayContains: userId).getDocuments();
    List<Conversation> entries = [
      for (DocumentSnapshot doc in q.documents)
        Conversation.fromMap(doc.reference.path.split('/').last, doc.data),
    ];
    return await Future.wait(entries.map((entry) => _loadedConversation(entry, _firestore)));
  }

  Stream<List<Conversation>> getStreams(String userId) {
    return _firestore.collection('chats').where('userIds', arrayContains: userId).snapshots().transform(
      StreamTransformer.fromHandlers(
        handleData: (QuerySnapshot q, sink) async {
          sink.add(q.documents.map((doc) {
            return Conversation.fromMap(doc.reference.path.split('/').last, doc.data);
          }).toList(growable: false));
        },
        handleDone: (sink) => sink.close(),
      ),
    );
  }

  Future<void> sendMessage(String dialogId, String userId, {String text, String imageUrl}) async {
    DocumentReference doc = _firestore.collection('chats').document(dialogId);
    Message newMsg = Message(
      fromId: userId,
      chatId: dialogId,
      text: text,
      imageUrl: imageUrl,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    Map<String, dynamic> data = (await doc.get()).data;
    data['messages'] = List.from(data['messages'] + [newMsg.toJSON()]);
    await doc.setData(data, merge: true);
  }

  Future<void> sendContact(String dialogId, String userId, String phone) async {
    DocumentReference doc = _firestore.collection('chats').document(dialogId);
    Message newMsg = Message(
      fromId: userId,
      chatId: dialogId,
      phone: phone,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    Map<String, dynamic> data = (await doc.get()).data;
    data['messages'] = List.from(data['messages'] + [newMsg.toJSON()]);
    await doc.setData(data, merge: true);
  }

  Future<UploadedImage> uploadImage(String dialogId, bool useCamera) async {
    File image = await ImagePicker.pickImage(source: useCamera ? ImageSource.camera : ImageSource.gallery);
    if (image != null) {
      var snap = await _storage.ref()
          .child('chats/$dialogId/${DateTime.now().millisecondsSinceEpoch}.${image.path.split('.').last}')
          .putFile(image)
          .onComplete;
      return UploadedImage._(await snap.ref.getDownloadURL(), () => snap.ref.delete());
    }
    return null;
  }

  Future<void> readChat(String dialogId) async {
    DocumentReference doc = _firestore.collection('chats').document(dialogId);
    await doc.setData({'lastReadTime': DateTime.now().millisecondsSinceEpoch}, merge: true);
  }

  Future<String> createDialog(String userId, String opId, Map<String, dynamic> data) async {
    var existing = await _firestore.collection('chats')
        //.where('startedById', isEqualTo: userId)
        .where('userIds', arrayContains: userId)
        .getDocuments();
    if (existing.documents.isNotEmpty) {
      for (var doc in existing.documents) {
        List<String> ids = List.from(doc.data['userIds']);
        if (ids.contains(opId)) {
          Map<String, dynamic> oldData = Map.of(doc.data);
          List entries = List.from(oldData['data']);
          if (entries.any((e) => e['id'] == data['id'])) throw StateError(doc.documentID);
          int l = entries.length;
          entries.add(data);
          oldData['data'] = entries;
          entries = List.from(oldData['messages']);
          entries.add(Message(
            fromId: userId,
            chatId: doc.documentID,
            data: l,
            timestamp: DateTime.now().millisecondsSinceEpoch,
          ).toJSON());
          oldData['messages'] = entries;
          await doc.reference.setData(oldData);
          throw StateError(doc.documentID);
        }
      }
      // shouldn't get here
      return null;
    }
    DocumentReference ref = _firestore.collection('chats').document();
    Map<String, dynamic> d = {
      'userIds': [userId, opId],
      'startedById': userId,
      'startedOn': DateTime.now().millisecondsSinceEpoch,
      'lastReadTime': DateTime.now().millisecondsSinceEpoch,
      'data': [data],
      'messages': <Map<String, dynamic>>[Message(
        fromId: userId,
        chatId: ref.documentID,
        data: 0,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ).toJSON()],
    };
    await ref.setData(d);
    return ref.documentID;
  }

  Future<UserData> getUserById(String userId) async {
    final doc = await _firestore.collection('users').document(userId).get();
    return UserData.fromMap(doc.documentID, doc.data);
  }

  Future<Conversation> _loadedConversation(Conversation on, Firestore firestore) async {
    List<DocumentSnapshot> snaps = await Future.wait(on.userIds.map((ref) => firestore.collection('users').document(ref).get()));
    List<UserData> users = [
      for (DocumentSnapshot doc in snaps)
        UserData(
          id: doc.reference.path.split('/').last,
          displayName: doc.data['display_name'],
          photoUrl: doc.data['ava_url'],
          data: doc.data['profile']?.map((v) => v is Timestamp ? v.toDate() : v)?.toList(growable: false),
        ),
    ];
    return on.copyWith(
      users: users,
      messages: on.messages.map((m) => m.copyWith(
        from: m.from ?? users.singleWhere((u) => u.id == m.fromId, orElse: () => null),
      )).toList(growable: false),
    );
  }
}

class UploadedImage {
  final String url;
  final void Function() delete;

  const UploadedImage._(this.url, this.delete);

  static const empty = UploadedImage._(null, null);
}
