import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _authToken;
  String _userId;
  DateTime _expiryIn;
  String _email;
  Timer _authTimer;

  bool get isAuthenticated {
    if (_expiryIn != null &&
        _expiryIn.isAfter(DateTime.now()) &&
        _authToken != null) {
      return true;
    }
    return false;
  }

  String get userId {
    return _userId;
  }

  String get token {
    return _authToken;
  }

  String get email {
    return _email;
  }

  Future<void> logout() async {
    _authToken = null;
    _userId = null;
    _expiryIn = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final int logoutAfter = _expiryIn.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: logoutAfter), logout);
  }

  Future<bool> tryLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final userData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    final expiryIn = DateTime.parse(userData['expiryIn']);
    if (expiryIn.isBefore(DateTime.now())) {
      return false;
    }
    _authToken = userData['authToken'];
    _userId = userData['userId'];
    _expiryIn = expiryIn;
    _email = userData['email'];
    return true;
  }

  Future<void> authenticate(
      String email, String password, String action) async {
    dynamic response;
    try {
      response = await http.post(
          'https://identitytoolkit.googleapis.com/v1/accounts:$action?key=${FlutterConfig.get('API_KEY')}',
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true
          }));
    } catch (err) {
      rethrow;
    }
    response = json.decode(response.body);
    if (response['error'] != null) {
      // print(response['error']['message']);
      throw HTTPException(response['error']['message']);
    } else {
      _authToken = response['idToken'];
      _userId = response['localId'];
      _expiryIn = DateTime.now()
          .add(Duration(seconds: int.parse(response['expiresIn'])));
      _email = response['email'];
      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'authToken': _authToken,
        'userId': _userId,
        'expiryIn': _expiryIn.toIso8601String(),
        'email': _email
      });
      prefs.setString('userData', userData);
    }
  }
}
