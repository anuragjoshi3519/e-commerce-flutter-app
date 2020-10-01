import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';

class EditProduct extends StatefulWidget {
  static const routeName = '/edit_product';
  @override
  _EditProductState createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageURLController = TextEditingController();
  final _formGlobalKey = GlobalKey<FormState>();
  String _pageTitle;
  String _productId;
  var _showLoader = false;
  var _editMode = false;

  var _initStatus = true;

  final Map<String, Object> _productDetails = {
    "id": DateTime.now().toString(),
    "title": '',
    "description": '',
    "price": '',
    "imageURL": '',
    "isFavorite": false,
  };

  @override
  void dispose() {
    super.dispose();
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageURLController.dispose();
  }

  @override
  void didChangeDependencies() {
    if (_initStatus) {
      final args =
          ModalRoute.of(context).settings.arguments as Map<String, Object>;
      _pageTitle = args["title"];
      _productId = args["id"];
      if (_productId.isNotEmpty) {
        _editMode = true;
        initializeProduct(_productId);
      }
    }
    _initStatus = false;
    super.didChangeDependencies();
  }

  void initializeProduct(String productId) {
    final Product product =
        Provider.of<Products>(context, listen: false).findById(productId);
    _productDetails["id"] = product.id;
    _productDetails["title"] = product.title;
    _productDetails["price"] = product.price;
    _productDetails["description"] = product.description;
    _productDetails["isFavorite"] = product.isFavorite;
    _imageURLController.text = product.imageUrl;
  }

