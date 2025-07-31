import 'package:flutter/material.dart';
import 'package:shopping_app/widget/support_widget.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List categories = [
    "images/headphone_icon.png",
    "images/laptop.png",
    "images/watch.png",
    "images/TV.png",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff2f2f2),
      body: Container(
        margin: EdgeInsets.only(top: 40.0, left: 20.0, right: 20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hey, Krish', style: AppWidget.boldTextStyle()),
                    Text(
                      'Good Morning',
                      style: AppWidget.lightTextFieldStyle(),
                    ),
                  ],
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Image.asset(
                    'images/boy.jpg',
                    height: 70,
                    width: 70,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            Container(
              padding: EdgeInsets.only(left: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              width: MediaQuery.of(context).size.width,
              child: TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search for products',
                  hintStyle: AppWidget.lightTextFieldStyle(),
                  prefixIcon: Icon(Icons.search, color: Colors.black),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Category', style: AppWidget.semiboldTetField()),
                Text(
                  'See all',
                  style: TextStyle(
                    color: Color(0xFFfd6f3e),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Container(
                  height: 130,
                  padding: EdgeInsets.all(20),
                  margin: EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Color(0xFFFD6F3E),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'All',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 130,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: categories.length,
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return CategoryTile(image: categories[index]);
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('All Products', style: AppWidget.semiboldTetField()),
                Text(
                  'See all',
                  style: TextStyle(
                    color: Color(0xFFfd6f3e),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Container(
              height: 240,
              child: ListView(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Image.asset(
                          'images/headphone2.png',
                          height: 150,
                          width: 150,
                          fit: BoxFit.cover,
                        ),
                        Text('HeadPhone', style: AppWidget.semiboldTetField()),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              '250 Rs.',
                              style: TextStyle(
                                color: Color(0xFFfd6f3e),
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 40),
                            Container(
                              decoration: BoxDecoration(
                                color: Color(0xFFfd6f3e),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              padding: EdgeInsets.all(5),
                              child: Icon(Icons.add, color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 20, left: 20),
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Image.asset(
                          'images/watch2.png',
                          height: 150,
                          width: 150,
                          fit: BoxFit.cover,
                        ),
                        Text(
                          'Smart Watch',
                          style: AppWidget.semiboldTetField(),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              '150 Rs.',
                              style: TextStyle(
                                color: Color(0xFFfd6f3e),
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 40),
                            Container(
                              decoration: BoxDecoration(
                                color: Color(0xFFfd6f3e),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              padding: EdgeInsets.all(5),
                              child: Icon(Icons.add, color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 20),
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Image.asset(
                          'images/laptop2.png',
                          height: 150,
                          width: 150,
                          fit: BoxFit.cover,
                        ),
                        Text('HeadPhone', style: AppWidget.semiboldTetField()),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              '1250 Rs.',
                              style: TextStyle(
                                color: Color(0xFFfd6f3e),
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 40),
                            Container(
                              decoration: BoxDecoration(
                                color: Color(0xFFfd6f3e),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              padding: EdgeInsets.all(5),
                              child: Icon(Icons.add, color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 20),
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Image.asset(
                          'images/TV.png',
                          height: 150,
                          width: 150,
                          fit: BoxFit.cover,
                        ),
                        Text('TV', style: AppWidget.semiboldTetField()),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              '1250 Rs.',
                              style: TextStyle(
                                color: Color(0xFFfd6f3e),
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 40),
                            Container(
                              decoration: BoxDecoration(
                                color: Color(0xFFfd6f3e),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              padding: EdgeInsets.all(5),
                              child: Icon(Icons.add, color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryTile extends StatelessWidget {
  String image;
  CategoryTile({required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(image, height: 50, width: 50, fit: BoxFit.cover),
          Icon(Icons.arrow_forward),
        ],
      ),
    );
  }
}