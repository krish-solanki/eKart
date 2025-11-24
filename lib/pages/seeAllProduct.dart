import 'package:flutter/material.dart';
import 'package:shopping_app/pages/product_detail.dart';
import 'package:shopping_app/widget/Colors/Colors.dart';
import 'package:shopping_app/widget/support_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Seeallproduct extends StatelessWidget {
  const Seeallproduct({super.key});

  Future<List<dynamic>> fetchCategoryProducts() async {
    final supabase = Supabase.instance.client;
    final response = await supabase.from('products').select();
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllColor.mainBGColor,
      appBar: AppBar(
        automaticallyImplyLeading: false, // ✅ removes back button
        backgroundColor: AllColor.mainBGColor,
        elevation: 0,
        centerTitle: true,
        title: Text("All Products", style: AppWidget.semiboldTetField()),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: Supabase.instance.client.from('products').select(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No Products Found'));
          }

          final products = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio:
                  0.68, // ✅ slightly taller cards for better layout
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];

              return Container(
                decoration: BoxDecoration(
                  color: AllColor.whiteColor,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ✅ Adjusted product image
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                      child: product['image_url'] != null
                          ? Image.network(
                              product['image_url'],
                              height: 160,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image, size: 80),
                            )
                          : const Icon(Icons.image_not_supported, size: 80),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        product['name'] ?? 'No Name',
                        style: AppWidget.semiboldTetField(),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "₹${product['price'] ?? '0'}",
                      style: const TextStyle(
                        color: AllColor.orangeBGColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetail(id: product['id']),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: AllColor.orangeBGColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.add,
                          color: AllColor.whiteColor,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
