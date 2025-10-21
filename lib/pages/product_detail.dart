import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_app/widget/Colors/Colors.dart';
import 'package:shopping_app/widget/Functions/Function.dart';
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
        backgroundColor: AllColor.productDetailBGColor,
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
                            color: AllColor.blackColor,
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
                        color: AllColor.whiteColor,
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
                                  color: AllColor.orangeBGColor,
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
                                color: AllColor.orangeBGColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              width: MediaQuery.of(context).size.width,
                              child: const Center(
                                child: Text(
                                  'Add To Cart',
                                  style: TextStyle(
                                    color: AllColor.whiteColor,
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

        CommonFunctions.printScaffoldMessage(context, "Already in cart", 0);
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

        CommonFunctions.printScaffoldMessage(context, 'Added in Cart', 0);
      }
    } catch (e) {
      debugPrint("Error adding to cart: $e");
      Navigator.of(context).pop(); // Close loading dialog

      CommonFunctions.printScaffoldMessage(context, 'Unable to add in cart', 1);
    }
  }
}
