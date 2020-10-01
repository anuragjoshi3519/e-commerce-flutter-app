import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_config/flutter_config.dart';

import './providers/cart.dart';
import './providers/order.dart';
import './providers/products.dart';
import './screens/cart_screen.dart';
import './screens/edit_product.dart';
import './screens/manage_product_screen.dart';
import './screens/order_screen.dart';
import './screens/product_overview_screen.dart';
import 'screens/product_detail_screen.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterConfig.loadEnvVariables();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Products>(
          create: (ctx) => Products(),
        ),
        ChangeNotifierProvider<Cart>(
          create: (ctx) => Cart(),
        ),
        ChangeNotifierProvider<Order>(
          create: (ctx) => Order(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
            primarySwatch: Colors.teal,
            accentColor: Colors.blueGrey,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            fontFamily: 'Lato',
            textTheme: Typography.blackMountainView),
        initialRoute: ProductsOverviewScreen.routeName,
        routes: {
          ProductsOverviewScreen.routeName: (ctx) => ProductsOverviewScreen(),
          ProductDetails.routeName: (ctx) => ProductDetails(),
          CartScreen.routeName: (ctx) => CartScreen(),
          OrderScreen.routeName: (ctx) => OrderScreen(),
          ManageProductScreen.routeName: (ctx) => ManageProductScreen(),
          EditProduct.routeName: (ctx) => EditProduct(),
        },
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: Text(title),
          ),
          body: const Center(child: Text('Home'))),
    );
  }
}
