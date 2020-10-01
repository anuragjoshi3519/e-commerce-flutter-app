import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';
import '../providers/product.dart';

class AddItemToCart extends StatelessWidget {
  const AddItemToCart({@required this.product});
  final Product product;
  @override
  Widget build(BuildContext context) {
    return Consumer<Cart>(
      builder: (ctx, cart, child) => IconButton(
          icon: child,
          onPressed: () {
            cart.addToCart(product.id, product.title, product.price);
            Scaffold.of(context).hideCurrentSnackBar();
            Scaffold.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(6.0),
                content: const Text(
                  "Item added to cart!",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(6.0)),
                ),
                backgroundColor: Colors.black87,
                elevation: 10,
                duration: const Duration(
                  seconds: 2,
                  milliseconds: 500,
                ),
                action: SnackBarAction(
                  label: "UNDO",
                  textColor: Colors.tealAccent,
                  onPressed: () => cart.removeItem(product.id),
                ),
              ),
            );
          }),
      child: const Icon(
        Icons.add_shopping_cart,
        size: 28,
      ),
    );
  }
}