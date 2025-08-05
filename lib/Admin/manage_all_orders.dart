import 'package:flutter/material.dart';
import 'package:shopping_app/widget/support_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManageAllOrders extends StatefulWidget {
  const ManageAllOrders({super.key});

  @override
  State<ManageAllOrders> createState() => _ManageAllOrdersState();
}

class _ManageAllOrdersState extends State<ManageAllOrders> {
  Future<List<Map<String, dynamic>>> fetchProducts() async {
    final supabase = Supabase.instance.client;
    final response = await supabase.from('orders').select();
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage All Orders", style: AppWidget.semiboldTetField()),
        backgroundColor: const Color(0xfff2f2f2),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchProducts(),
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

          final products = snapshot.data!;
          debugPrint("✅ Fetched ordeers: $products");

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final orders = products[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Material(
                  elevation: 3,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    child: Row(
                      children: [
                        // Check Condition for image URL
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: AssetImage('images/boy.jpg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Email: " + orders['email'] ?? 'No Name',
                                style: AppWidget.orderPageTextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "Name: " + orders['user_name'] ?? '',
                                style: AppWidget.orderPageTextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "Price: " + orders['price'] ?? 'No Price',
                                style: AppWidget.orderPageTextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 5),
                              Center(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // 🔵 Left: Current Status
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: getStatusColor(orders['status']),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        orders['status'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),

                                    ElevatedButton(
                                      onPressed: () {
                                        String currentStatus = orders['status'];
                                        String nextStatus = getNextStatus(
                                          currentStatus,
                                        );
                                        upadateStatus(nextStatus, orders['id']);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: getStatusColor(
                                          getNextStatus(orders['status']),
                                        ),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        getNextStatus(orders['status']),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Future<void> upadateStatus(String status, String s) async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('orders')
        .update({'status': status})
        .eq('id', s);
    setState(() {});
    print('Status updated: $response');
  }

  String getNextStatus(String current) {
    switch (current) {
      case 'Pending':
        return 'Acepted';
      case 'Acepted':
        return 'Dispatched';
      case 'Dispatched':
        return 'Stop';
      case 'Cancled':
        return 'Reactive';
      case 'Stop':
        return 'Acepted';
      default:
        return 'Acepted'; // fallback
    }
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
