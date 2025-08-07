import 'package:flutter/material.dart';
import 'package:shopping_app/pages/category_products.dart';
import 'package:shopping_app/pages/seached_product.dart';
import 'package:shopping_app/widget/support_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<Map<String, dynamic>> categories = [
    {"name": "Headphones", "image": "images/headphone_icon.png"},
    {"name": "Laptop", "image": "images/laptop.png"},
    {"name": "Watch", "image": "images/watch.png"},
    {"name": "TV", "image": "images/TV.png"},
  ];

  String? name, imageUrl;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUserData();
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

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(top: 40.0, left: 20.0, right: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hey ${name?.isNotEmpty == true ? name : 'Guest'}',
                        style: AppWidget.boldTextStyle(),
                      ),
                      Text(
                        'Good Morning',
                        style: AppWidget.lightTextFieldStyle(),
                      ),
                    ],
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: imageUrl != null && imageUrl!.isNotEmpty
                        ? Image.network(
                            imageUrl!,
                            height: 70,
                            width: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'images/boy.jpg',
                                height: 70,
                                width: 70,
                                fit: BoxFit.cover,
                              );
                            },
                          )
                        : Image.asset(
                            'images/boy.jpg',
                            height: 70,
                            width: 70,
                            fit: BoxFit.cover,
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Search bar
              TextField(
                controller: searchController,
                onSubmitted: handleSearch,
                decoration: InputDecoration(
                  hintText: 'Search for products',
                  hintStyle: AppWidget.lightTextFieldStyle(),
                  prefixIcon: const Icon(Icons.search, color: Colors.black),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Categories
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Category', style: AppWidget.semiboldTetField()),
                  const Text(
                    'See all',
                    style: TextStyle(
                      color: Color(0xFFfd6f3e),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              SizedBox(
                height: 130,
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFD6F3E),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          'All',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          return CategoryTile(
                            image: categories[index]["image"],
                            category: categories[index]["name"],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // All Products
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('All Products', style: AppWidget.semiboldTetField()),
                  const Text(
                    'See all',
                    style: TextStyle(
                      color: Color(0xFFfd6f3e),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              SizedBox(
                height: 240,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    productCard(
                      'images/headphone2.png',
                      'Headphone',
                      '250 Rs.',
                    ),
                    productCard('images/watch2.png', 'Smart Watch', '150 Rs.'),
                    productCard('images/laptop2.png', 'Laptop', '1250 Rs.'),
                    productCard('images/TV.png', 'TV', '2250 Rs.'),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget productCard(String imagePath, String title, String price) {
    return Container(
      margin: const EdgeInsets.only(right: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      width: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Image.asset(imagePath, height: 120, fit: BoxFit.cover),
          const SizedBox(height: 10),
          Text(title, style: AppWidget.semiboldTetField()),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                price,
                style: const TextStyle(
                  color: Color(0xFFfd6f3e),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFfd6f3e),
                  borderRadius: BorderRadius.circular(7),
                ),
                padding: const EdgeInsets.all(5),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CategoryTile extends StatelessWidget {
  final String image;
  final String category;

  const CategoryTile({required this.image, required this.category, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryProducts(category: category),
          ),
        );
      },
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(image, height: 50, width: 50, fit: BoxFit.contain),
            const Icon(Icons.arrow_forward),
          ],
        ),
      ),
    );
  }
}
