import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/screens/product_overview_screen.dart';

import '../providers/products.dart';
import './edit_product.dart';
import './main_drawer.dart';

class ManageProductScreen extends StatefulWidget {
  static const routeName = "/manage_products";

  @override
  _ManageProductScreenState createState() => _ManageProductScreenState();
}

class _ManageProductScreenState extends State<ManageProductScreen> {
  Future _productsFuture;

  Future _fetchProducts() {
    return Provider.of<Products>(context, listen: false).fetchProducts(true);
  }

  @override
  void initState() {
    _productsFuture = _fetchProducts();
    super.initState();
  }

  DateTime currentBackPressTime;
  Future<bool> onWillPop() {
    final DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: "Press back key again to exit.");
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Your Products",
          style: Theme.of(context).textTheme.headline6.copyWith(
                color: Colors.white,
              ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 6.0),
            child: IconButton(
              tooltip: "Add a new product",
              icon: const Icon(
                Icons.add,
                size: 34,
                color: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pushNamed(
                EditProduct.routeName,
                arguments: {"title": "Add Product", "id": ''},
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 6.0),
            child: IconButton(
              tooltip: "Go to home screen",
              icon: const Icon(
                Icons.home_outlined,
                size: 28,
                color: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pushReplacementNamed(
                ProductsOverviewScreen.routeName,
              ),
            ),
          ),
        ],
      ),
      body: WillPopScope(
        child: FutureBuilder(
            future: _productsFuture,
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(height: 8),
                    Text("Loading products...")
                  ],
                ));
              } else {
                if (snapshot.error != null) {
                  return AlertDialog(
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
                          setState(() {
                            _productsFuture = _fetchProducts();
                          });
                        },
                        child: const Text("Retry"),
                      )
                    ],
                  );
                }
                return RefreshIndicator(
                    onRefresh: _fetchProducts,
                    child: Provider.of<Products>(context, listen: false)
                            .items
                            .isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  padding: const EdgeInsets.all(0),
                                  tooltip: "Add a new product",
                                  icon: Icon(Icons.add_box_outlined,
                                      size: 44,
                                      color: Theme.of(context).primaryColor),
                                  onPressed: () =>
                                      Navigator.of(context).pushNamed(
                                    EditProduct.routeName,
                                    arguments: {
                                      "title": "Add Product",
                                      "id": ''
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                const Text(
                                  'Add a new product to sell.',
                                  style: TextStyle(
                                      fontFamily: 'Lato',
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black45),
                                )
                              ],
                            ),
                          )
                        : Consumer<Products>(
                            builder: (ctx, products, _) => ListView.builder(
                              itemBuilder: (ctx, i) => Column(
                                children: [
                                  ManageProductItem(
                                    id: products.items[i].id,
                                    imageUrl: products.items[i].imageUrl,
                                    title: products.items[i].title,
                                  ),
                                ],
                              ),
                              itemCount: products.items.length,
                            ),
                          ));
              }
            }),
        onWillPop: onWillPop,
      ),
      drawer: MainDrawer(),
    );
  }
}

class ManageProductItem extends StatefulWidget {
  const ManageProductItem({
    @required this.id,
    @required this.imageUrl,
    @required this.title,
  });
  final String id;
  final String imageUrl;
  final String title;

  @override
  _ManageProductItemState createState() => _ManageProductItemState();
}

class _ManageProductItemState extends State<ManageProductItem> {
  bool _showLoader = false;

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);
    return Container(
      child: !_showLoader
          ? Card(
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              margin: const EdgeInsets.all(2.0),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(widget.imageUrl),
                  radius: 23,
                ),
                title: Text(widget.title),
                trailing: Container(
                    width: 100,
                    child: Row(
                      children: [
                        const Spacer(),
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: Theme.of(context).primaryColor,
                          ),
                          onPressed: () => Navigator.of(context).pushNamed(
                            EditProduct.routeName,
                            arguments: {
                              "title": "Edit Product",
                              "id": widget.id
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete,
                              color: Theme.of(context).errorColor),
                          onPressed: () => showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text(
                                "Are you sure?",
                              ),
                              content: const Text(
                                "This action will permanently delete the product.",
                              ),
                              actions: [
                                FlatButton(
                                  onPressed: () async {
                                    Navigator.of(ctx).pop();
                                    setState(() {
                                      _showLoader = true;
                                    });
                                    try {
                                      await Provider.of<Products>(context,
                                              listen: false)
                                          .deleteProduct(widget.id);
                                    } catch (error) {
                                      scaffold.showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "${error.message} Something went wrong.",
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                          duration: const Duration(seconds: 3),
                                          backgroundColor: Colors.black87,
                                        ),
                                      );
                                    }
                                    setState(() {
                                      _showLoader = false;
                                    });
                                  },
                                  child: const Text(
                                    "YES",
                                  ),
                                ),
                                FlatButton(
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  child: const Text(
                                    "NO",
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )),
              ),
            )
          : const Padding(
              padding: EdgeInsets.all(12.0),
              child: FittedBox(
                child: CircularProgressIndicator(
                  strokeWidth: 3.0,
                ),
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
    );
  }
}
