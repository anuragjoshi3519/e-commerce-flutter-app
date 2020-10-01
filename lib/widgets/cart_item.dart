import 'package:flutter/material.dart';

import '../screens/product_detail_screen.dart';

class CartItem extends StatelessWidget {
  const CartItem(
      {@required this.id,
      @required this.title,
      @required this.price,
      @required this.quantity,
      @required this.removeFromCart});
  final String id;
  final String title;
  final double price;
  final int quantity;
  final Function removeFromCart;


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Dismissible(
        key: ValueKey(id),
        onDismissed: (direction) {
          removeFromCart(id);
        },
        // confirmDismiss: (direction) {
        //   var dismiss = true;
        //   Scaffold.of(context).hideCurrentSnackBar();
        //   Scaffold.of(context).showSnackBar(
        //     SnackBar(
        //       content: Text("Item removed from cart!"),
        //       duration: Duration(
        //         seconds: 1,
        //         milliseconds: 500
        //       ),
        //       action: SnackBarAction(
        //           label: "UNDO",
        //           onPressed: () {
        //             dismiss = false;
        //           }),
        //     ),
        //   );
        //   return Future.delayed(
        //       Duration(seconds: 1,milliseconds: 500), () => Future.value(dismiss));
        // },
        background: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Colors.red[300],
                  Colors.red[300],
                  Colors.red,
                  Colors.red,
                  Colors.red,
                ]),
                borderRadius: const BorderRadius.all(Radius.circular(10))),
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            alignment: Alignment.centerRight,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.delete,
                color: Colors.white,
                size: 30,
              ),
            )),
        direction: DismissDirection.endToStart,
        child: Card(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))),
          elevation: 1,
          child: ListTile(
            leading: CircleAvatar(
              child: FittedBox(
                  fit: BoxFit.contain,
                  child: Padding(
                    padding:const  EdgeInsets.all(3),
                    child: Text(
                      '\$${price.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  )),
              backgroundColor: Colors.teal[300],
              radius: 24,
            ),
            title: GestureDetector(
              onTap: () => Navigator.pushNamed(
                  context, ProductDetails.routeName,
                  arguments: id),
              child: Text(
                title,
                style: const TextStyle(fontSize:18),
              ),
            ),
            trailing: Text(
              'x$quantity',
              style: const TextStyle(
                fontSize: 18,
                fontFamily: "Lato",
              ),
            ),
            subtitle: Text(
              'Cost: \$${(quantity * price).toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 14,
                fontFamily: "Lato",
              ),
            ),
          ),
        ),
      ),
    );
  }
}
