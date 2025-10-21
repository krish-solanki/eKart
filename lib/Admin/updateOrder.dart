import 'package:flutter/material.dart';
import 'package:shopping_app/widget/Colors/Colors.dart';
import 'package:shopping_app/widget/CustomWidget/orderedItem.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpdateOrder extends StatefulWidget {
  final String orderId;
  // optional initial status (we will re-fetch from server on init)
  final String? status;

  const UpdateOrder({super.key, required this.orderId, this.status});

  @override
  State<UpdateOrder> createState() => _UpdateOrderState();
}

class _UpdateOrderState extends State<UpdateOrder> {
  late String? currentStatus; // may be null while fetching
  bool isLoading = false; // prevents double updates
  bool itemsLoading = true;
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    currentStatus = widget.status;
    _initData();
  }

  Future<void> _initData() async {
    // fetch items and fresh order status from DB
    await Future.wait([
      _fetchOrderItemsWithProduct(widget.orderId),
      _fetchOrderStatus(widget.orderId),
    ]);
    setState(() {
      itemsLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final next = nextStatus(currentStatus);

    return Scaffold(
      backgroundColor: AllColor.mainBGColor,
      appBar: AppBar(
        backgroundColor: AllColor.mainBGColor,
        elevation: 0,
        title: Text("${widget.orderId.substring(0, 7)}..."),
      ),

      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          color: AllColor.mainBGColor,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: (next == null || isLoading)
                  ? Colors.grey
                  : AllColor.greenColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: (next == null || isLoading)
                ? null
                : () async {
                    await _handleUpdate();
                  },
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    next == null ? "Order Completed" : "Move to '$next' Status",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),

      body: itemsLoading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
          ? const Center(child: Text('No orders found.'))
          : Column(
              children: [
                // Optional: show current status on top
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  color: AllColor.mainBGColor,
                  child: Text(
                    "Current Status: ${currentStatus ?? 'Unknown'}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final product = item['products'] ?? {};
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
                        code: 1,
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  // fetch order items (and store into local items list)
  Future<void> _fetchOrderItemsWithProduct(String orderId) async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('order_items')
          .select('*, products:product_id (name, image_url, price)')
          .eq('order_id', orderId);

      debugPrint('Fetched items for order $orderId: $response');

      if (response == null) {
        items = [];
      } else {
        // response might be a List<dynamic>
        final list = List<Map<String, dynamic>>.from(response as List);
        items = list;
      }
    } catch (e, st) {
      debugPrint('Error fetching items: $e\n$st');
      items = [];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch order items: $e')),
      );
    }
  }

  // fetch current order status from 'orders' table
  Future<void> _fetchOrderStatus(String orderId) async {
    try {
      final supabase = Supabase.instance.client;
      final resp = await supabase
          .from('orders')
          .select('status')
          .eq('id', orderId)
          .maybeSingle(); // maybeSingle returns null if not found

      debugPrint('Fetched order status for $orderId: $resp');

      if (resp == null) {
        // no order found — keep existing status or null
        return;
      }

      // resp may be Map<String, dynamic> with 'status' key
      if (resp is Map && resp.containsKey('status')) {
        setState(() {
          currentStatus = resp['status']?.toString();
        });
      }
    } catch (e, st) {
      debugPrint('Error fetching order status: $e\n$st');
      // ignore; currentStatus remains as previously passed
    }
  }

  // handle update flow: set loading, perform update, re-fetch status
  Future<void> _handleUpdate() async {
    final next = nextStatus(currentStatus);
    if (next == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Order already delivered.')));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;

      final updateResponse = await supabase
          .from('orders')
          .update({'status': next})
          .eq('id', widget.orderId);

      debugPrint('Update response: $updateResponse');

      await _fetchOrderStatus(widget.orderId);
    } catch (e, st) {
      debugPrint('Error updating order status: $e\n$st');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update status: $e')));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String? nextStatus(String? current) {
    if (current == null) return 'Pending';
    switch (current) {
      case 'Pending':
        return 'Accepted';
      case 'Accepted':
        return 'Dispatch';
      case 'Dispatch':
        return 'On The Way';
      case 'On The Way':
        return 'Delivered';
      case 'Delivered':
        return null;
      default:
        if (current.toLowerCase() == 'dispatched') return 'On The Way';
        return null;
    }
  }
}
