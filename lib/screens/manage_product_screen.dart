import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import './edit_product.dart';
import './main_drawer.dart';

class ManageProductScreen extends StatefulWidget {
  static const routeName = "/manage_products";

  @override
  _ManageProductScreenState createState() => _ManageProductScreenState();
}

class _ManageProductScreenState extends State<ManageProductScreen> {
  Future<void> refreshProducts() async {
    await Provider.of<Products>(context, listen: false).fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
          ],
        ),
        body: Consumer<Products>(
            builder: (ctx, products, child) => RefreshIndicator(
                  onRefresh: refreshProducts,
                  child: ListView.builder(
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
                )),
        drawer: MainDrawer(),
      ),
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
              margin: const EdgeInsets.all(2.0),
              child: ListTile(
                contentPadding: const EdgeInsets.all(14),
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(widget.imageUrl),
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
