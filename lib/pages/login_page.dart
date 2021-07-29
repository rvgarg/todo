import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo/api/Login_api.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  LoginApi api = LoginApi();
  bool signup = false;
  bool signin = false;
  final _key = GlobalKey<FormState>();
  final _userName = TextEditingController();
  final _password = TextEditingController();
  var _pwd = false;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: ListView(
          children: [
            Form(
              key: _key,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Align(
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.person_outline,
                      size: MediaQuery.of(context).size.width / 4,
                    ),
                  ),
                  if (signin || signup)
                    Container(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _userName,
                            decoration: InputDecoration(
                              labelText: 'Email ID / Phone No.',
                              contentPadding: EdgeInsets.all(10),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email ID / Phone No. is required';
                              }
                            },
                          ),
                          TextFormField(
                            controller: _password,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              contentPadding: EdgeInsets.all(10),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password is required';
                              }
                            },
                            enabled: _pwd,
                          ),
                        ],
                      ),
                    ),
                  if (!signup)
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: OutlinedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.blue),
                            elevation: MaterialStateProperty.all(5)),
                        onPressed: () {
                          if (signin) {
                            if (_pwd) {
                              var email = _userName.text;
                              var password = _password.text;
                              api.loginWithEmail(
                                  email: email,
                                  password: password,
                                  context: context);
                            } else {
                              var mobile = _userName.text;
                              api.login(mobile: mobile, context: context);
                            }
                          } else {
                            setState(() {
                              signin = true;
                              signup = false;
                            });
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(15),
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width,
                          child: Text(
                            'SIGN IN',
                            style: TextStyle(
                                backgroundColor: Colors.blue,
                                color: Colors.white,
                                fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                  if (!signup || signin)
                    Padding(
                      child: Divider(),
                      padding: EdgeInsets.all(10),
                    ),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: OutlinedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.blue),
                          elevation: MaterialStateProperty.all(5)),
                      onPressed: () {
                        if (signup) {
                          var email = _userName.text;
                          var password = _password.text;
                          api.signupWithEmail(
                              email: email,
                              password: password,
                              context: context);
                        } else {
                          setState(() {
                            signup = true;
                            signin = false;
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(15),
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width,
                        child: Text(
                          'SIGN UP',
                          style: TextStyle(
                              backgroundColor: Colors.blue,
                              color: Colors.white,
                              fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                  if (signup)
                    Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(20),
                            child: OutlinedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.blue),
                                  elevation: MaterialStateProperty.all(5)),
                              onPressed: () {
                                api.loginWithGoogle(context: context);
                              },
                              child: Container(
                                padding: EdgeInsets.all(15),
                                alignment: Alignment.center,
                                width: MediaQuery.of(context).size.width,
                                child: Text(
                                  'GOOGLE',
                                  style: TextStyle(
                                      backgroundColor: Colors.blue,
                                      color: Colors.white,
                                      fontSize: 15),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(20),
                            child: OutlinedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.blue),
                                  elevation: MaterialStateProperty.all(5)),
                              onPressed: () {
                                api.loginWithFacebook(context: context);
                              },
                              child: Container(
                                padding: EdgeInsets.all(15),
                                alignment: Alignment.center,
                                width: MediaQuery.of(context).size.width,
                                child: Text(
                                  'FACEBOOK',
                                  style: TextStyle(
                                      backgroundColor: Colors.blue,
                                      color: Colors.white,
                                      fontSize: 15),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                ],
              ),
            ),
          ],
        ),
      );

  @override
  void dispose() {
    _userName.dispose();
    _password.dispose();
    super.dispose();
  }

  void check() {
    if (_userName.text!.contains('@')) {
      _pwd = true;
    } else {
      _pwd = false;
    }
  }

  @override
  void initState() {
    _userName.addListener(check);
    super.initState();
  }
}
