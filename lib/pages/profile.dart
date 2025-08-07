import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shopping_app/pages/login.dart';
import 'package:shopping_app/widget/support_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;
  String? imageUrl;
  String bucketName = 'user-images';
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  void loadUserData() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      // Load email
      emailController.text = user.email ?? '';

      // Load username
      final metadata = user.userMetadata;
      if (metadata != null && metadata['name'] != null) {
        userNameController.text = metadata['name'];
      }

      // Load profile image
      if (metadata != null && metadata['image_url'] != null) {
        imageUrl = metadata['image_url'];
      }
      setState(() {});
    }
  }

  Future pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      selectedImage = File(pickedFile.path);
      debugPrint('Image selected: ${pickedFile.path}');
      setState(() {});
    } else {
      debugPrint('No image selected');
    }
  }

  Future uploadImageToSupabase() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      debugPrint('User not logged in');
      return;
    }

    setState(() => isLoading = true); // START LOADING

    String? newImageUrl;
    String? newFilePath;

    try {
      if (selectedImage != null) {
        if (user.userMetadata?['image_path'] != null) {
          final oldPath = user.userMetadata!['image_path'];
          await supabase.storage.from(bucketName).remove([oldPath]);
        }

        newFilePath = '${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';
        await supabase.storage
            .from(bucketName)
            .upload(
              newFilePath,
              selectedImage!,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: false,
              ),
            );

        newImageUrl = supabase.storage
            .from(bucketName)
            .getPublicUrl(newFilePath);
      }

      final newName = userNameController.text.trim();
      Map<String, dynamic> updatedMetadata = {'name': newName};

      if (newImageUrl != null && newFilePath != null) {
        updatedMetadata['image_url'] = newImageUrl;
        updatedMetadata['image_path'] = newFilePath;
      }

      await supabase.auth.updateUser(UserAttributes(data: updatedMetadata));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Profile updated")));

      selectedImage = null;
      loadUserData();
    } catch (e) {
      debugPrint('Upload/update error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isLoading = false); // STOP LOADING
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (!isLoading)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') {
                  handleLogout();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'logout', child: Text('Logout')),
              ],
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: pickImage,
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(80),
                    child: selectedImage != null
                        ? Image.file(
                            selectedImage!,
                            width: 160,
                            height: 160,
                            fit: BoxFit.cover,
                          )
                        : imageUrl != null
                        ? Image.network(
                            imageUrl!,
                            width: 160,
                            height: 160,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            'images/boy.jpg',
                            width: 160,
                            height: 160,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text('Email', style: AppWidget.loginPageText()),
              const SizedBox(height: 10),
              TextFormField(
                controller: emailController,
                readOnly: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF4F5F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 20,
                  ),
                ),
              ),

              const SizedBox(height: 20),
              Text('Name', style: AppWidget.loginPageText()),
              const SizedBox(height: 10),
              TextFormField(
                controller: userNameController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  } else if (value.trim().length < 3) {
                    return 'Name must be at least 3 characters long';
                  }
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
                    vertical: 15,
                    horizontal: 20,
                  ),
                ),
              ),

              const SizedBox(height: 30),
              Center(
                child: isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            uploadImageToSupabase();
                          }
                        },
                        icon: const Icon(Icons.update),
                        label: const Text('Update Profile'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void handleLogout() async {
    setState(() => isLoading = true); // Start loader

    try {
      await supabase.auth.signOut();

      if (mounted) {
        setState(() => isLoading = false); // Stop loader before navigating
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (context) => Login()));
      }
    } catch (e) {
      setState(() => isLoading = false); // Stop loader on error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Logout failed: $e")));
    }
  }
}
