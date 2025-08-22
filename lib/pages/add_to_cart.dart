import 'package:flutter/material.dart';
import 'package:shopping_app/widget/support_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddToCart extends StatefulWidget {
  const AddToCart({super.key});

  @override
  State<AddToCart> createState() => _AddToCartState();
}

class _AddToCartState extends State<AddToCart> {
  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),
      appBar: AppBar(
        title: const Text('Add to Cart'),
        backgroundColor: const Color(0xfff2f2f2),
        elevation: 0,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase
            .from('cart')
            .stream(primaryKey: ['id']) // live updates
            .eq('user_id', user!.id) // only current user
            .execute(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Your cart is empty'),
            );
          }

          final cartItems = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final item = cartItems[index];

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Material(
                  elevation: 3,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding:
                        const EdgeInsets.only(left: 20, top: 10, bottom: 10),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item['image_url'] ?? '',
                            fit: BoxFit.cover,
                            width: 80,
                            height: 80,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                "images/TV.png",
                                width: 80,
                                height: 80,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['product_name'] ?? '',
                                style: AppWidget.productName(),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "₹ ${item['price'] ?? ''}",
                                style: AppWidget.orderPageTextStyle(
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                // decrease qty
                              },
                              child: Image.asset(
                                "images/less_qty.png",
                                fit: BoxFit.cover,
                                height: 30,
                                width: 30,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text('${item['quantity'] ?? 1}'),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () {
                                // increase qty
                              },
                              child: Image.asset(
                                "images/inc_qty.png",
                                fit: BoxFit.cover,
                                height: 30,
                                width: 30,
                              ),
                            ),
                          ],
                        )
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
}
