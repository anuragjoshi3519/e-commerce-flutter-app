import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';
import '../providers/product.dart';
import '../providers/products.dart';
import '../screens/cart_screen.dart';
import '../screens/main_drawer.dart';
import '../widgets/badge.dart';
import '../widgets/product_item.dart';

enum FilterOptions { All, Favorites }

class ProductsOverviewScreen extends StatefulWidget {
  static const routeName = '/product_overview_screen';
  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  bool _showFavorite = false;
  bool _showLoader = false;

  void loadProducts() {
    Provider.of<Products>(context, listen: false)
        .fetchProducts()
        .catchError((_) {
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                title: const Text("Error in loading products"),
                content: const Text("Please try again."),
                actions: [
                  FlatButton(
                    child: const Text("Exit"),
                    onPressed: () {
                      SystemNavigator.pop();
                    },
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pushReplacementNamed(
                          context, ProductsOverviewScreen.routeName);
                    },
                    child: const Text("Retry"),
                  )
                ],
              ));
    }).then((_) {
      setState(() {
        _showLoader = false;
      });
    });
  }

  @override
  void initState() {
    setState(() {
      _showLoader = true;
    });
    Future.delayed(Duration.zero, () {
      loadProducts();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: MainDrawer(),
        appBar: AppBar(
          title: Text(_showFavorite ? "Your Favorites" : "Local Market",
              style: Theme.of(context)
                  .textTheme
                  .headline6
                  .copyWith(color: Colors.white)),
          actions: [
            Consumer<Cart>(
              builder: (ctx, cart, _) => Badge(
                child: IconButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, CartScreen.routeName),
                    icon: const Icon(Icons.shopping_cart)),
                value: cart.totalItems.toString(),
                color: Colors.orange[300],
              ),
            ),
            PopupMenuButton(
                color: Colors.grey[50],
                icon: const Icon(Icons.more_vert),
                elevation: 7,
                onSelected: (FilterOptions option) {
                  setState(() {
                    if (option == FilterOptions.All)
                      _showFavorite = false;
                    else
                      _showFavorite = true;
                  });
                },
                itemBuilder: (ctx) => [
                      PopupMenuItem(
                        child: Row(
                          children: [
                            Icon(Icons.all_inclusive,
                                color: Theme.of(context).accentColor),
                            const SizedBox(width: 7),
                            const Text("Show All"),
                          ],
                        ),
                        value: FilterOptions.All,
                      ),
                      PopupMenuItem(
                        child: Row(
                          // ignore: prefer_const_literals_to_create_immutables
                          children: [
                            const Icon(Icons.favorite, color: Colors.red),
                            const SizedBox(width: 7),
                            const Text("Only Favorites"),
                          ],
                        ),
                        value: FilterOptions.Favorites,
                      )
                    ])
          ],
        ),
        body: _showLoader
            ? Center(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                  Text("Loading products...")
                ],
              ))
            : ProductsGrid(showFavs: _showFavorite),
      ),
    );
  }
}

class ProductsGrid extends StatelessWidget {
  const ProductsGrid({@required this.showFavs});
  final bool showFavs;
  @override
  Widget build(BuildContext context) {
    final List<Product> loadedProducts = !showFavs
        ? Provider.of<Products>(context).items
        : Provider.of<Products>(context).favoriteItems;
    return showFavs == false
        ? loadedProducts.isNotEmpty? GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                childAspectRatio: 6 / 5,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12),
            itemCount: loadedProducts.length,
            itemBuilder: (ctx, index) => ChangeNotifierProvider<Product>.value(
              value: loadedProducts[index],
              child: ProductItem(),
            ),
          ):const Center(
            child: Text(
              "Sorry! There is no product available right now.",
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          )
        : const Center(
            child: Text(
              "You have no favorites.",
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          );
  }
}
