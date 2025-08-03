import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    fetchProduct();
  }

  Future<void> fetchProduct() async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('products')
        .select()
        .eq('id', widget.id)
        .maybeSingle(); // get a single product
    debugPrint('Product Responce is ${response}');

    if (response != null) {
      setState(() {
        product = response;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFfef5f1),
        body: product == null
            ? SingleChildScrollView(
                child: const Center(child: CircularProgressIndicator()),
              )
            : Container(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 20),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(Icons.arrow_back_ios_new_outlined),
                          ),
                        ),
                        Center(
                          child: product!['image_url'] != null
                              ? Container(
                                  margin: EdgeInsets.only(top: 0),
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
                        padding: const EdgeInsets.only(
                          top: 20,
                          left: 20,
                          right: 20,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                            Text(
                              'Details',
                              style: AppWidget.semiboldTetField(),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              product!['description'] ?? 'No description',
                              style: const TextStyle(fontSize: 15),
                            ),
                            const Spacer(),
                            Container(
                              margin: EdgeInsets.only(bottom: 25),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFfd6f3e),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              width: MediaQuery.of(context).size.width,
                              child: const Center(
                                child: Text(
                                  'Buy Now',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
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
      ),
    );
  }
}
