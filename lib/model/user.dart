import 'package:meta/meta.dart';

@immutable
class UserData {
  final String id;
  final String displayName;
  final String photoUrl;
  final List data;

  const UserData({
    this.id,
    this.displayName,
    this.photoUrl,
    this.data,
  });

  //compatibility with Firebase Auth
  String get email => null;

  factory UserData.fromMap(String id, Map<String, dynamic> src) {
    return UserData(id: id, displayName: src['display_name'], photoUrl: src['ava_url'], data: src['profile']);
  }
}