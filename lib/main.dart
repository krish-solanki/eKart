import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Initialize Supabase
    await Supabase.initialize(
      url: 'https://hummoctauxhmrealpqks.supabase.co', // ✅ Fixed URL
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh1bW1vY3RhdXhobXJlYWxwcWtzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5NTU4MjUsImV4cCI6MjA2OTUzMTgyNX0.jMC0BGC-GQJBvrm9qBilyDtLMFKK2yiUvDbJn2zIUFk',
    );

    // Check connection by querying a test table (replace 'test_table' with your actual table name)
    final response = await Supabase.instance.client
        .from('user') // 🔁 Replace with your actual table
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
    return const MaterialApp(
      home: Scaffold(body: Center(child: Text('Hello World!!'))),
    );
  }
}
