import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';
import '../providers/cart.dart';

class OrderItem {
  OrderItem({
    @required this.id,
    @required this.items,
    @required this.dateTime,
  });
  final String id;
  final List<CartItem> items;
  final DateTime dateTime;

  double get totalAmount {
    var total = 0.0;
    // ignore: avoid_function_literals_in_foreach_calls
    items.forEach((element) {
      total += element.totalPrice;
    });
    return total;
  }
}

class Order with ChangeNotifier {

  Order(this._authToken,this._orderItems);

  final String _authToken;
  List<OrderItem> _orderItems = [];

  List<OrderItem> get orderItems {
    return [..._orderItems];
  }

  Future<void> fetchOrders() async {
    try {
      final response =
          await http.get('${FlutterConfig.get('FIREBASE_REALTIME_DB_URL')}/orders.json?auth=$_authToken');
      final _loadedOrders = json.decode(response.body) as Map<String, dynamic>;
      final List<OrderItem> _orders = [];
      if (_loadedOrders != null) {
        _loadedOrders.forEach(
          (orderID, orderData) {
            _orders.insert(
                0,
                OrderItem(
                  id: orderID,
                  items: (orderData['items'] as List<Object>).map(
                    (e) {
                      final ord = json.decode(e);
                      return CartItem(
                        id: ord['id'],
                        title: ord['title'],
                        price: ord['price'],
                        quantity: ord['quantity'],
                      );
                    },
                  ).toList(),
                  dateTime: DateTime.parse(orderData['datetime']),
                ));
          },
        );
      }
      _orderItems = _orders;
      notifyListeners();
    } catch (_) {
      throw HTTPException("Error");
    }
  }

  Future<void> addOrder(List<CartItem> cartItems) async {
    try {
      final response =
          await http.post('${FlutterConfig.get('FIREBASE_REALTIME_DB_URL')}/orders.json?auth=$_authToken',
              body: json.encode({
                'items': cartItems
                    .map(
                      (e) => json.encode({
                        'id': e.id,
                        'title': e.title,
                        'price': e.price,
                        'quantity': e.quantity,
                      }),
                    )
                    .toList(),
                'datetime': DateTime.now().toIso8601String(),
              }));
      _orderItems.insert(
          0,
          OrderItem(
            id: json.decode(response.body)['name'],
            items: cartItems,
            dateTime: DateTime.now(),
          ));
      notifyListeners();
    } catch (_) {
      throw HTTPException("Error");
    }
  }
}
