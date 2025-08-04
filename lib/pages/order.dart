import 'package:flutter/material.dart';
import 'package:shopping_app/widget/support_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Order extends StatefulWidget {
  const Order({super.key});

  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> {
  Stream? ordersTree;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),
      appBar: AppBar(
        backgroundColor: const Color(0xfff2f2f2),
        elevation: 0,
        title: Text("Your Orders:"),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: Supabase.instance.client
            .from('orders')
            .stream(
              primaryKey: ['id'],
            ) // ⚠️ Use actual primary key of your table
            .eq('email', "default123@gmail.com") // filter by category
            .execute(),
        builder: (context, snapshot) {
          final products = snapshot.data!;
          debugPrint("Responce of orders: ${products}");

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              debugPrint('Image Url ${product['image_url']}');

              return Container(
                margin: EdgeInsets.only(left: 5, right: 5),
                child: Column(
                  children: [
                    Material(
                      elevation: 3,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: EdgeInsets.only(left: 20, top: 10, bottom: 10),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            product['imageg_url'] == null
                                ? Image.network(
                                    product!['image_url'],
                                    fit: BoxFit.cover,
                                    width: 120,
                                    height: 120,
                                  )
                                : const Icon(Icons.image_not_supported),
                            SizedBox(width: 20),
                            Column(
                              children: [
                                Text(
                                  product['product_name'] ?? 'Not Fetched',
                                  style: AppWidget.semiboldTetField(),
                                ),
                                Text(
                                  product['price'] ?? 'Not Fetched',
                                  style: const TextStyle(
                                    color: Color(0xFFfd6f3e),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
