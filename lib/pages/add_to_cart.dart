import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shopping_app/widget/Colors/Colors.dart';
import 'package:shopping_app/widget/Functions/Function.dart';
import 'package:shopping_app/widget/support_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddToCart extends StatefulWidget {
  const AddToCart({super.key});

  @override
  State<AddToCart> createState() => _AddToCartState();
}

class _AddToCartState extends State<AddToCart> {
  late Razorpay _razorpay;
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> cartItems = [];
  Map<String, bool> itemLoading = {};
  bool isLoadingCart = true;
  bool isPaymentLoading = false;
  int totalPrice = 0;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);

    fetchCart();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> fetchCart() async {
    setState(() => isLoadingCart = true);
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase
        .from('cart')
        .select(
          'id, quantity, product_id, product_price , products!cart_product_id_fkey(name, price, image_url, description)',
        )
        .eq('user_id', user.id);

    cartItems = List<Map<String, dynamic>>.from(response as List? ?? []);
    calculateTotalPrice();
    setState(() => isLoadingCart = false);
  }

  void calculateTotalPrice() {
    totalPrice = 0;
    for (var item in cartItems) {
      final product = item['products'] ?? {};
      final price = num.tryParse(product['price']?.toString() ?? "0") ?? 0;
      final quantity = int.tryParse(item['quantity']?.toString() ?? "0") ?? 0;
      totalPrice += (price * quantity).toInt();
    }
  }

  Future<void> updateQuantity(String itemId, int qty, bool isIncrease) async {
    setState(() => itemLoading[itemId] = true);

    final user = supabase.auth.currentUser;
    if (user == null) return;

    final newQty = isIncrease ? qty + 1 : qty - 1;
    if (newQty < 1) {
      setState(() => itemLoading[itemId] = false);
      return;
    }

    await supabase
        .from('cart')
        .update({'quantity': newQty})
        .eq('id', itemId)
        .eq('user_id', user.id);

    final index = cartItems.indexWhere((i) => i['id'].toString() == itemId);
    if (index != -1) {
      cartItems[index]['quantity'] = newQty;
    }

    calculateTotalPrice();
    setState(() => itemLoading[itemId] = false);
  }

  Future<void> deleteItem(String itemId) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await supabase.from('cart').delete().match({
      'id': itemId,
      'user_id': user.id,
    });
    cartItems.removeWhere((item) => item['id'].toString() == itemId);
    calculateTotalPrice();
    setState(() {});
    CommonFunctions.printScaffoldMessage(context, 'Item removed from cart', 0);
  }

  // Razorpay Payment
  Future<void> startRazorpayPayment() async {
    if (cartItems.isEmpty || totalPrice == 0) {
      CommonFunctions.printScaffoldMessage(context, "Cart is empty!", 1);
      return;
    }

    final user = supabase.auth.currentUser;
    if (user == null) return;

    setState(() => isPaymentLoading = true);

    var options = {
      'key': 'rzp_test_D89mOflBbBSKZi',
      'amount': totalPrice * 100,
      'currency': 'INR',
      'name': 'My Shopping App',
      'description': 'Order Payment',
      'prefill': {
        'contact': user.userMetadata?['phone'] ?? '9316659446',
        'email': user.email ?? 'test@example.com',
      },
      'theme': {'color': '#0F62FE'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      setState(() => isPaymentLoading = false);
      CommonFunctions.printScaffoldMessage(context, 'Error: $e', 1);
    }
  }

  Future<void> _onPaymentSuccess(PaymentSuccessResponse response) async {
    try {
      setState(() => isPaymentLoading = true);

      final user = supabase.auth.currentUser!;
      final userName = user.userMetadata?['name']?.toString() ?? '';
      final now = DateTime.now();
      final dateString =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      if (userName.isEmpty) {
        CommonFunctions.printScaffoldMessage(
          context,
          'Please update your profile with a name before placing an order.',
          1,
        );
        return;
      }

      final orderResponse = await supabase
          .from('orders')
          .insert({
            'user_id': user.id,
            'total_price': totalPrice,
            'status': 'Pending',
            'name': userName,
            'email_id': user.email,
            'payment_id': response.paymentId,
          })
          .select()
          .single();

      final orderId = orderResponse['id'];
      final orderItems = cartItems.map((item) {
        return {
          'order_id': orderId,
          'product_id': item['product_id'],
          'quantity': item['quantity'],
          'price': item['product_price'],
          'order_date': dateString,
        };
      }).toList();

      await supabase.from('order_items').insert(orderItems);
      await supabase.from('cart').delete().match({'user_id': user.id});

      setState(() {
        cartItems.clear();
        totalPrice = 0;
        isPaymentLoading = false;
      });

      CommonFunctions.printScaffoldMessage(
        context,
        '✅ Payment Successful! Order placed.',
        0,
      );
    } catch (error) {
      setState(() => isPaymentLoading = false);
      CommonFunctions.printScaffoldMessage(
        context,
        '❌ Failed to place order: $error',
        1,
      );
    }
  }

  void _onPaymentError(PaymentFailureResponse response) {
    setState(() => isPaymentLoading = false);
    CommonFunctions.printScaffoldMessage(
      context,
      'Payment Failed: ${response.message}',
      1,
    );
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    setState(() => isPaymentLoading = false);
    CommonFunctions.printScaffoldMessage(
      context,
      'External Wallet: ${response.walletName}',
      0,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingCart) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (cartItems.isEmpty) {
      return const Scaffold(body: Center(child: Text('Your cart is empty')));
    }

    return Scaffold(
      backgroundColor: AllColor.mainBGColor,
      appBar: AppBar(
        title: const Text('Add to Cart'),
        backgroundColor: AllColor.mainBGColor,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(25),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    final product = item['products'] ?? {};
                    final price =
                        num.tryParse(product['price']?.toString() ?? "0") ?? 0;
                    final quantity =
                        int.tryParse(item['quantity']?.toString() ?? "0") ?? 0;
                    final itemId = item['id'].toString();

                    return Container(
                      height: 200,
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                height: 120,
                                width: 120,
                                child: Image.network(
                                  product['image_url'] ?? '',
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product['name'] ?? '',
                                      style: AppWidget.titleFont(),
                                    ),
                                    Text(
                                      CommonFunctions.getShortDescription(
                                        product['description'],
                                      ),
                                      style: AppWidget.descriptionFont1(),
                                    ),
                                    Row(
                                      children: [
                                        const Text('₹'),
                                        Text(
                                          "${price * quantity}",
                                          style: AppWidget.pricrFont(),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Quantity Box
                              Container(
                                height: 30,
                                width: 110,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AllColor.orangeBGColor,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    GestureDetector(
                                      onTap: itemLoading[itemId] == true
                                          ? null
                                          : () => updateQuantity(
                                              itemId,
                                              quantity,
                                              false,
                                            ),
                                      child: const Icon(Icons.remove),
                                    ),
                                    itemLoading[itemId] == true
                                        ? const SizedBox(
                                            height: 15,
                                            width: 15,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(' $quantity '),
                                    GestureDetector(
                                      onTap: itemLoading[itemId] == true
                                          ? null
                                          : () => updateQuantity(
                                              itemId,
                                              quantity,
                                              true,
                                            ),
                                      child: const Icon(Icons.add),
                                    ),
                                  ],
                                ),
                              ),

                              // Remove Button
                              GestureDetector(
                                onTap: () => deleteItem(itemId),
                                child: Container(
                                  height: 30,
                                  width: 110,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AllColor.orangeBGColor,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  child: const Center(child: Text('Remove')),
                                ),
                              ),

                              // Wishlist Button
                              Container(
                                height: 30,
                                width: 110,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AllColor.whiteColor,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Wishlist',
                                    style: TextStyle(
                                      color: AllColor.whiteColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              GestureDetector(
                onTap: isPaymentLoading ? null : startRazorpayPayment,
                child: Container(
                  height: 60,
                  margin: const EdgeInsets.only(
                    right: 10,
                    left: 10,
                    bottom: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isPaymentLoading ? Colors.grey : AllColor.greenColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: isPaymentLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.shopping_cart_checkout,
                                color: Colors.white,
                                size: 30,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '₹$totalPrice',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
          if (isPaymentLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
