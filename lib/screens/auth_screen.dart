import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/http_exception.dart';
import '../providers/auth.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    // final transformConfig = Matrix4.rotationZ(-8 * pi / 180);
    // transformConfig.translate(-10.0);
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(0, 90, 90, 1),
                  Color.fromRGBO(10, 10, 10, 1),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                stops: [0, 1],
              ),
            ),
          ),
          Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.only(left: 15.0, top: 5.0),
              transform: Matrix4.rotationZ(60 * pi / 180)
                ..translate(-110.0, -380.0),
              decoration: const BoxDecoration(
                // borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(0, 50, 70, 1),
                    Color.fromRGBO(80, 80, 80, 1),
                  ],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  stops: [0, 1],
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 20,
                    color: Colors.black,
                    offset: Offset(0, 2),
                  )
                ],
              )),
          Container(
            padding: const EdgeInsets.only(top: 20.0, left: 10.0),
            child: Text(
              "Shopp'In\nProxy",
              style: TextStyle(
                color: Colors.white,
                fontSize: deviceSize.height * 0.08,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: deviceSize.height * 0.15),
            alignment: Alignment.center,
            child: const AuthCard(),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({
    Key key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  final Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();

  void showDialogBox(String title, String content) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text(title),
              content: Text(content),
              actions: [
                FlatButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('CLOSE'))
              ],
            ));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_authMode == AuthMode.Login) {
      try {
        await Provider.of<Auth>(context, listen: false).authenticate(
            _authData['email'], _authData['password'], 'signInWithPassword');
      } on HTTPException catch (error) {
        String message = "Something went wrong! Please try again.";
        if (error.toString().contains('EMAIL_NOT_FOUND')) {
          message = "There is no user registered with given email address.";
        } else if (error.toString().contains('INVALID_EMAIL')) {
          message = "There is no user registered with given email address.";
        } else if (error.toString().contains('INVALID_PASSWORD')) {
          message = "You have entered wrong password. Please try again.";
        } else if (error.toString().contains('TOO_MANY_ATTEMPTS_TRY_LATER')) {
          message =
              "Too many failed attempts. Account has been temporarily disabled.";
        }
        showDialogBox('Authentication Failed', message);
      } catch (e) {
        showDialogBox("ERROR", 'Something went wrong! Please try again.');
      }
    } else {
      try {
        await Provider.of<Auth>(context, listen: false)
            .authenticate(_authData['email'], _authData['password'], 'signUp');
      } on HTTPException catch (error) {
        String message = "Something went wrong! Please try again.";
        if (error.toString().contains('EMAIL_EXISTS')) {
          message = "Email ID is already in use.";
        } else if (error.toString().contains('INVALID_EMAIL')) {
          message = "Please enter a valid email address.";
        } else if (error.toString().contains('TOO_MANY_ATTEMPTS_TRY_LATER')) {
          message =
              "Too many failed attempts. Account has been temporily disabled.";
        }
        showDialogBox('Authentication Failed', message);
      } catch (e) {
        showDialogBox("ERROR", 'Something went wrong! Please try again.');
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      margin: EdgeInsets.only(top: deviceSize.height * 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
      elevation: 16.0,
      child: Container(
        alignment: Alignment.center,
        height: _authMode == AuthMode.Signup ? 350 : 290,
        constraints:
            BoxConstraints(minHeight: _authMode == AuthMode.Signup ? 320 : 260),
        width: deviceSize.width * 0.90,
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Email ID'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value.isEmpty || !value.contains('@')) {
                      return 'Invalid email!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['email'] = value;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value.isEmpty || value.length < 5) {
                      return 'Password is too short!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['password'] = value;
                  },
                ),
                if (_authMode == AuthMode.Signup)
                  TextFormField(
                    enabled: _authMode == AuthMode.Signup,
                    decoration:
                        const InputDecoration(labelText: 'Confirm Password'),
                    obscureText: true,
                    validator: _authMode == AuthMode.Signup
                        ? (value) {
                            if (value != _passwordController.text) {
                              return 'Passwords do not match!';
                            }
                            return null;
                          }
                        : null,
                  ),
                const SizedBox(
                  height: 20,
                ),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  RaisedButton(
                    child: Text(
                      _authMode == AuthMode.Login ? 'LOG IN' : 'SIGN UP',
                      style: const TextStyle(fontFamily: "Lato", fontSize: 18),
                    ),
                    onPressed: _submit,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30.0, vertical: 8.0),
                    color: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).primaryTextTheme.button.color,
                  ),
                FlatButton(
                  child: Text(
                      _authMode == AuthMode.Login ? 'SIGN UP' : 'LOG IN',
                      style: const TextStyle(
                          fontFamily: "Lato",
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                  onPressed: _switchAuthMode,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
