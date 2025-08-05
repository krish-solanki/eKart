import 'package:flutter/material.dart';
import 'package:shopping_app/pages/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: ElevatedButton(
            onPressed: () async {
              showDialog(
                context: context,
                barrierDismissible:
                    false, // Prevent user from closing dialog manually
                builder: (context) {
                  return const AlertDialog(
                    content: Row(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 20),
                        Text("Logging out..."),
                      ],
                    ),
                  );
                },
              );

              // Log out from Supabase
              await Supabase.instance.client.auth.signOut();

              // Add a short delay before navigating (e.g., 2 seconds)
              await Future.delayed(const Duration(seconds: 2));

              // Dismiss loader
              Navigator.of(context).pop(); // This removes the dialog

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => Login()),
              );
            },
            child: Text('Logout'),
          ),
        ),
      ),
    );
  }
}
