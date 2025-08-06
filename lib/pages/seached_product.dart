import 'package:flutter/material.dart';
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
      backgroundColor: const Color(0xfff2f2f2),
      appBar: AppBar(
        title: Text("Results for '$searchQuery'"),
        backgroundColor: const Color(0xfff2f2f2),
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
              return ListTile(
                leading: product['image_url'] != null
                    ? Image.network(product['image_url'], width: 50)
                    : const Icon(Icons.image_not_supported),
                title: Text(product['name']),
                subtitle: Text(product['price']),
              );
            },
          );
        },
      ),
    );
  }
}
