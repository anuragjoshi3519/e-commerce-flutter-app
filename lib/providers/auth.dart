import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _authToken;
  String _userId;
  String _expiryIn;
  bool _isAuthenticated = false;

  bool get isAuthenticated {
    return _isAuthenticated;
  }

  String get userId {
    return _userId;
  }

  String get token {
    return _authToken;
  }

  void logout() {
    _authToken = "";
    _userId = "";
    _expiryIn = "";
    _isAuthenticated = false;
    notifyListeners();
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
      print(response['error']['message']);
      throw HTTPException(response['error']['message']);
    } else {
      _authToken = response['idToken'];
      _userId = response['localId'];
      _expiryIn = response['expiresIn'];
      _isAuthenticated = true;
      notifyListeners();
    }
  }
}
