//http://localhost:3000

import 'package:flutter/material.dart';
import 'package:shopping_app/pages/home.dart';
import 'package:shopping_app/pages/login.dart';
import 'package:shopping_app/widget/support_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  String email = "", password = "", name = "";
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(child: Image.asset('images/login.png')),
                const SizedBox(height: 20),
                Center(
                  child: Text('Sign Up', style: AppWidget.loginPageHeading()),
                ),
                const SizedBox(height: 30),

                // Name Field
                Text('Name', style: AppWidget.loginPageText()),
                const SizedBox(height: 10),
                TextFormField(
                  controller: nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return "Please enter your name";
                    if (value.length < 3)
                      return "Name must be at least 3 characters";
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Enter Name",
                    filled: true,
                    fillColor: const Color(0xFFF4F5F9),
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

                // Email Field
                Text('Email', style: AppWidget.loginPageText()),
                const SizedBox(height: 10),
                TextFormField(
                  controller: emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return "Please enter your email";
                    if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value))
                      return "Enter a valid email";
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Enter Email",
                    filled: true,
                    fillColor: const Color(0xFFF4F5F9),
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

                // Password Field
                Text('Password', style: AppWidget.loginPageText()),
                const SizedBox(height: 10),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return "Please enter a password";
                    if (value.length < 6)
                      return "Password must be at least 6 characters long";
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Enter Password",
                    filled: true,
                    fillColor: const Color(0xFFF4F5F9),
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

                // Sign Up Button
                GestureDetector(
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      email = emailController.text.trim();
                      password = passwordController.text.trim();
                      name = nameController.text.trim();
                      registration();
                    }
                  },
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Already have an account? Sign In
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: AppWidget.lightTextFieldStyle(),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Login()),
                      ),
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          color: Colors.green[600],
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> registration() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              "Registration Successful! Check Your Mail for Verification link",
              style: TextStyle(fontSize: 12.0),
            ),
          ),
        );
      }
    } on AuthException catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text("Auth Error: ${e.message}"),
        ),
      );
    }
  }
}
