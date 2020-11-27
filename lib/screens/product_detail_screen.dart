import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';
import '../widgets/add_item_to_cart.dart';

class ProductDetails extends StatelessWidget {
  static const routeName = 'productdetails/';

  @override
  Widget build(BuildContext context) {
    final String id = ModalRoute.of(context).settings.arguments;
    final Products products = Provider.of<Products>(context);
    final Product product = products.findById(id);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            product.title,
            style: Theme.of(context)
                .textTheme
                .headline6
                .copyWith(color: Colors.white),
          ),
          actions: [
            AddItemToCart(product: product),
          ],
        ),
        body: product != null
            ? SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      height: 220,
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Hero(
                            tag: id,
                            child: Image.network(product.imageUrl,
                                fit: BoxFit.cover)),
                      ),
                    ),
                    Card(
                      elevation: 0.5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: 250,
                                    child: Text(
                                      // ignore: unnecessary_string_interpolations
                                      '${product.title}',
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                      softWrap: true,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                      width: 67,
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          color: Colors.green[400],
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: FittedBox(
                                        fit: BoxFit.contain,
                                        child: Text(
                                          "\$${product.price.toStringAsFixed(2)}",
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ))
                                ]),
                            const SizedBox(height: 20),
                            const Divider(
                              color: Colors.black87,
                              thickness: 0.5,
                              indent: 12,
                              endIndent: 12,
                              height: 10,
                            ),
                            const SizedBox(height: 30),
                            Text('Product Discription:',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 19,
                                )),
                            const SizedBox(height: 20),
                            // ignore: unnecessary_string_interpolations
                            Text('${product.description}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                )),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              )
            : const Center(
                child: Text(
                  "No such product available",
                  style: TextStyle(
                    fontSize: 19,
                  ),
                ),
              ),
      ),
    );
  }
}
