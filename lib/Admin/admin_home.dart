import 'package:flutter/material.dart';
import 'package:shopping_app/widget/support_widget.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),
      appBar: AppBar(
        title: Text(
          "Admin Home",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xfff2f2f2),
      ),

      body: Container(
        margin: EdgeInsets.only(left: 20 , right: 20),
        child: Column(
          children: [
            Material(
              elevation: 3,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: EdgeInsets.only(top: 10 , bottom: 10),
                decoration: BoxDecoration(color: Colors.white , borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add , size: 50,),
                    SizedBox(width: 20),
                    Text('Add Product' , style: AppWidget.boldTextStyle(),),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
