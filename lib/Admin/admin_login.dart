// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopping_app/Admin/admin_home.dart';
import 'package:shopping_app/pages/bottom_nav.dart';
import 'package:shopping_app/widget/Colors/Colors.dart';
import 'package:shopping_app/widget/support_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  String? email, pass;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
          child: Form(
            key: _formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(child: Image.asset('images/login.png')),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    'Admin Sign Up',
                    style: AppWidget.loginPageHeading(),
                  ),
                ),
                const SizedBox(height: 30),

                // --- Name Field ---
                Text('Username', style: AppWidget.loginPageText()),
                const SizedBox(height: 10),
                TextFormField(
                  controller: emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your name";
                    }
                    if (value.length < 3) {
                      return "Name must be at least 3 characters long";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Enter Name",
                    filled: true,
                    fillColor: AllColor.addProductInputFieldBGColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15.0,
                      horizontal: 20.0,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // --- Password Field ---
                Text('Password', style: AppWidget.loginPageText()),
                const SizedBox(height: 10),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter a password";
                    }
                    if (value.length < 6) {
                      return "Password must be at least 6 characters long";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Enter Password",
                    filled: true,
                    fillColor: AllColor.addProductInputFieldBGColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15.0,
                      horizontal: 20.0,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // --- Sign Up Button ---
                GestureDetector(
                  onTap: () {
                    if (_formkey.currentState!.validate()) {
                      loginAdmin();
                    }
                  },
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AllColor.greenColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            color: AllColor.whiteColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> loginAdmin() async {
    final email = emailController.text.trim();
    final pass = passwordController.text.trim();
    final supabase = Supabase.instance.client;

    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AllColor.redColor,
          content: Text('Email and password are required'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await supabase
          .from('admin')
          .select()
          .eq('email', email)
          .eq('password', pass)
          .maybeSingle();

      Navigator.of(context).pop(); // Close loading dialog

      if (response == null) {
        if ((await supabase
                .from('admin')
                .select('email')
                .eq('email', email)
                .maybeSingle()) ==
            null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AllColor.redAccentColor,
              content: const Text('Email not found'),
            ),
          );
        } else {
          // Email exists, but password is incorrect
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.redAccent,
              content: Text('Password was incorrect'),
            ),
          );
        }
      } else {
        saveData();
        // Success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AllColor.greenColor,
            content: Text('Login successful!'),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 500));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AdminHome()),
        );
      }
    } on PostgrestException catch (e) {
      Navigator.of(context).pop();
      debugPrint('Login Faild: ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AllColor.redColor,
          content: Text('Login failed: ${e.message}'),
        ),
      );
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AllColor.redColor,
          content: Text('An unexpected error occurred.'),
        ),
      );
    }
  }

  saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', emailController.text.trim());
  }
}
