import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_config/flutter_config.dart';

import './providers/auth.dart';
import './providers/cart.dart';
import './providers/order.dart';
import './providers/products.dart';
import './screens/auth_screen.dart';
import './screens/cart_screen.dart';
import './screens/edit_product.dart';
import './screens/manage_product_screen.dart';
import './screens/order_screen.dart';
import './screens/product_overview_screen.dart';
import 'screens/product_detail_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterConfig.loadEnvVariables();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Auth>(
          create: (ctx) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          update: (ctx, auth, previousProducts) => Products(
              auth.token,
              auth.userId,
              previousProducts != null ? previousProducts.items : []),
          create: null,
        ),
        ChangeNotifierProvider<Cart>(
          create: (ctx) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Order>(
          update: (ctx, auth, previousOrders) => Order(auth.token,
              previousOrders != null ? previousOrders.orderItems : []),
          create: null,
        ),
      ],
      child: Consumer<Auth>(builder: (ctx, auth, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(
              primarySwatch: Colors.teal,
              accentColor: Colors.blueGrey,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              fontFamily: 'Lato',
              textTheme: Typography.blackMountainView),
          home: auth.isAuthenticated ? ProductsOverviewScreen() : AuthScreen(),
          routes: {
            ProductsOverviewScreen.routeName: (ctx) => ProductsOverviewScreen(),
            ProductDetails.routeName: (ctx) => ProductDetails(),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrderScreen.routeName: (ctx) => OrderScreen(),
            ManageProductScreen.routeName: (ctx) => ManageProductScreen(),
            EditProduct.routeName: (ctx) => EditProduct(),
            AuthScreen.routeName: (ctx) => AuthScreen(),
          },
        );
      }),
    );
  }
}