  Future<void> submitForm() async {
    if (_formGlobalKey.currentState.validate()) {
      setState(() {
        _showLoader = true;
      });
      _formGlobalKey.currentState.save();
      final Product product = Product(
          id: _productDetails["id"] as String,
          title: _productDetails["title"] as String,
          price: _productDetails["price"] as double,
          description: _productDetails["description"] as String,
          imageUrl: _productDetails["imageURL"] as String,
          isFavorite: _productDetails["isFavorite"] as bool);

      final products = Provider.of<Products>(context, listen: false);
      try {
        if (_productId.isNotEmpty) {
          await products.updateProduct(product);
        } else {
          await products.addProduct(product);
        }
        setState(() {
          _showLoader = false;
        });
        Navigator.pop(context);
      } catch (error) {
        setState(() {
          _showLoader = false;
        });
        return await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(error.message as String),
            content: const Text("Something went wrong. Please retry."),
            actions: [
              FlatButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                  },
                  child: const Text('CLOSE'))
            ],
          ),
        );
      }
    }
  }

  void saveData(String field, String value) {
    if (field != 'price')
      _productDetails[field] = value;
    else
      _productDetails[field] = double.parse(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _pageTitle,
          style: Theme.of(context).textTheme.headline6.copyWith(
                color: Colors.white,
              ),
        ),
      ),
      body: !_showLoader
          ? SingleChildScrollView(
              child: Column(
                children: [
                  Form(
                    key: _formGlobalKey,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextFormField(
                            initialValue: _productDetails["title"] as String,
                            decoration: const InputDecoration(
                              labelText: "Title",
                            ),
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => FocusScope.of(context)
                                .requestFocus(_priceFocusNode),
                            onSaved: (value) {
                              saveData("title", value);
                            },
                            validator: (value) {
                              if (value.isNotEmpty)
                                return null;
                              else
                                return "Title cannot be empty";
                            },
                          ),
                          TextFormField(
                            initialValue: _productDetails["price"].toString(),
                            decoration: const InputDecoration(
                              labelText: "Price",
                            ),
                            focusNode: _priceFocusNode,
                            enableInteractiveSelection: true,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => FocusScope.of(context)
                                .requestFocus(_descriptionFocusNode),
                            keyboardType: TextInputType.number,
                            onSaved: (value) {
                              saveData("price", value);
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return "Price cannot be empty";
                              }
                              if (double.tryParse(value) == null)
                                return "Invalid price";
                              if (double.parse(value) <= 0)
                                return "Price cannot be less than or equal to 0";
                              return null;
                            },
                          ),
                          TextFormField(
                            initialValue:
                                _productDetails["description"] as String,
                            maxLines: 3,
                            enableInteractiveSelection: true,
                            decoration: const InputDecoration(
                              labelText: "Give Description",
                            ),
                            focusNode: _descriptionFocusNode,
                            onSaved: (value) {
                              saveData("description", value);
                            },
                            validator: (value) {
                              if (value.isEmpty)
                                return "Please give a description.";
                              if (value.length < 10)
                                return "Description can't be less than 10 characters";
                              return null;
                            },
                          ),
                          const SizedBox(height: 8.0),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                width: 70,
                                height: 50,
                                decoration: BoxDecoration(border: Border.all()),
                                child: _imageURLController.text.isEmpty
                                    ? const Center(
                                        child: Icon(
                                          Icons.broken_image,
                                        ),
                                      )
                                    // : CachedNetworkImage(
                                    //     imageUrl: _imageURLController.text,
                                    //     fit: BoxFit.cover,
                                    //     placeholder: (context, url) =>
                                    //         CircularProgressIndicator(),
                                    //     errorWidget: (context, url, error) =>
                                    //         new Icon(Icons.error),
                                    //   ),
                                    : Image.network(
                                        _imageURLController.text,
                                        fit: BoxFit.cover,
                                        // loadingBuilder: (BuildContext context,
                                        //     Widget child,
                                        //     ImageChunkEvent loadingProgress) {
                                        //   if (loadingProgress == null) return child;
                                        //   return Center(
                                        //     child: CircularProgressIndicator(
                                        //       value: loadingProgress
                                        //                   .expectedTotalBytes !=
                                        //               null
                                        //           ? loadingProgress
                                        //                   .cumulativeBytesLoaded /
                                        //               loadingProgress
                                        //                   .expectedTotalBytes
                                        //           : null,
                                        //     ),
                                        //   );
                                        // },
                                        // errorBuilder: (BuildContext context,
                                        //     Object exception, StackTrace stackTrace) {
                                        //   return Center(
                                        //       child: FittedBox(
                                        //           fit: BoxFit.cover,
                                        //           child: Icon(
                                        //             Icons.error,
                                        //             color: Colors.red,
                                        //           )));
                                        // },
                                      ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  controller: _imageURLController,
                                  decoration: const InputDecoration(
                                    labelText: "Enter Image URL",
                                  ),
                                  keyboardType: TextInputType.url,
                                  onSaved: (value) {
                                    saveData("imageURL", value);
                                  },
                                  onFieldSubmitted: (_) {
                                    setState(() {});
                                  },
                                  enableInteractiveSelection: true,
                                  validator: (value) {
                                    if (value.isEmpty)
                                      return "Image URL can't be empty";
                                    if (!value
                                        .startsWith(RegExp('(https?):\/\/')))
                                      return "URL must start with https:// (or http://)";
                                    const urlPattern = r'(https?):\/\/.+\.[\w]';
                                    final result =
                                        RegExp(urlPattern, caseSensitive: false)
                                            .firstMatch(value);
                                    if (result == null)
                                      return "Please enter a valid image URL";
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              RaisedButton(
                                padding: const EdgeInsets.all(5),
                                disabledColor: Colors.cyan,
                                color: Colors.cyan,
                                onPressed: () {
                                  _formGlobalKey.currentState.validate();
                                  setState(() {});
                                },
                                child: Row(
                                  children: const [
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 4.0),
                                      child: Text(
                                        "Upload",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.upload_outlined,
                                      color: Colors.white,
                                      size: 26,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  RaisedButton(
                    color: Theme.of(context).primaryColor,
                    onPressed: () => submitForm(),
                    child: const Text(
                      "Done",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    hoverElevation: 8,
                  )
                ],
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 8.0),
                  if (_editMode)
                    const Text("Updating product. Please wait...")
                  else
                    const Text("Adding new product. Please wait...")
                ],
              ),
            ),
    );
  }
}
