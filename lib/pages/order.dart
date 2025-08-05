import 'package:flutter/material.dart';
import 'package:shopping_app/pages/login.dart';
import 'package:shopping_app/widget/support_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Order extends StatefulWidget {
  const Order({super.key});

  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> {
  final userEmail = Supabase.instance.client.auth.currentUser?.email;

  @override
  Widget build(BuildContext context) {
    if (userEmail == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => Login()),
      );
    }
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
            .stream(primaryKey: ['id'])
            .eq('email', userEmail.toString())
            .execute(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No orders found'));
          }

          final products = snapshot.data!;
          debugPrint("Responce of orders: ${products}");

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];

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
                            product['image_url'] != null
                                ? Image.network(
                                    product!['image_url'],
                                    fit: BoxFit.cover,
                                    width: 120,
                                    height: 120,
                                  )
                                : const Icon(Icons.image_not_supported),
                            SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product['product_name'] ?? 'Not Fetched',
                                  style: AppWidget.semiboldTetField(),
                                ),
                                Text(
                                  "Price: " + product['price'] ?? 'Not Fetched',
                                  style: AppWidget.orderPageTextStyle(
                                    color: Colors.orange,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text('Status: '),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: getStatusColor(
                                          product['status'],
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        product['status'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
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

  Color getStatusColor(String status) {
    switch (status) {
      case 'Acepted':
      case 'Reactive':
        return Colors.green;
      case 'Dispatched':
        return Colors.orange;
      case 'Stop':
      case 'Cancled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
