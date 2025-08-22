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

  Future<List<Map<String, dynamic>>> fetchCart() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      return [];
    }

    final response = await supabase
        .from('cart')
        .select(
          'id, quantity, product_id, products!cart_product_id_fkey(name, price, image_url)',
        )
        .eq('user_id', user.id);

    debugPrint("CART RESPONSE: $response");

    if (response.isEmpty) return [];

    return List<Map<String, dynamic>>.from(response as List);
  }

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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchCart(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Your cart is empty'));
          }

          final cartItems = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final item = cartItems[index];
              final product = item['products'] ?? {};
              debugPrint("CART ITEM: $item");

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Material(
                  elevation: 3,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            product['image_url'] ?? '',
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
                                product['name'] ?? '',
                                style: AppWidget.productName(),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "${product['price'] ?? ''}",
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
                                decreaseQuantity(
                                  item['id'],
                                  item['quantity'] ?? 1,
                                  user!,
                                );
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
                                increaseQuantity(
                                  item['id'],
                                  item['quantity'] ?? 1,
                                  user!,
                                );
                              },
                              child: Image.asset(
                                "images/inc_qty.png",
                                fit: BoxFit.cover,
                                height: 30,
                                width: 30,
                              ),
                            ),
                          ],
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

  increaseQuantity(item, qty, user) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    await supabase
        .from('cart')
        .update({'quantity': qty + 1})
        .eq('id', item)
        .eq('user_id', user.id);

    Navigator.of(context).pop();
    setState(() {});
  }

  decreaseQuantity(item, qty, user) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    if (qty > 1) {
      await supabase
          .from('cart')
          .update({'quantity': qty - 1})
          .eq('id', item)
          .eq('user_id', user.id);
    }
    Navigator.of(context).pop();

    setState(() {});
  }
}
