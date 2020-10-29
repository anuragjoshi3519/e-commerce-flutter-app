import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart' show Cart;
import '../providers/order.dart';
import '../widgets/cart_item.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart_screen';
  @override
  Widget build(BuildContext context) {
    final Order orders = Provider.of<Order>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart',
            style: Theme.of(context)
                .textTheme
                .headline6
                .copyWith(color: Colors.white)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 6.0),
            child: IconButton(
              tooltip: "Go to home screen",
              icon: const Icon(
                Icons.home_outlined,
                size: 28,
                color: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
      body: Consumer<Cart>(
        builder: (_, cart, child) => cart.length != 0
            ? Column(
                children: [
                  const SizedBox(height: 8.0),
                  Expanded(
                    child: ListView.builder(
                        padding: const EdgeInsets.all(5),
                        itemCount: cart.length,
                        itemBuilder: (_, index) => CartItem(
                            id: cart.cartItems.keys.toList()[index],
                            quantity:
                                cart.cartItems.values.toList()[index].quantity,
                            title: cart.cartItems.values.toList()[index].title,
                            price: cart.cartItems.values.toList()[index].price,
                            removeFromCart: cart.removeFromCart)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 6.0),
                    child: Card(
                      elevation: 0.5,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 18.0),
                            child: Text(
                              '\$ Total amount',
                              style: TextStyle(
                                fontSize: 23,
                                color: Colors.blueGrey[900],
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Column(children: [
                              Container(
                                  margin: const EdgeInsets.only(top: 20),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      color: Colors.green[400],
                                      borderRadius: BorderRadius.circular(20)),
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: Text(
                                      "\$${cart.totalAmount.toStringAsFixed(2)}",
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )),
                              FlatButton(
                                  child: Text(
                                    "ORDER NOW",
                                    style: TextStyle(
                                        color: Colors.teal[300],
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text(
                                          "Proceed To Payment",
                                        ),
                                        content: const Text(
                                          "Do you wish to continue?",
                                        ),
                                        actions: [
                                          FlatButton(
                                              child: const Text("YES"),
                                              onPressed: () async {
                                                Navigator.pop(ctx);
                                                try {
                                                  await orders.addOrder(cart
                                                      .cartItems.values
                                                      .toList());
                                                  cart.clearCart();
                                                } catch (error) {
                                                  showDialog(
                                                      context: context,
                                                      builder:
                                                          (ctx) => AlertDialog(
                                                                title: Text(
                                                                  error.message
                                                                      as String,
                                                                ),
                                                                content:
                                                                    const Text(
                                                                  "Something went wrong. Please retry.",
                                                                ),
                                                                actions: [
                                                                  FlatButton(
                                                                    child: const Text(
                                                                        "CLOSE"),
                                                                    onPressed: () =>
                                                                        Navigator.pop(
                                                                            ctx),
                                                                  )
                                                                ],
                                                              ));
                                                }
                                              }),
                                          FlatButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx),
                                              child: const Text("NO"))
                                        ],
                                      ),
                                    );
                                  }),
                            ]),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : const Center(
                child: Text(
                  "Your cart is empty.",
                  style: TextStyle(fontFamily: "Lato", fontSize: 18),
                ),
              ),
      ),
    );
  }
}
