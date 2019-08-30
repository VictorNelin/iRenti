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
  final Firestore _firestore;
  final FirebaseStorage _storage;
  Completer _registrar;

  UserRepository({FirebaseAuth firebaseAuth, GoogleSignIn googleSignIn, Firestore firestore, FirebaseStorage storage})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _firestore = firestore ?? Firestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  Future signInWithCredentials(String email, String password) {
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

  Future verify({String vId, String code}) async {
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

  Future setData({String name, String email, String password}) async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    await user.updateEmail(email);
    await user.updatePassword(password);
    await user.updateProfile(UserUpdateInfo()..displayName = name);
    await _firestore.collection('users').document(user.uid).setData(
      {'display_name': name, 'fave': <int>[],},
      merge: true,
    );
  }

  Future get verifyState => _registrar?.future;

  Future signOut() async {
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
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user;
  }

  Future<List<dynamic>> getProfileData() async {
    if (!(await isSignedIn())) return _kEmptyData;
    String uid = (await getUser()).uid;
    final doc = await _firestore.collection('users').document(uid).get();
    return doc.data == null ? _kEmptyData : (doc.data['profile']?.map((v) => v is Timestamp ? v.toDate() : v)?.toList(growable: false) ?? _kEmptyData);
  }

  Future updateProfileData(List<dynamic> data) async {
    if (!(await isSignedIn())) return;
    assert(data.length == 7);
    String uid = (await getUser()).uid;
    await _firestore.collection('users').document(uid).setData(
      {'profile': data.map((v) => v is DateTime ? Timestamp.fromDate(v) : v).toList(growable: false)},
      merge: true,
    );
  }

  Future uploadAvatar(bool useCamera) async {
    if (!(await isSignedIn())) return;
    File image = await ImagePicker.pickImage(source: useCamera ? ImageSource.camera : ImageSource.gallery);
    if (image != null) {
      FirebaseUser user = await getUser();
      var snap = await _storage.ref()
          .child('users/${user.uid}/ava.${image.path.split('.').last}')
          .putFile(image)
          .onComplete;
      String url = await snap.ref.getDownloadURL();
      await user.updateProfile(UserUpdateInfo()..photoUrl = url);
      await _firestore.collection('users').document(user.uid).setData(
        {'ava_url': url},
        merge: true,
      );
    }
  }

  Future<List<String>> getFaves() async {
    if (!(await isSignedIn())) return _kEmptyData;
    String uid = (await getUser()).uid;
    final doc = await _firestore.collection('users').document(uid).get();
    return doc.data == null ? const <String>[] : (doc.data['fave'] == null ? const <String>[] : List.castFrom(doc.data['fave']));
  }

  Future<List<String>> toggleFave(List<String> prevFave, String id) async {
    if (!(await isSignedIn())) return null;
    List<String> faveIds = List.of(prevFave);
    if (faveIds.contains(id)) {
      faveIds.remove(id);
    } else {
      faveIds.add(id);
    }
    String uid = (await getUser()).uid;
    await _firestore.collection('users').document(uid).setData({'fave': faveIds}, merge: true);
    return faveIds;
  }

  Future<FirebaseUser> updateName(String name) async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    await user.updateProfile(UserUpdateInfo()..displayName = name);
    await user.reload();
    await _firestore.collection('users').document(user.uid).setData(
      {'display_name': name},
      merge: true,
    );
    return user;
  }

  Future<FirebaseUser> updatePhone({Stream<String> data}) async {
    String _vId;
    Completer<FirebaseUser> _user = Completer<FirebaseUser>();
    int i = 0;
    StreamSubscription dataSub;
    dataSub = data.listen((s) {
      if (i == 0) {
        ++i;
        _firebaseAuth.verifyPhoneNumber(
          phoneNumber: s,
          timeout: const Duration(milliseconds: 0),
          verificationCompleted: (cred) async {
            (await _firebaseAuth.currentUser()).updatePhoneNumberCredential(cred).then((_) {
              _user.complete(_firebaseAuth.currentUser());
              dataSub.cancel();
            });
          },
          verificationFailed: (error) {
            print(error.message);
            _user.completeError(error);
          },
          codeSent: (vId, [forceResend]) {
            _vId = vId;
          },
          codeAutoRetrievalTimeout: (vId) {
            _vId = vId;
          },
        );
      } else if (i == 1) {
        AuthCredential cred = PhoneAuthProvider.getCredential(
          verificationId: _vId,
          smsCode: s,
        );
        _firebaseAuth.currentUser().then((u) {
          u.updatePhoneNumberCredential(cred).then((_) {
            _user.complete(_firebaseAuth.currentUser());
            dataSub.cancel();
          });
        });
      }
    });
    return _user.future;
  }
}