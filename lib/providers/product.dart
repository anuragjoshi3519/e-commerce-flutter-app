import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';

class Product with ChangeNotifier{
  Product(
      {@required this.id,
      @required this.title,
      @required this.description,
      @required this.price,
      @required this.imageUrl,
      this.isFavorite=false});
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Future<void> toggleFavorite() async{
    isFavorite = !isFavorite;
    notifyListeners();
    final response = await http.patch("${FlutterConfig.get('FIREBASE_REALTIME_DB_URL')}/products/$id.json",
          body: json.encode({
            "isFavorite":isFavorite,
    }));

    if(response.statusCode>=400){
      isFavorite = !isFavorite;
      notifyListeners();
      throw HTTPException("Update failed. Something went wrong!");
    }
  }
}
