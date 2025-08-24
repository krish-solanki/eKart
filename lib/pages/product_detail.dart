import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_app/widget/support_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductDetail extends StatefulWidget {
  final String id;

  const ProductDetail({super.key, required this.id});

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  Map<String, dynamic>? product;
  Map<String, dynamic>? paymentIntent;
  bool _isLoading = false; // Loader flag

  @override
  void initState() {
    super.initState();
    fetchProduct();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFfef5f1),
        body: product == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          margin: const EdgeInsets.only(left: 20, top: 20),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_outlined,
                            color: Colors.black,
                            size: 28,
                          ),
                        ),
                      ),
                      Center(
                        child: product!['image_url'] != null
                            ? Container(
                                margin: const EdgeInsets.only(top: 30),
                                child: Image.network(
                                  product!['image_url'],
                                  fit: BoxFit.cover,
                                  height: 400,
                                ),
                              )
                            : const Icon(Icons.image_not_supported),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                product!['name'] ?? '',
                                style: AppWidget.boldTextStyle(),
                              ),
                              Text(
                                product!['price'] ?? '',
                                style: const TextStyle(
                                  color: Color(0xFFfd6f3e),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text('Details', style: AppWidget.semiboldTetField()),
                          const SizedBox(height: 10),
                          Text(
                            product!['description'] ?? 'No description',
                            style: const TextStyle(fontSize: 15),
                          ),
                          const Spacer(),
                          GestureDetector(
                            // onTap: () => makePayment(product!['price']),
                            onTap: () => addOrUpdateCart(product!['id'], 1),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 25),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFfd6f3e),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              width: MediaQuery.of(context).size.width,
                              child: const Center(
                                child: Text(
                                  'Add To Cart',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
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
    final userEmail = supabase.auth.currentUser?.email;
    try {
      final response = await supabase.from('orders').insert({
        'email': userEmail,
        'image_url': product!['image_url'],
        'product_id': product!['id'],
        'price': amount,
        'product_name': product!['name'],
        'user_name': 'krish',
        'order': 'pending',
      });

      debugPrint("Responce of order: ${response}");
    } on PostgrestException catch (e) {
      print("Error insert in orders: ${e}");
    }
  }

  Future<void> fetchProduct() async {
    setState(() => _isLoading = true);
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('products')
        .select()
        .eq('id', widget.id)
        .maybeSingle();

    if (mounted) {
      setState(() {
        product = response;
        _isLoading = false;
      });
    }
  }

  Future<void> addOrUpdateCart(String productId, int quantity) async {
    final user = Supabase.instance.client.auth.currentUser;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    if (user == null) {
      debugPrint('User not logged in');
      return;
    }

    setState(() => _isLoading = true); // Start loader

    try {
      final existing = await Supabase.instance.client
          .from('cart')
          .select()
          .eq('user_id', user.id)
          .eq('product_id', productId)
          .maybeSingle();
      debugPrint('Existing cart item: $existing');

      if (existing != null) {
        Navigator.of(context).pop(); // Close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text("Already in cart"),
          ),
        );
      } else {
        // Insert new
        await Supabase.instance.client.from('cart').insert({
          'user_id': user.id,
          'product_id': productId,
          'quantity': quantity,
          'product_name': product!['name'],
          'product_price': product!['price'],
          'total_price':
              quantity *
              (int.tryParse(
                    product!['price'].toString().replaceAll(
                      RegExp(r'[^0-9]'),
                      '',
                    ),
                  ) ??
                  0),
        });
        Navigator.of(context).pop(); // Close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text("Added in cart"),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error adding to cart: $e");
      Navigator.of(context).pop(); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Unable to add to cart"),
        ),
      );
    }
  }
}
