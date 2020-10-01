import 'dart:convert';

import 'package:flutter_config/flutter_config.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';
import './product.dart';

class Products with ChangeNotifier {
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
        '${FlutterConfig.get('FIREBASE_REALTIME_DB_URL')}/products/${product.id}.json',
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

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(
          '${FlutterConfig.get("FIREBASE_REALTIME_DB_URL")}/products.json');
      final loadedProducts = json.decode(response.body) as Map<String, dynamic>;
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
                  price: prodData['price'],
                  imageUrl: prodData['imageUrl'],
                  isFavorite: prodData['isFavorite']),
            );
          },
        );
      }
      _items = prods;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      final response = await http.post(
          '${FlutterConfig.get("FIREBASE_REALTIME_DB_URL")}/products.json',
          body: json.encode({
            'title': product.title,
            'price': product.price,
            "description": product.description,
            "imageUrl": product.imageUrl,
            "isFavorite": product.isFavorite
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
            isFavorite: product.isFavorite,
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
        "${FlutterConfig.get('FIREBASE_REALTIME_DB_URL')}/products/$id.json");

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
