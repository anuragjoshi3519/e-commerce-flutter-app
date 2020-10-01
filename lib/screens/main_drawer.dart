import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../screens/cart_screen.dart';
import '../screens/manage_product_screen.dart';
import '../screens/order_screen.dart';
import '../screens/product_overview_screen.dart';

class MainDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        child: Container(
          child: Column(
            children: [
              AppBar(
                toolbarHeight: kToolbarHeight + 15,
                leading: const Padding(
                  padding: EdgeInsets.only(left: 15.0, top: 8.0, bottom: 8.0),
                  child: CircleAvatar(
                    child: Icon(Icons.person),
                    radius: 5,
                  ),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Anurag Joshi",
                        style: TextStyle(
                          fontSize: 18,
                        )),
                    const SizedBox(height: 5),
                    GestureDetector(
                      onTap: null,
                      child: const Text("Profile",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70)),
                    ),
                    const SizedBox(height: 3),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.shop),
                title: const Text(
                  "Local Shop",
                  style: TextStyle(fontSize: 16),
                ),
                subtitle: const Text("Go to your local shop"),
                onTap: () => Navigator.of(context)
                    .pushReplacementNamed(ProductsOverviewScreen.routeName),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.shopping_cart),
                title: const Text(
                  "Your Cart",
                  style: TextStyle(fontSize: 16),
                ),
                subtitle: const Text("Go to cart"),
                onTap: () =>
                    Navigator.of(context).pushNamed(CartScreen.routeName),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.payment),
                title: const Text(
                  "Orders",
                  style: TextStyle(fontSize: 16),
                ),
                subtitle: const Text("See your orders"),
                onTap: () => Navigator.of(context)
                    .pushReplacementNamed(OrderScreen.routeName),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.mode_edit),
                title: const Text(
                  "Manage Products",
                  style: TextStyle(fontSize: 16),
                ),
                subtitle: const Text("Add or edit your products"),
                onTap: () => Navigator.of(context).pushReplacementNamed(
                  ManageProductScreen.routeName,
                ),
              ),
              const Spacer(),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text(
                  "Settings",
                  style: TextStyle(fontSize: 16),
                ),
                onTap: () => null,
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: const Text(
                  "Exit",
                  style: TextStyle(fontSize: 16),
                ),
                onTap: () => showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                            title: const Text("Exit"),
                            content: const Text("Do you really want to exit?"),
                            actions: [
                              FlatButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: const Text("NO"),
                              ),
                              FlatButton(
                                onPressed: () => SystemNavigator.pop(),
                                child: const Text("YES"),
                              ),
                            ])),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
