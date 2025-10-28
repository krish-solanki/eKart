import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
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
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> cartItems = [];
  Map<String, bool> itemLoading = {};
  bool isLoadingCart = true;
  int totalPrice = 0;

  @override
  void initState() {
    super.initState();
    fetchCart();
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

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

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
      body: Column(
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
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GestureDetector(
                                  onTap: itemLoading[itemId] == true
                                      ? null
                                      : () => updateQuantity(
                                          itemId,
                                          quantity,
                                          item['product_price'],
                                          user,
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
                                          item['product_price'],
                                          user,
                                          true,
                                        ),
                                  child: const Icon(Icons.add),
                                ),
                              ],
                            ),
                          ),

                          // Remove Button
                          GestureDetector(
                            onTap: () => deleteItem(context, itemId, user),
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
                                style: TextStyle(color: AllColor.whiteColor),
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
          if (cartItems.isNotEmpty)
            GestureDetector(
              onTap: () {
                placeOrder();
              },
              child: Container(
                height: 60,
                margin: const EdgeInsets.only(right: 10, left: 10, bottom: 10),
                decoration: BoxDecoration(
                  color: AllColor.greenColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_checkout,
                        color: AllColor.whiteColor,
                        size: 30,
                      ),
                      SizedBox(width: 5),
                      Text(
                        '₹$totalPrice',
                        style: const TextStyle(
                          color: AllColor.whiteColor,
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
    );
  }

  Future<void> placeOrder() async {
    try {
      final user = supabase.auth.currentUser!;
      final userName = user.userMetadata?['name']?.toString() ?? '';

      final now = DateTime.now();
      final currentDate = DateTime(now.year, now.month, now.day);
      final dateString =
          '${currentDate.year.toString().padLeft(4, '0')}-'
          '${currentDate.month.toString().padLeft(2, '0')}-'
          '${currentDate.day.toString().padLeft(2, '0')}';

      print(dateString);
      final totalPrice = cartItems.fold<int>(
        0,
        (sum, item) =>
            sum + ((item['product_price'] as int) * (item['quantity'] as int)),
      );

      // 2️⃣ Insert into `orders` table
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
            'user_id': supabase.auth.currentUser!.id,
            'total_price': totalPrice,
            'status': 'Pending',
            'name': userName,
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
      await supabase.from('cart').delete().match({
        'user_id': supabase.auth.currentUser!.id,
      });
      setState(() {
        cartItems.clear();
      });

      print('✅ Order placed successfully! Order ID: $orderId');
    } catch (error) {
      print('❌ Failed to place order: $error');
    }
  }

  Future<void> updateQuantity(
    String itemId,
    int qty,
    int productPrice,
    user,
    bool isIncrease,
  ) async {
    setState(() => itemLoading[itemId] = true);

    final newQty = isIncrease ? qty + 1 : qty - 1;
    if (newQty < 1) {
      setState(() => itemLoading[itemId] = false);
      return;
    }

    await supabase
        .from('cart')
        .update({'quantity': newQty, 'total_price': newQty * productPrice})
        .eq('id', itemId)
        .eq('user_id', user.id);

    // Update local cart item and total price
    final index = cartItems.indexWhere(
      (element) => element['id'].toString() == itemId,
    );
    if (index != -1) {
      setState(() {
        cartItems[index]['quantity'] = newQty;
        cartItems[index]['total_price'] = newQty * productPrice;
        itemLoading[itemId] = false;
        calculateTotalPrice();
      });
    }
  }

  // Delete item
  deleteItem(BuildContext context, String itemId, user) {
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Remove from Cart"),
              content: isLoading
                  ? const SizedBox(
                      height: 60,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : const Text("Do you want to remove this item from cart?"),
              actions: isLoading
                  ? []
                  : [
                      TextButton(
                        child: const Text("Cancel"),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      TextButton(
                        child: const Text("Yes"),
                        onPressed: () async {
                          setStateDialog(() => isLoading = true);
                          try {
                            await supabase.from('cart').delete().match({
                              'id': itemId,
                              'user_id': user.id,
                            });
                            cartItems.removeWhere(
                              (element) => element['id'].toString() == itemId,
                            );
                            calculateTotalPrice();
                            Navigator.of(context).pop();
                            setState(() {}); // refresh UI
                            CommonFunctions.printScaffoldMessage(
                              context,
                              'Item removed from cart',
                              0,
                            );
                          } catch (e) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error: $e")),
                            );
                          }
                        },
                      ),
                    ],
            );
          },
        );
      },
    );
  }
}
