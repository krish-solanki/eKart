import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopping_app/Admin/add_product.dart';
import 'package:shopping_app/Admin/admin_login.dart';
import 'package:shopping_app/Admin/manage_all_orders.dart';
import 'package:shopping_app/widget/Colors/Colors.dart';
import 'package:shopping_app/widget/support_widget.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  String? email;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllColor.mainBGColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,

        title: Text(
          "Admin Home",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AllColor.mainBGColor,
      ),

      body: Container(
        margin: EdgeInsets.only(left: 20, right: 20),
        child: Column(
          children: [
            Material(
              elevation: 3,
              borderRadius: BorderRadius.circular(10),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddProduct()),
                  );
                },
                child: Container(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  decoration: BoxDecoration(
                    color: AllColor.whiteColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, size: 50),
                      SizedBox(width: 20),
                      Text('Add Product', style: AppWidget.boldTextStyle()),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Material(
              elevation: 3,
              borderRadius: BorderRadius.circular(10),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ManageAllOrders()),
                  );
                },
                child: Container(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  decoration: BoxDecoration(
                    color: AllColor.whiteColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, size: 50),
                      SizedBox(width: 20),
                      Text(
                        'Manage All Orders',
                        style: AppWidget.boldTextStyle(),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),
            Material(
              elevation: 3,
              borderRadius: BorderRadius.circular(10),
              child: GestureDetector(
                child: Container(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  decoration: BoxDecoration(
                    color: AllColor.whiteColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 10),
                        child: Icon(Icons.exit_to_app_outlined, size: 50),
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () {
                          logout();
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: 20),
                          child: Text(
                            'Logout',
                            style: AppWidget.boldTextStyle(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AdminLogin()),
    );
  }

  void getData() async {
    final prefs = await SharedPreferences.getInstance();
    final storedEmail = prefs.getString('username');

    if (storedEmail == null || storedEmail.isEmpty) {
      if (!mounted) return;
      logout();
    } else {
      setState(() {
        email = storedEmail;
      });
    }
  }
}
