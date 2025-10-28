import 'package:flutter/material.dart';
import 'package:shopping_app/pages/displayAllOrder.dart';
import 'package:shopping_app/pages/login.dart';
import 'package:shopping_app/widget/Colors/Colors.dart';
import 'package:shopping_app/widget/support_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Order extends StatefulWidget {
  const Order({super.key});

  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> {
  // ✅ Get the Supabase client instance
  final supabase = Supabase.instance.client;

  // ✅ Get the current user (id + email)
  User? get currentUser => Supabase.instance.client.auth.currentUser;

  Future<List<Map<String, dynamic>>> fetchOrders() async {
    if (currentUser == null) return [];

    // ✅ Use the user ID (UUID) to fetch orders for this user
    final response = await supabase
        .from('orders')
        .select()
        .eq('user_id', currentUser!.id);

    return response;
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      Future.microtask(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Login()),
        );
      });
      return const SizedBox();
    }

    return Scaffold(
      backgroundColor: AllColor.mainBGColor,
      appBar: AppBar(
        backgroundColor: AllColor.mainBGColor,
        elevation: 0,
        title: const Text("Your Orders:"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchOrders(),
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
          debugPrint("Response of orders: $products");

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];

              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DisplayAllOrder(orderId: product['id']),
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.only(left: 5, right: 5, bottom: 15),
                  child: Material(
                    elevation: 3,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AllColor.whiteColor,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Order ID Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Order Id:",
                                style: AppWidget.orderIdStyle(),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                product['id']?.substring(0, 8) ?? 'Not Fetched',
                                style: AppWidget.orderIdStyle(),
                              ),
                            ],
                          ),

                          /// Customer Name
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text("Customer:", style: AppWidget.labelStyle()),
                              const SizedBox(width: 10),
                              Text(
                                product['name'] ?? 'Not Found',
                                style: AppWidget.dataStyle(),
                              ),
                            ],
                          ),

                          /// Email Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text("Email:", style: AppWidget.labelStyle()),
                              const SizedBox(width: 10),
                              Text(
                                currentUser?.email ?? 'Not Found',
                                style: AppWidget.dataStyle(),
                              ),
                            ],
                          ),

                          /// Price Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text("Price:", style: AppWidget.priceStyle()),
                              const SizedBox(width: 10),
                              Text(
                                "₹ ${product['total_price'] ?? '0'}",
                                style: AppWidget.priceStyle(),
                              ),
                            ],
                          ),

                          /// Status Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text("Status:", style: AppWidget.labelStyle()),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: getStatusColor(
                                    product['status']?.toString() ?? '',
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  product['status'] ?? 'No Status',
                                  style: const TextStyle(
                                    color: AllColor.whiteColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
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
        return AllColor.greenColor;
      case 'Dispatched':
        return AllColor.orangeColor;
      case 'Stop':
      case 'Cancled':
        return AllColor.redColor;
      default:
        return AllColor.greyColor;
    }
  }
}
