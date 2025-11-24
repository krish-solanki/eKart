import 'package:flutter/material.dart';
import 'package:shopping_app/pages/product_detail.dart';
import 'package:shopping_app/pages/seached_product.dart';
import 'package:shopping_app/widget/Colors/Colors.dart';
import 'package:shopping_app/widget/CustomWidget/product.dart';
import 'package:shopping_app/widget/support_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  List<Map<String, dynamic>> products = [];
  bool isLoadingProducts = false; // ✅ fixed nullable issue
  late TabController _tabController;

  final List<String> category = ['All', 'Headphones', 'Laptop', 'Watch', 'TV'];
  final TextEditingController searchController = TextEditingController();

  String? name, imageUrl;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: category.length, vsync: this);
    loadUserData();
    loadProducts();
  }

  Future<void> loadUserData() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user != null && user.userMetadata != null) {
      final metadata = user.userMetadata!;
      setState(() {
        name = metadata['name']?.toString();
        imageUrl = metadata['image_url']?.toString();
      });
    }
  }

  Future<void> loadProducts() async {
    setState(() => isLoadingProducts = true);
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.from('products').select();

      setState(() {
        products = List<Map<String, dynamic>>.from(response);
        isLoadingProducts = false;
      });
    } catch (e) {
      setState(() => isLoadingProducts = false);
      debugPrint('Error fetching products: $e');
    }
  }

  void handleSearch(String query) {
    if (query.trim().isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SearchResultPage(searchQuery: query)),
    ).then((_) {
      if (mounted) {
        searchController.clear();
        FocusScope.of(context).unfocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔍 Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: searchController,
                onSubmitted: handleSearch,
                decoration: InputDecoration(
                  hintText: 'Search for products',
                  hintStyle: AppWidget.searchBarFont(),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AllColor.blackColor,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 🏷️ Category Tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AllColor.whiteColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                padding: const EdgeInsets.all(5),
                indicator: BoxDecoration(
                  color: AllColor.orangeBGColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                labelColor: AllColor.whiteColor,
                unselectedLabelColor: AllColor.blackColor,
                tabs: category.map((cat) => Tab(text: cat)).toList(),
              ),
            ),

            const SizedBox(height: 10),

            // 🧩 Tab Views
            Expanded(
              child: isLoadingProducts
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: category.map((cat) {
                        List<Map<String, dynamic>> filteredProducts;

                        if (cat == "All") {
                          filteredProducts = products;
                        } else {
                          filteredProducts = products
                              .where(
                                (p) =>
                                    (p['category']?.toString().toLowerCase() ??
                                        '') ==
                                    cat.toLowerCase(),
                              )
                              .toList();
                        }

                        if (filteredProducts.isEmpty) {
                          return Center(child: Text("No $cat Found"));
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: ProductCard(
                                imagePath:
                                    product['image_url'] ?? 'images/TV.png',
                                title: product['name'] ?? 'No Title',
                                price: product['price']?.toString() ?? '0',
                                productId: product['id'].toString(),
                                description:
                                    product['description']?.toString() ?? '',
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}
