import 'package:flutter/foundation.dart';

class CartItem {
  CartItem({
    @required this.id,
    @required this.title,
    @required this.price,
    this.quantity = 1,
  });
  String id;
  String title;
  double price;
  int quantity;


  double get totalPrice{
    return price*quantity;
  }
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _cartItems = {};

  Map<String, CartItem> get cartItems {
    return {..._cartItems};
  }

  int get length {
    return _cartItems.length;
  }

  int get totalItems {
    var total = 0;
    _cartItems.forEach((key, value) {
      total += value.quantity;
    });
    return total;
  }

  double get totalAmount {
    var total = 0.0;
    _cartItems.forEach((key, value) {
      total += value.totalPrice;
    });
    return total;
  }

  void addToCart(String id, String title, double price) {
    if (_cartItems.containsKey(id)) {
      _cartItems[id].quantity += 1;
    } else {
      _cartItems.putIfAbsent(
          id,
          () => CartItem(
              id: id, title: title, price: price));
    }
    notifyListeners();
  }

  void removeItem(String id){
    if(!_cartItems.containsKey(id)){
      return;
    }else{
      if(_cartItems[id].quantity==1){
        removeFromCart(id);
      }else{
        _cartItems[id].quantity-=1;
      }
    }
  }

  void removeFromCart(String id) {
    _cartItems.removeWhere((key, value) => key == id);
    notifyListeners();
  }

  void clearCart(){
    _cartItems={};
    notifyListeners();
  }
}
