import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _authToken;
  String _userId;
  DateTime _expiryIn;

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

  void logout() {
    _authToken = null;
    _userId = null;
    _expiryIn = null;
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
      // print(response['error']['message']);
      throw HTTPException(response['error']['message']);
    } else {
      _authToken = response['idToken'];
      _userId = response['localId'];
      _expiryIn = DateTime.now()
          .add(Duration(seconds: int.parse(response['expiresIn'])));
      notifyListeners();
    }
  }
}
