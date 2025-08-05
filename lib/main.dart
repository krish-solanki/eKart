import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:shopping_app/Admin/add_product.dart';
import 'package:shopping_app/Admin/manage_all_orders.dart';
import 'package:shopping_app/pages/bottom_nav.dart';
import 'package:shopping_app/pages/home.dart';
import 'package:shopping_app/pages/login.dart';
import 'package:shopping_app/pages/signUp.dart';
import 'package:shopping_app/widget/support_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey =
      'pk_test_51Rs2oTRvBOOvyb45f6E424Td1UiHbqUA1GoLlpAWTX4fhUzYYPey2PhMExlblzIdtfWOaO88vo5m1EHv59PJYwWu00yBIXyZiV'; // ✅ replace with your test key

  try {
    // Initialize Supabase
    await Supabase.initialize(
      url: 'https://hummoctauxhmrealpqks.supabase.co', // ✅ Fixed URL
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh1bW1vY3RhdXhobXJlYWxwcWtzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5NTU4MjUsImV4cCI6MjA2OTUzMTgyNX0.jMC0BGC-GQJBvrm9qBilyDtLMFKK2yiUvDbJn2zIUFk',
    );

    final response = await Supabase.instance.client
        .from('admin') // 🔁 Replace with your actual table
        .select()
        .limit(1);

    debugPrint('✅ Supabase connection successful: $response');
  } catch (error) {
    debugPrint('❌ Supabase connection failed: $error');
  }

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    return MaterialApp(
      home: session != null ? const Bottomnav() : const Login(),
    );
  }
}
