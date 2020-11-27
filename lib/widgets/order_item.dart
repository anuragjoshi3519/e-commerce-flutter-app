import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../providers/order.dart' as ord;

class OrderItem extends StatefulWidget {
  const OrderItem({
    @required this.order,
  });
  final ord.OrderItem order;

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  bool _expandTile = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: ListTile(
              isThreeLine: true,
              leading: const Icon(Icons.shopping_basket,
                  size: 32, color: Colors.teal),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Order ID: ${widget.order.id.hashCode}",
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 19,
                    ),
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  Text(
                    "Total Amount: ${widget.order.totalAmount.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  )
                ],
              ),
              subtitle: Text(
                DateFormat("dd/MM/yyyy hh:mm").format(widget.order.dateTime),
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              trailing: IconButton(
                  icon: Icon(
                      !_expandTile ? Icons.expand_more : Icons.expand_less,
                      size: 32),
                  onPressed: () {
                    setState(() {
                      _expandTile = !_expandTile;
                    });
                  }),
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.ease,
          height: _expandTile
              ? min(250.0, widget.order.items.length * 40 + 5.0)
              : 0,
          child: ListView(
              children: widget.order.items
                  .map(
                    (e) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 8),
                      child: Row(
                        children: [
                          Text(
                            e.title,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Spacer(),
                          Text(
                            "\$${e.price} x${e.quantity}",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList()),
        ),
      ],
    );
  }
}
