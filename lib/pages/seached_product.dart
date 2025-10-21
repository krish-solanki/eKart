import 'package:flutter/material.dart';
import 'package:shopping_app/pages/product_detail.dart';
import 'package:shopping_app/widget/Colors/Colors.dart';
import 'package:shopping_app/widget/CustomWidget/product.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchResultPage extends StatelessWidget {
  final String searchQuery;

  const SearchResultPage({super.key, required this.searchQuery});

  Future<List<Map<String, dynamic>>> fetchSearchResults() async {
    final supabase = Supabase.instance.client;
    final query = searchQuery.toLowerCase();

    final response = await supabase
        .from('products')
        .select()
        .or('name.ilike.%$query%,category.ilike.%$query%');
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllColor.mainBGColor,
      appBar: AppBar(
        title: Text("Results for '$searchQuery'"),
        backgroundColor: AllColor.mainBGColor,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchSearchResults(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No matching products found.'));
          }

          final products = snapshot.data!;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10, right: 18, left: 18),
                child: ProductCard(
                  imagePath: product['image_url'] ?? 'images/TV.png',
                  title: product['name'] ?? '',
                  price: product['price'].toString() ?? '',
                  productId: product['id'].toString() ?? '',
                  description: product['description'].toString() ?? '',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
