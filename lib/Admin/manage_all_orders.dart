import 'package:flutter/material.dart';
import 'package:shopping_app/Admin/updateOrder.dart';
import 'package:shopping_app/widget/Colors/Colors.dart';
import 'package:shopping_app/widget/support_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManageAllOrders extends StatefulWidget {
  const ManageAllOrders({super.key});

  @override
  State<ManageAllOrders> createState() => _ManageAllOrdersState();
}

class _ManageAllOrdersState extends State<ManageAllOrders> {
  Future<List<Map<String, dynamic>>>? _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = fetchOrders(); // ✅ Initialize here
  }

  Future<List<Map<String, dynamic>>> fetchOrders() async {
    final supabase = Supabase.instance.client;
    final response = await supabase.from('orders').select();
    return List<Map<String, dynamic>>.from(response);
  }

  void refreshOrders() {
    setState(() {
      _ordersFuture = fetchOrders(); // ✅ Refresh future safely
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage All Orders", style: AppWidget.semiboldTetField()),
        backgroundColor: AllColor.mainBGColor,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No Orders found'));
          }

          final orders = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UpdateOrder(
                        orderId: order['id'],
                        status: order['status'],
                      ),
                    ),
                  ).then((_) {
                    // 🔄 Refresh when coming back
                    refreshOrders();
                  });
                },
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
                          Row(
                            children: [
                              Text(
                                "Order Id:",
                                style: AppWidget.orderIdStyle(),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                order['id'] != null
                                    ? order['id'].substring(0, 8) + "..."
                                    : 'Not Fetched',
                                style: AppWidget.orderIdStyle(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text("Customer:", style: AppWidget.labelStyle()),
                              const SizedBox(width: 10),
                              Text('Krish', style: AppWidget.dataStyle()),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text("Email:", style: AppWidget.labelStyle()),
                              const SizedBox(width: 10),
                              Text(
                                'ksolanki700@rku.ac.in',
                                style: AppWidget.dataStyle(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text("Price:", style: AppWidget.priceStyle()),
                              const SizedBox(width: 10),
                              Text(
                                '₹ ${order['total_price'] ?? 'N/A'}',
                                style: AppWidget.priceStyle(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text("Status:", style: AppWidget.labelStyle()),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: getStatusColor(order['status'] ?? ''),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  order['status'] ?? 'No Status',
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
      case 'Accepted':
        return AllColor.greenColor;
      case 'Dispatch':
        return AllColor.tealColor;
      case 'On The Way':
        return AllColor.orangeBGColor;
      case 'Delivered':
        return AllColor.greenColor600!;
      case 'Cancled':
        return AllColor.redColor;
      default:
        return AllColor.greyColor;
    }
  }
}