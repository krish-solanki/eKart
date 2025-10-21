import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:shopping_app/widget/Colors/Colors.dart';
import 'package:shopping_app/widget/Functions/Function.dart';
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
  TextEditingController priceController = new TextEditingController();
  TextEditingController descriptionController = new TextEditingController();

  File? selectedImage;
  String? selectedCategory;
  Future getImage() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      selectedImage = File(image!.path);
    });
  }

  uploadItem() async {
    if (selectedImage == null ||
        nameController.text.trim().isEmpty ||
        priceController.text.trim().isEmpty ||
        selectedCategory == null ||
        descriptionController.text.trim().isEmpty) {
      CommonFunctions.printScaffoldMessage(
        context,
        'Please Fill All Fields',
        1,
      );
      return;
    }

    // Show loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

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
      Navigator.of(context).pop(); // Close loader
      CommonFunctions.printScaffoldMessage(
        context,
        'Product Image Upload Faild',
        1,
      );
    } catch (e) {
      Navigator.of(context).pop(); // Close loader
      CommonFunctions.printScaffoldMessage(context, 'Unexcepted Error', 1);
    }
  }

  insertInTable(String url) async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase.from('products').insert({
        'name': nameController.text,
        'category': selectedCategory.toString().toLowerCase(),
        'image_url': url,
        'price': priceController.text.trim(),
        'description': descriptionController.text,
        'special': null,
      });
      setState(() {
        selectedCategory = null;
        selectedImage = null;
        nameController.clear();
        priceController.clear();
        descriptionController.clear();
        Navigator.of(context).pop();
      });
      CommonFunctions.printScaffoldMessage(
        context,
        'Product Added Successfully',
        0,
      );

      await Future.delayed(Duration(milliseconds: 500));
    } on PostgrestException catch (e) {
      Navigator.of(context).pop(); // ✅ Close loader
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Insert failed: ${e.message}")));
      CommonFunctions.printScaffoldMessage(
        context,
        'Insetion faild ${e.message}',
        1,
      );
    } catch (e) {
      Navigator.of(context).pop(); // ✅ Close loader
      CommonFunctions.printScaffoldMessage(
        context,
        'Unexpeccted error occured',
        1,
      );
    }
  }

  final List<String> categoryItem = ['Watch', 'Laptop', 'TV', 'Headphones'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Product", style: AppWidget.semiboldTetField()),
        backgroundColor: const Color(0xfff2f2f2),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(left: 20, top: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upload Product Image',
                style: AppWidget.lightTextFieldStyle(),
              ),
              SizedBox(height: 10),
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
                            child: Image.file(
                              selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
              SizedBox(height: 20),
              Text('Product Name', style: AppWidget.lightTextFieldStyle()),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: AllColor.addProductInputFieldBGColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(border: InputBorder.none),
                ),
              ),
              SizedBox(height: 20),
              Text('Product Price', style: AppWidget.lightTextFieldStyle()),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: AllColor.addProductInputFieldBGColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextFormField(
                  controller: priceController,
                  decoration: InputDecoration(border: InputBorder.none),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Product Description',
                style: AppWidget.lightTextFieldStyle(),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: AllColor.addProductInputFieldBGColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextFormField(
                  controller: descriptionController,
                  maxLines: 5,
                  minLines: 3,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(border: InputBorder.none),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Select Product Category',
                style: AppWidget.lightTextFieldStyle(),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: AllColor.addProductInputFieldBGColor,
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
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: AllColor.blackColor,
                    ),
                    value: selectedCategory,
                  ),
                ),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () => uploadItem(),
                child: Center(
                  child: Container(
                    margin: EdgeInsets.only(bottom: 30),
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AllColor.greenColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Center(
                      child: Text(
                        'Add Product',
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
            ],
          ),
        ),
      ),
    );
  }
}
