import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

export 'package:firebase_auth/firebase_auth.dart' show FirebaseUser;

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
      timeout: const Duration(seconds: 5),
      verificationCompleted: (cred) async {
        print(cred);
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
      codeAutoRetrievalTimeout: (vId) {},
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
}