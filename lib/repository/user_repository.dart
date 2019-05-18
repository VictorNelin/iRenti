import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

export 'package:firebase_auth/firebase_auth.dart' show FirebaseUser;
export 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

const _kEmptyData = [null, null, null, null, null, null, null];

class UserRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  Completer _registrar;

  UserRepository({FirebaseAuth firebaseAuth, GoogleSignIn googleSignIn})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  Future<void> signInWithCredentials(String email, String password) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<String> signUp({String phone}) async {
    Completer<String> _vId = Completer<String>();
    _registrar = Completer();
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: const Duration(milliseconds: 0),
      verificationCompleted: (cred) async {
        await _firebaseAuth.signInWithCredential(cred);
        _registrar?.complete();
        _registrar = null;
      },
      verificationFailed: (error) {
        print(error.message);
        _vId.completeError(error);
      },
      codeSent: (vId, [forceResend]) {
        _vId.complete(vId);
      },
      codeAutoRetrievalTimeout: (vId) {
        _vId.complete(vId);
      },
    );
    return _vId.future;
  }

  Future<void> verify({String vId, String code}) async {
    AuthCredential cred = PhoneAuthProvider.getCredential(
      verificationId: vId,
      smsCode: code,
    );
    await _firebaseAuth.signInWithCredential(cred);
    Future reg = _registrar?.future ?? Future.delayed(const Duration(milliseconds: 300));
    _registrar?.complete();
    _registrar = null;
    return reg;
  }

  Future<void> setData({String name, String email, String password}) async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    await user.updateEmail(email);
    await user.updatePassword(password);
    await user.updateProfile(UserUpdateInfo()..displayName = name);
  }

  Future get verifyState => _registrar?.future;

  Future<void> signOut() async {
    return Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  Future<bool> isSignedIn() async {
    final currentUser = await _firebaseAuth.currentUser();
    return currentUser != null;
  }

  Future<FirebaseUser> getUser() async {
    return await _firebaseAuth.currentUser();
  }

  Future<List<dynamic>> getProfileData() async {
    if (!(await isSignedIn())) return _kEmptyData;
    String uid = (await getUser()).uid;
    final doc = await Firestore.instance.collection('users').document(uid).get();
    return doc.data == null ? _kEmptyData : (doc.data['profile']?.map((v) => v is Timestamp ? v.toDate() : v)?.toList(growable: false) ?? _kEmptyData);
  }

  Future<void> updateProfileData(List<dynamic> data) async {
    if (!(await isSignedIn())) return;
    assert(data.length == 7);
    String uid = (await getUser()).uid;
    await Firestore.instance.collection('users').document(uid).setData(
      {'profile': data.map((v) => v is DateTime ? Timestamp.fromDate(v) : v).toList(growable: false)},
      merge: true,
    );
  }

  Future<void> uploadAvatar() async {
    if (!(await isSignedIn())) return;
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      String uid = (await getUser()).uid;
      var snap = await FirebaseStorage.instance.ref()
          .child('users/$uid/ava.${image.path.split('.').last}')
          .putFile(image)
          .onComplete;
      await (await getUser()).updateProfile(UserUpdateInfo()..photoUrl = await snap.ref.getDownloadURL());
    }
  }
}