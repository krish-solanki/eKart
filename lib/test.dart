import 'package:flutter/material.dart';

class DisplayOrders extends StatelessWidget {
  const DisplayOrders({super.key});

  @override
  Widget build(BuildContext context) {
    // Static sample data
    final List<Map<String, dynamic>> orders = [
      {
        'product_name': 'Classic White T-Shirt',
        'price': 499,
        'quantity': 2,
        'order_date': DateTime(2025, 9, 25),
        'image_url': 'images/boy.jpg',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        title: const Text(
          'My Orders',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      backgroundColor: const Color(0xFFF6F7FB),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: ListView.separated(
          itemCount: orders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = orders[index];
            return OrderCard(
              productName: item['product_name'] ?? '',
              price: item['price'] ?? 0,
              quantity: item['quantity'] ?? 1,
              orderDate: item['order_date'] ?? DateTime.now(),
              imageUrl: item['image_url'] ?? '',
            );
          },
        ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final String productName;
  final int price;
  final int quantity;
  final DateTime orderDate;
  final String imageUrl;

  const OrderCard({
    super.key,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.orderDate,
    required this.imageUrl,
  });

  // String formattedDate(DateTime date) {
  //   return ('dd MMM yyyy').format(date);
  // }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼️ Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                imageUrl,
                height: 90,
                width: 90,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 14),

            // 📄 Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    productName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Price & Quantity Row
                  Row(
                    children: [
                      Text(
                        '₹ $price',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F6FF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Qty: $quantity',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Order Date
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Ordered on ${orderDate}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
