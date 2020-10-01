import 'dart:convert';

import 'package:flutter_config/flutter_config.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';
import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
    // Product(
    //   id: 'p5',
    //   title: 'Oneplus Nord',
    //   description: 'Live with style. Flagship model by Oneplus.',
    //   price: 169.99,
    //   imageUrl:
    //       'https://images.anandtech.com/doci/15922/1-m00-15-d2-rb8lb18cw9kapfouaawjvqw4rbo469_840_840_678x452.png',
    // ),
    // Product(
    //   id: 'p6',
    //   title: 'TP-Link Router',
    //   description: 'Connect with the world in no time.',
    //   price: 89.99,
    //   imageUrl:
    //       'https://assets.croma.com/medias/sys_master/images/images/hf4/h3a/8873587900446/208732_pjpeg.jpg',
    // ),
    // Product(
    //   id: 'p7',
    //   title: 'Machine Learning Yearning',
    //   description: 'Machine learning guide by Andrew Ng.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://i.gr-assets.com/images/S/compressed.photo.goodreads.com/books/1480798569l/30741739._SX318_.jpg',
    // ),
    // Product(
    //   id: 'p8',
    //   title: 'Bose Headphone',
    //   description: 'Listen to music like a boss.',
    //   price: 249.99,
    //   imageUrl: 'https://endorsedbox.com/wp-content/uploads/2019/11/HLPE2.jpg',
    // ),
    // Product(
    //   id: 'p9',
    //   title: 'Philips Trimmer',
    //   description: 'Give youself a new funky style everyday.',
    //   price: 55.99,
    //   imageUrl:
    //       'https://images.philips.com/is/image/PhilipsConsumer/QT4005_15-A2P-global-001?\$jpglarge\$&wid=1250',
    // ),
    // Product(
    //   id: 'p10',
    //   title: 'HP Pavilion 14',
    //   description: 'The beast. Enjoy working smart with brand new Pavilion 14.',
    //   price: 589.99,
    //   imageUrl: 'https://uniquec.com/wp-content/uploads/CE2065TX-400x400.png',
    // ),
    // Product(
    //   id: 'p11',
    //   title: 'Alarm Clock',
    //   description: "Wake up, Wake up, Wake up. Can't? Buy this clock & see",
    //   price: 49.99,
    //   imageUrl:
    //       'https://images-na.ssl-images-amazon.com/images/I/61hLFWn3rZL._AC_SX522_.jpg',
    // ),
    // Product(
    //   id: 'p12',
    //   title: 'LG TV',
    //   description: 'Get entertained with new LG Smart TV.',
    //   price: 199.99,
    //   imageUrl:
    //       'https://www.lg.com/cac_en/images/tvs/MD06187896/gallery/D1.jpg',
    // ),
  ];

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
          '${FlutterConfig.get('FIREBASE_REALTIME_DB_URL')}/products.json');
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
          '${FlutterConfig.get('FIREBASE_REALTIME_DB_URL')}/products.json',
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
