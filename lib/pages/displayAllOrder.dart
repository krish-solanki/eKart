import 'package:flutter/material.dart';
import 'package:shopping_app/widget/Colors/Colors.dart';
import 'package:shopping_app/widget/CustomWidget/orderedItem.dart';
import 'package:shopping_app/widget/support_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DisplayAllOrder extends StatelessWidget {
  String orderId;
  DisplayAllOrder({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    return Scaffold(
      backgroundColor: AllColor.mainBGColor,
      appBar: AppBar(
        backgroundColor: AllColor.mainBGColor,
        elevation: 0,
        title: Text("${orderId.substring(0, 7)}..."),
      ),
      body: FutureBuilder(
        future: _fetchOrderItemsWithProduct(orderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No orders found.'));
          }

          final items = snapshot.data!;

          return  ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final product = item['products'];

              return OrderedItem(
                imageUrl: product['image_url'] ?? '',
                product_name: product['name'] ?? 'Unknown Product',
                date: item['order_date'],
                quantity: (item['quantity'] is int)
                    ? item['quantity']
                    : int.tryParse(item['quantity'].toString()) ?? 1,
                price: (item['price'] is int)
                    ? item['price']
                    : int.tryParse(item['price'].toString()) ?? 0,
                code: 0,
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchOrderItemsWithProduct(
    String orderId,
  ) async {
    final response = await Supabase.instance.client
        .from('order_items')
        .select('*, products:product_id (name, image_url)')
        .eq('order_id', orderId);
    return List<Map<String, dynamic>>.from(response);
  }
}
