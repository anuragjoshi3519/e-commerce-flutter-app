import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../providers/product.dart';
import '../screens/product_detail_screen.dart';
import '../widgets/add_item_to_cart.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);
    final Product product = Provider.of<Product>(context, listen: false);
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, ProductDetails.routeName,
            arguments: product.id),
        child: GridTile(
          child: Hero(
            tag: product.id,
            child: FadeInImage(
              placeholder: const AssetImage(
                  'assets/images/product-placeholder.jpg'),
              image: NetworkImage(
                product.imageUrl,
              ),
              fit: BoxFit.cover,
            ),
          ),
          footer: Container(
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, left: 6, right: 6),
            decoration: const BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(6), topRight: Radius.circular(6))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 115,
                  child: Text(
                    product.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerRight,
                  width: 60,
                  child: Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
          header:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            AddItemToCart(product: product),
            Consumer<Product>(
              builder: (ctx, product, child) => IconButton(
                icon: Icon(
                  !product.isFavorite ? Icons.favorite_border : Icons.favorite,
                  color: Colors.red,
                  size: 26,
                ),
                onPressed: () async {
                  try {
                    await product.toggleFavorite(
                        Provider.of<Auth>(context, listen: false).token,
                        Provider.of<Auth>(context, listen: false).userId);
                  } catch (error) {
                    scaffold.showSnackBar(
                      SnackBar(
                        content: Text(
                          error.message as String,
                          style: const TextStyle(fontSize: 15),
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.black87,
                        margin: const EdgeInsets.all(8.0),
                      ),
                    );
                  }
                },
              ),
            )
          ]),
        ),
      ),
    );
  }
}
