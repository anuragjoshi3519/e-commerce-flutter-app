import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/order.dart' show Order;
import '../widgets/order_item.dart';
import './product_overview_screen.dart';
import 'main_drawer.dart';

class OrderScreen extends StatefulWidget {
  static const routeName = '/orders';

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  Future _orderFuture;

  Future _loadOrders() {
    return Provider.of<Order>(context, listen: false).fetchOrders();
  }

  @override
  void initState() {
    _orderFuture = _loadOrders();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Order orders = Provider.of<Order>(context);
    return SafeArea(
      child: Scaffold(
        drawer: MainDrawer(),
        appBar: AppBar(
            title: Text(
          "Your Orders",
          style: Theme.of(context)
              .textTheme
              .headline6
              .copyWith(color: Colors.white),
        )),
        body: FutureBuilder(
          future: _orderFuture,
          builder: (ctx, orderSnapshot) {
            if (orderSnapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                  Text("Loading orders...")
                ],
              ));
            } else {
              if (orderSnapshot.hasError) {
                return AlertDialog(
                  title: const Text("Error"),
                  content: const Text("Can't load orders. Please try again."),
                  actions: [
                    FlatButton(
                      child: const Text("Close"),
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                            context, ProductsOverviewScreen.routeName);
                      },
                    ),
                    FlatButton(
                      onPressed: () {
                        setState(() {
                          _orderFuture = _loadOrders();
                        });
                      },
                      child: const Text("Retry"),
                    )
                  ],
                );
              }
              return RefreshIndicator(
                onRefresh: _loadOrders,
                child: orders.orderItems.isEmpty
                    ? const Center(
                        child: Text(
                          "You haven't placed any order.",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black54,
                          ),
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.all(8),
                        child: ListView.builder(
                            itemBuilder: (ctx, index) =>
                                OrderItem(order: orders.orderItems[index]),
                            itemCount: orders.orderItems.length),
                      ),
              );
            }
          },
        ),
      ),
    );
  }
}
