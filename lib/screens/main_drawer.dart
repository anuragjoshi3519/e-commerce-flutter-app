import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
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
                toolbarHeight: kToolbarHeight + 16,
                leading: const Padding(
                  padding: EdgeInsets.only(left: 15.0, top: 8.0, bottom: 8.0),
                  child: CircleAvatar(
                    child: Icon(Icons.person_outlined),
                    radius: 5,
                  ),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(Provider.of<Auth>(context, listen: false).email,
                        style: const TextStyle(
                          fontSize: 18,
                        )),
                    // const SizedBox(height: 5),
                    // GestureDetector(
                    //   onTap: null,
                    //   child: const Text("Edit profile",
                    //       style: TextStyle(
                    //           fontSize: 14,
                    //           fontWeight: FontWeight.bold,
                    //           color: Colors.white70)),
                    // ),
                    const SizedBox(height: 3),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: Icon(
                  Icons.shop,
                  color: Theme.of(context).primaryColor,
                ),
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
                leading: Icon(
                  Icons.shopping_cart,
                  color: Theme.of(context).primaryColor,
                ),
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
                leading: Icon(
                  Icons.payment,
                  color: Theme.of(context).primaryColor,
                ),
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
                leading: Icon(
                  Icons.mode_edit,
                  color: Theme.of(context).primaryColor,
                ),
                title: const Text(
                  "Manage Products",
                  style: TextStyle(fontSize: 16),
                ),
                subtitle: const Text("Add or edit your products"),
                onTap: () {
                  Navigator.of(context).pushReplacementNamed(
                    ManageProductScreen.routeName,
                  );
                },
              ),
              const Spacer(),
              // ListTile(
              //   leading: const Icon(Icons.settings),
              //   title: const Text(
              //     "Settings",
              //     style: TextStyle(fontSize: 15),
              //   ),
              //   onTap: () => null,
              // ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text(
                  "Log out",
                  style: TextStyle(fontSize: 15),
                ),
                onTap: () => showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                      title: const Text("Logging out?"),
                      content: const Text("Do you wish to continue?"),
                      actions: [
                        FlatButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text("NO"),
                        ),
                        FlatButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Provider.of<Auth>(context, listen: false).logout();
                            Navigator.of(context).pushReplacementNamed('/');
                          },
                          child: const Text("YES"),
                        ),
                      ]),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.exit_to_app_rounded),
                title: const Text(
                  "Exit",
                  style: TextStyle(fontSize: 15),
                ),
                onTap: () => showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                            title: const Text("Exit?"),
                            content: const Text("Do you really wish to exit?"),
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
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
