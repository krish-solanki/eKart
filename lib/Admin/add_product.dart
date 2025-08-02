// admin/add_produc.dart

import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:random_string/random_string.dart';
import 'package:shopping_app/widget/support_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as paths;

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final ImagePicker _picker = ImagePicker();
  TextEditingController nameController = new TextEditingController();
  File? selectedImage;
  String? selectedCategory;
  Future getImage() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      selectedImage = File(image!.path);
    });
  }

  uploadItem() async {
    if (selectedImage != null &&
        nameController != "" &&
        selectedCategory != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      if (selectedImage != null) {
        final supabase = Supabase.instance.client;
        final bucket = supabase.storage.from('product-images');

        final fileBytes = await selectedImage?.readAsBytes();
        final fileExtension = paths.extension(selectedImage!.path);
        final fileName = const Uuid().v4() + fileExtension;
        final mimeType = lookupMimeType(selectedImage!.path);

        try {
          final response = await bucket.uploadBinary(
            'uploads/$fileName',
            fileBytes!,
            fileOptions: FileOptions(contentType: mimeType),
          );

          final publicUrl = bucket.getPublicUrl('uploads/$fileName');
          await insertInTable(publicUrl);
        } on StorageException catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Upload failed: ${e.message}")),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please Fill All Category")));
    }
  }

  insertInTable(String url) async {
    final supabase = Supabase.instance.client;

    debugPrint("Image Url ${url}");
    try {
      final response = await supabase.from('products').insert({
        'name': nameController.text.trim(),
        'category': selectedCategory,
        'image_url': url, // Save image URL
      });
      debugPrint('Responces: ${response}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product Added Sucessfully')),
      );
      await Future.delayed(Duration(milliseconds: 500));
      setState(() {
        selectedCategory = null;
        selectedImage = null;
        nameController.text = "";
      });
    } on PostgrestException catch (e) {
      debugPrint('Insert failed: ${e.message}');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Insert failed: ${e.message}")));
    } catch (e) {
      debugPrint('Unexpected Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An unexpected error occurred")),
      );
    }
  }

  final List<String> categoryItem = ['Watch', 'Laptop', 'TV', 'Headphones'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios_new_outlined),
        ),
        title: Text('Add Product', style: AppWidget.semiboldTetField()),
      ),
      body: Container(
        margin: EdgeInsets.only(left: 20, top: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload Product Image',
              style: AppWidget.lightTextFieldStyle(),
            ),
            SizedBox(height: 20),
            selectedImage == null
                ? GestureDetector(
                    onTap: () => getImage(),
                    child: Center(
                      child: Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 1.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(Icons.camera_alt_outlined),
                      ),
                    ),
                  )
                : Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(20),
                    child: Center(
                      child: Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 1.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(selectedImage!, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  ),
            SizedBox(height: 40),
            Text('Product Name', style: AppWidget.lightTextFieldStyle()),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Color(0xFFececf8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextFormField(
                validator: (value) {
                  if (value == null) {
                    return 'Please enter name';
                  } else if (value.length < 3) {
                    return "Write Atleast 3 charater name";
                  }
                },
                controller: nameController,
                decoration: InputDecoration(border: InputBorder.none),
              ),
            ),
            SizedBox(height: 40),
            Text(
              'Select Product Category',
              style: AppWidget.lightTextFieldStyle(),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Color(0xFFececf8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  items: categoryItem
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text(
                            item,
                            style: AppWidget.semiboldTetField(),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCategory = newValue;
                    });
                  },
                  dropdownColor: Colors.white,
                  hint: const Text('Select Category'),
                  iconSize: 36,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                  value: selectedCategory,
                ),
              ),
            ),
            SizedBox(height: 40),
            GestureDetector(
              onTap: () => uploadItem(),
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
                      'Add Product',
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
          ],
        ),
      ),
    );
  }
}
