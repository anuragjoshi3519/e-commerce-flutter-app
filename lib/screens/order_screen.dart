import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/order.dart' show Order;
import '../widgets/order_item.dart';
import 'main_drawer.dart';

class OrderScreen extends StatefulWidget {
  static const routeName = '/orders';

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  bool _showLoader = false;

  Future<void> loadOrders() async {
    try {
      await Provider.of<Order>(context, listen: false).fetchOrders();
    } catch (_) {
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                title: const Text("Error"),
                content: const Text("Can't load orders. Please try again."),
                actions: [
                  FlatButton(
                    child: const Text("Close"),
                    onPressed: () {
                      Navigator.pop(ctx);
                    },
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pushReplacementNamed(
                          context, OrderScreen.routeName);
                    },
                    child: const Text("Retry"),
                  )
                ],
              ));
    } finally {
      setState(() {
        _showLoader = false;
      });
    }
  }

  @override
  void initState() {
    setState(() {
      _showLoader = true;
    });
    Future.delayed(Duration.zero, () {
      loadOrders();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Order orders = Provider.of<Order>(context, listen: false);
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
        body: !_showLoader
            ? RefreshIndicator(
                onRefresh: loadOrders,
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
              )
            : Center(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                  Text("Loading orders...")
                ],
              )),
      ),
    );
  }
}
