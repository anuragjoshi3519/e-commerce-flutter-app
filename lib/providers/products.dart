import 'dart:convert';

import 'package:flutter_config/flutter_config.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';
import './product.dart';

class Products with ChangeNotifier {
  Products(this._authToken, this._userId, this._items);

  final String _authToken;
  final String _userId;
  List<Product> _items = [];

  Product findById(String id) {
    return _items.firstWhere((element) => element.id == id, orElse: () => null);
  }

  Future<void> updateProduct(Product product) async {
    final productIndex =
        _items.indexWhere((element) => element.id == product.id);
    Product oldProduct;
    if (productIndex >= 0) {
      oldProduct = _items[productIndex];
      _items[productIndex] = product;
      notifyListeners();
    }
    final response = await http.patch(
        '${FlutterConfig.get('FIREBASE_REALTIME_DB_URL')}/products/${product.id}.json?auth=$_authToken',
        body: json.encode({
          "title": product.title,
          "price": product.price,
          "description": product.description,
          "imageUrl": product.imageUrl,
        }));
    if (response.statusCode >= 400) {
      _items[productIndex] = oldProduct;
      notifyListeners();
      throw HTTPException("Update Failed!");
    }
    oldProduct = null;
  }

  Future<void> fetchProducts([bool filterProducts = false]) async {
    final String filterQuery =
        filterProducts ? '&orderBy="creatorId"&equalTo="$_userId"' : '';
    try {
      var response = await http.get(
          '${FlutterConfig.get("FIREBASE_REALTIME_DB_URL")}/products.json?auth=$_authToken$filterQuery');
      final loadedProducts = json.decode(response.body) as Map<String, dynamic>;
      response = await http.get(
          "${FlutterConfig.get('FIREBASE_REALTIME_DB_URL')}/userFavourites/$_userId.json?auth=$_authToken");
      final userFavourites = json.decode(response.body) as Map<String, dynamic>;

      final List<Product> prods = [];
      if (loadedProducts != null) {
        loadedProducts.forEach(
          (prodID, prodData) {
            prods.insert(
              0,
              Product(
                  id: prodID,
                  title: prodData['title'],
                  description: prodData['description'],
                  price: prodData['price'] as double,
                  imageUrl: prodData['imageUrl'],
                  // ignore: avoid_bool_literals_in_conditional_expressions
                  isFavorite: userFavourites == null
                      ? false
                      : userFavourites[prodID] ?? false),
            );
          },
        );
      }
      _items = prods;
      notifyListeners();
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      final response = await http.post(
          '${FlutterConfig.get("FIREBASE_REALTIME_DB_URL")}/products.json?auth=$_authToken',
          body: json.encode({
            'title': product.title,
            'price': product.price,
            "description": product.description,
            "imageUrl": product.imageUrl,
            "creatorId": _userId,
          }));
      final id = json.decode(response.body)['name'];
      _items.insert(
          0,
          Product(
            id: id,
            title: product.title,
            price: product.price,
            description: product.description,
            imageUrl: product.imageUrl,
            isFavorite: false,
          ));
      notifyListeners();
    } catch (_) {
      throw HTTPException("Error");
    }
  }

  Future<void> deleteProduct(String id) async {
    final _productIndex = _items.indexWhere((element) => element.id == id);
    var _oldProduct = _items[_productIndex];
    _items.removeAt(_productIndex);
    notifyListeners();
    final response = await http.delete(
        "${FlutterConfig.get('FIREBASE_REALTIME_DB_URL')}/products/$id.json?auth=$_authToken");

    if (response.statusCode >= 400) {
      _items.insert(_productIndex, _oldProduct);
      notifyListeners();
      throw HTTPException("Deletion Failed!");
    }
    _oldProduct = null;
  }

  List<Product> get favoriteItems {
    return _items.where((element) => element.isFavorite).toList();
  }

  List<Product> get items {
    return [..._items];
  }
}
