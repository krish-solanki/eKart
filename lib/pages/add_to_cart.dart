import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_app/widget/support_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddToCart extends StatefulWidget {
  const AddToCart({super.key});

  @override
  State<AddToCart> createState() => _AddToCartState();
}

class _AddToCartState extends State<AddToCart> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? product;
  Map<String, dynamic>? paymentIntent;

  Future<List<Map<String, dynamic>>> fetchCart() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      return [];
    }

    final response = await supabase
        .from('cart')
        .select(
          'id, quantity, product_id, product_price , products!cart_product_id_fkey(name, price, image_url)',
        )
        .eq('user_id', user.id);

    debugPrint("CART RESPONSE: $response");

    if (response.isEmpty) return [];

    return List<Map<String, dynamic>>.from(response as List);
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;
    int finalPrice = 0, itemPrice = 0, totalPrice = 0;

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
          final cartItemsTotal = snapshot.data ?? [];
          for (var item in cartItemsTotal) {
            final product = item['products'] ?? {};
            final price =
                num.tryParse(product['price']?.toString() ?? "0") ?? 0;
            final quantity =
                int.tryParse(item['quantity']?.toString() ?? "0") ?? 0;
            totalPrice += (price * quantity).toInt();
          }

          final cartItems = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final item = cartItems[index];
              final product = item['products'] ?? {};
              final price =
                  num.tryParse(product['price']?.toString() ?? "0") ?? 0;
              final quantity =
                  int.tryParse(item['quantity']?.toString() ?? "0") ?? 0;
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
                                "₹ ${price * quantity}",
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
                                  item['product_price'] ?? 1,
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
                                  item['product_price'] ?? 1,
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

      bottomNavigationBar: GestureDetector(
        onTap: () {
          makePayment(totalPrice.toString());
        },
        child: Container(
          height: 60,
          margin: EdgeInsets.only(right: 10, left: 10, bottom: 10),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Text(
              'Proceed',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  increaseQuantity(item, qty, product_price, user) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    debugPrint("Product Price: ${product_price}");

    await supabase
        .from('cart')
        .update({
          'quantity': qty + 1,
          'total_price':
              (qty + 1) *
              (int.tryParse(
                product_price.toString().replaceAll(RegExp(r'[^0-9]'), ''),
              )),
        })
        .eq('id', item)
        .eq('user_id', user.id);

    debugPrint("Quantity increased for item ID:");

    Navigator.of(context).pop();
    setState(() {});
  }

  decreaseQuantity(item, qty, product_price, user) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    if (qty > 1) {
      await supabase
          .from('cart')
          .update({
            'quantity': qty - 1,
            'total_price':
                (qty - 1) *
                (int.tryParse(
                  product_price.toString().replaceAll(RegExp(r'[^0-9]'), ''),
                )),
          })
          .eq('id', item)
          .eq('user_id', user.id);
    }
    Navigator.of(context).pop();

    setState(() {});
  }

  Future<void> makePayment(String amount) async {
    debugPrint("makePayment() method entered with amount: $amount");

    try {
      final paymentIntent = await createPaymentIntent(amount, 'INR');

      debugPrint("✅ Payment Intent Created: $paymentIntent");

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          style: ThemeMode.dark,
          merchantDisplayName: "Krish",
        ),
      );

      await displayPaymentSheet(amount);
    } catch (e, stack) {
      debugPrint("❌ makePayment Exception: $e");
      debugPrint("🔍 StackTrace: $stack");

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: Text(e.toString()),
        ),
      );
    }
  }

  Future<void> displayPaymentSheet(String amount) async {
    try {
      await Stripe.instance.presentPaymentSheet();
      insertIntoTable(amount);
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 10),
              Text('Payment Successful'),
            ],
          ),
        ),
      );
      paymentIntent = null;
    } on StripeException catch (e) {
      print('Stripe Exception: $e');
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(content: Text('Payment Cancelled')),
      );
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<Map<String, dynamic>> createPaymentIntent(
    String amount,
    String currency,
  ) async {
    try {
      final body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card',
      };

      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization':
              'Bearer sk_test_51Rs2oTRvBOOvyb45x2O8nMKfT1TU83zWWG71fJCMI7RBsjmNmID3DWCUwjCmMhuf4rNUD141om7uJQ6nzHOvY42T00yjTwljVA', // NEVER use in frontend in production
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      debugPrint('🔁 Stripe Response: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Stripe error: ${response.body}');
      }

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Failed to create payment intent: $e');
    }
  }

  String calculateAmount(String amount) {
    final cleanedAmount = amount.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanedAmount.isEmpty) throw Exception("Invalid amount: $amount");
    final intAmount = int.parse(cleanedAmount);
    return (intAmount * 100).toString(); // Convert to paisa
  }

  Future<void> insertIntoTable(String amount) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    final email = user?.email;

    try {
      final response = await supabase
          .from('orders')
          .insert({
            'email': email,
            'price': amount,
            'user_name': 'krish',
            'status': 'pending',
            'user_id': user?.id,
          })
          .select()
          .single();

      final orderId = response['id'];
      debugPrint("✅ Order created with ID: $orderId");

      try {
        await insertIntoOrdersItem(orderId);
        debugPrint("✅ Finished inserting items into order_items");
      } catch (e, st) {
        debugPrint("❌ insertIntoOrdersItem failed: $e");
        debugPrint("StackTrace: $st");
      }

      // 👇 Also await this
      try {
        await supabase.from('cart').delete().eq('user_id', user!.id);
        debugPrint("✅ Cart cleared for user ID: ${user.id}");
      } catch (e, st) {
        debugPrint("❌ Failed clearing cart: $e");
        debugPrint("StackTrace: $st");
      }
    } on PostgrestException catch (e) {
      debugPrint("❌ Error insert in orders table: ${e.message}");
    }
  }

  Future<void> insertIntoOrdersItem(String orderId) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      debugPrint("🔍 Fetching cart items for user: ${user.id}");

      // ⚠️ Make sure your "cart" table has total_price
      final cartItems = await supabase
          .from('cart')
          .select('product_id, quantity, total_price')
          .eq('user_id', user.id);

      debugPrint("🛒 Cart Items: $cartItems");

      if (cartItems.isEmpty) {
        debugPrint("⚠️ No cart items found");
        return;
      }

      final orderItemsData = cartItems.map((item) {
        return {
          'order_id': orderId,
          'product_id': item['product_id'],
          'quantity': item['quantity'].toString(),
          'price': item['total_price'].toString(),
        };
      }).toList();

      debugPrint("📦 Inserting Order Items: $orderItemsData");

      final response = await supabase
          .from('order_items')
          .insert(orderItemsData);

      debugPrint("✅ Order items inserted: $response");
    } catch (e, st) {
      debugPrint("❌ Error inserting order items: $e");
      debugPrint("StackTrace: $st");
    }
    setState(() {});
  }
}
