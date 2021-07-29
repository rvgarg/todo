import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginApi {
  late final FirebaseAuth auth;

  LoginApi() {
    auth = FirebaseAuth.instance;
  }

  void loginWithFacebook({required BuildContext context}) async {
    var login = FacebookLogin();
    var result = await login.logInWithReadPermissions(['email']);
    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Logged In!!')));
        Navigator.of(context).pushNamed('/list');
        break;
      case FacebookLoginStatus.cancelledByUser:
        print('Cancelled by User');
        break;
      case FacebookLoginStatus.error:
        print('Error!! Try again');
        break;
    }
  }

  void loginWithGoogle({required BuildContext context}) async {
    final GoogleSignInAccount? googleSignInAccount =
        await GoogleSignIn().signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount!.authentication;
    final credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);
    await auth.signInWithCredential(credential).then((value) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Logged In!!')));
      Navigator.of(context).pushNamed('/list');
    }).catchError((onError) {
      print(onError);
    });
  }

  void signupWithEmail(
      {required String email,
      required String password,
      required BuildContext context}) async {
    try {
      auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Logged In!!')));
        Navigator.of(context).pushNamed('/list');
      }).catchError((onError) {
        print(onError);
      });
    } catch (e) {
      print(e.toString());
    }
  }

  void loginWithEmail(
      {required String email,
      required String password,
      required BuildContext context}) async {
    try {
      auth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((value) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Logged In!!')));
        Navigator.of(context).pushNamed('/list');
      }).catchError((onError) {
        print(onError);
      });
    } catch (e) {
      print(e.toString());
    }
  }

  void login({required String mobile, required BuildContext context}) async {
    try {
      auth.verifyPhoneNumber(
          phoneNumber: mobile,
          timeout: Duration(seconds: 20),
          verificationCompleted: (phoneAuthCredential) async {
            await auth.signInWithCredential(phoneAuthCredential).then((value) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('Logged In!!')));
              Navigator.of(context).pushNamed('/list');
            }).catchError((onError) {
              print(onError);
            });
          },
          verificationFailed: (e) {
            print(e.message);
          },
          codeSent: (verificationId, [resendId]) {
            var _otp = TextEditingController();
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('OTP'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: _otp,
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      var code = _otp.text.trim();
                      var credential = PhoneAuthProvider.credential(
                          verificationId: verificationId, smsCode: code);
                      await auth.signInWithCredential(credential).then((value) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Logged In!!')));
                        Navigator.of(context).pushNamed('/list');
                      }).catchError((onError) {
                        print(onError);
                      });
                      _otp.dispose();
                    },
                    child: Text(
                      "Done",
                      style: TextStyle(
                          color: Colors.blue, backgroundColor: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
          codeAutoRetrievalTimeout: (verificationId) {
            print(verificationId);
          });
    } catch (e) {
      print(e.toString());
    }
  }
}
