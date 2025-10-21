import 'package:flutter/material.dart';
import 'package:shopping_app/pages/category_products.dart';
import 'package:shopping_app/pages/product_detail.dart';
import 'package:shopping_app/pages/seached_product.dart';
import 'package:shopping_app/pages/seeAllProduct.dart';
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
  bool? isLoadingProducts;
  late TabController _tabController;

  final List<String> category = [
    'All',
    'Trending',
    'Popular',
    'Headphones',
    'Laptop',
    'Watch',
    'TV',
  ];

  Future<void> loadProducts() async {
    setState(() => isLoadingProducts = true);
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.from('products').select();
      debugPrint("Fetched Products: $response");

      setState(() {
        products = List<Map<String, dynamic>>.from(response);
        isLoadingProducts = false;
      });
    } catch (e) {
      setState(() => isLoadingProducts = false);
      debugPrint('Error fetching products: $e');
    }
  }

  String? name, imageUrl;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUserData();
    loadProducts();
    _tabController = TabController(length: category.length, vsync: this);
  }

  Future<void> loadUserData() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user != null) {
      final metadata = user.userMetadata;
      if (metadata != null) {
        setState(() {
          name = metadata['name']?.toString();
          imageUrl = metadata['image_url']?.toString();
        });
      }
    }
  }

  void handleSearch(String query) {
    if (query.isEmpty) return;
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
            // Search bar
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
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                ),
              ),
            ),

            SizedBox(height: 10),

            // TabBar
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

            // TabBarView takes remaining space
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: category.map((cat) {
                  if (isLoadingProducts ?? true) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // 🔹 If "All" tab → vertical list (same productCard)
                  if (cat == "All") {
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 0),
                          child: ProductCard(
                            imagePath: product['image_url'] ?? 'images/TV.png',
                            title: product['name'] ?? 'No Title',
                            price: product['price']?.toString() ?? '0',
                            productId: product['id'].toString(),
                            description: product['description'].toString(),
                          ),
                        );
                      },
                    );
                  }

                  if (cat == "Trending") {
                    final headphoneProducts = products
                        .where(
                          (p) =>
                              (p['special']?.toString().toLowerCase().trim() ??
                                  '') ==
                              'trending',
                        )
                        .toList();

                    if (headphoneProducts.isEmpty) {
                      return const Center(
                        child: Text("No Trending Product Found"),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      itemCount: headphoneProducts.length,
                      itemBuilder: (context, index) {
                        final product = headphoneProducts[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 0),
                          child: ProductCard(
                            imagePath: product['image_url'] ?? 'images/TV.png',
                            title: product['name'] ?? '',
                            price: product['price'].toString() ?? '',
                            productId: product['id'].toString() ?? '',
                            description:
                                product['description'].toString() ?? '',
                          ),
                        );
                      },
                    );
                  }

                  if (cat == "Popular") {
                    final headphoneProducts = products
                        .where(
                          (p) =>
                              (p['category']?.toString().toLowerCase().trim() ??
                                  '') ==
                              'popular',
                        )
                        .toList();

                    if (headphoneProducts.isEmpty) {
                      return const Center(
                        child: Text("No Popular Product Found"),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      itemCount: headphoneProducts.length,
                      itemBuilder: (context, index) {
                        final product = headphoneProducts[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 0),
                          child: ProductCard(
                            imagePath: product['image_url'] ?? 'images/TV.png',
                            title: product['name'] ?? '',
                            price: product['price'].toString() ?? '',
                            productId: product['id'].toString() ?? '',
                            description:
                                product['description'].toString() ?? '',
                          ),
                        );
                      },
                    );
                  }

                  if (cat == "Headphones") {
                    final headphoneProducts = products
                        .where(
                          (p) =>
                              (p['category']?.toString().toLowerCase() ?? '') ==
                              'headphones',
                        )
                        .toList();

                    if (headphoneProducts.isEmpty) {
                      return const Center(child: Text("No Headphones Found"));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      itemCount: headphoneProducts.length,
                      itemBuilder: (context, index) {
                        final product = headphoneProducts[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 0),
                          child: ProductCard(
                            imagePath: product['image_url'] ?? 'images/TV.png',
                            title: product['name'] ?? '',
                            price: product['price'].toString() ?? '',
                            productId: product['id'].toString() ?? '',
                            description:
                                product['description'].toString() ?? '',
                          ),
                        );
                      },
                    );
                  }

                  if (cat == "Laptop") {
                    final laptopProducts = products
                        .where(
                          (p) =>
                              (p['category']?.toString().toLowerCase() ?? '') ==
                              'laptop',
                        )
                        .toList();

                    if (laptopProducts.isEmpty) {
                      return const Center(child: Text("No Laptop Found"));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      itemCount: laptopProducts.length,
                      itemBuilder: (context, index) {
                        final product = laptopProducts[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 0),
                          child: ProductCard(
                            imagePath: product['image_url'] ?? 'images/TV.png',
                            title: product['name'] ?? '',
                            price: product['price'].toString() ?? '',
                            productId: product['id'].toString() ?? '',
                            description:
                                product['description'].toString() ?? '',
                          ),
                        );
                      },
                    );
                  }

                  if (cat == "Watch") {
                    final laptopProducts = products
                        .where(
                          (p) =>
                              (p['category']?.toString().toLowerCase() ?? '') ==
                              'watch',
                        )
                        .toList();

                    if (laptopProducts.isEmpty) {
                      return const Center(child: Text("No Watches Found"));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      itemCount: laptopProducts.length,
                      itemBuilder: (context, index) {
                        final product = laptopProducts[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 0),
                          child: ProductCard(
                            imagePath: product['image_url'] ?? 'images/TV.png',
                            title: product['name'] ?? '',
                            price: product['price'].toString() ?? '',
                            productId: product['id'].toString() ?? '',
                            description:
                                product['description'].toString() ?? '',
                          ),
                        );
                      },
                    );
                  }

                  if (cat == "TV") {
                    final laptopProducts = products
                        .where(
                          (p) =>
                              (p['category']?.toString().toLowerCase() ?? '') ==
                              'tv',
                        )
                        .toList();

                    if (laptopProducts.isEmpty) {
                      return const Center(child: Text("No TV Found"));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      itemCount: laptopProducts.length,
                      itemBuilder: (context, index) {
                        final product = laptopProducts[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 0),
                          child: ProductCard(
                            imagePath: product['image_url'] ?? 'images/TV.png',
                            title: product['name'] ?? '',
                            price: product['price'].toString() ?? '',
                            productId: product['id'].toString() ?? '',
                            description:
                                product['description'].toString() ?? '',
                          ),
                        );
                      },
                    );
                  }

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 0),
                        child: ProductCard(
                          imagePath: product['image_url'] ?? 'images/TV.png',
                          title: product['name'] ?? 'No Title',
                          price: product['price']?.toString() ?? '0',
                          productId: product['id'].toString(),
                          description: product['description'].toString(),
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