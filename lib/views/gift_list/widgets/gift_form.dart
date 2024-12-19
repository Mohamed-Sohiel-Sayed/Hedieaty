import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../controllers/gift_controller.dart';
import '../../../models/gift.dart';
import '../../../services/auth_service.dart';
import '../../../shared/widgets/custom_widgets.dart';

class GiftForm extends StatefulWidget {
  final Gift? gift;
  final Function(Gift) onSave;
  final String eventId;
  final String userId;

  GiftForm({this.gift, required this.onSave, required this.eventId, required this.userId});

  @override
  _GiftFormState createState() => _GiftFormState();
}

class _GiftFormState extends State<GiftForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  late TextEditingController _priceController;
  final GiftController _controller = GiftController();
  final AuthService _authService = AuthService();
  File? _image;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.gift?.name ?? '');
    _descriptionController = TextEditingController(text: widget.gift?.description ?? '');
    _categoryController = TextEditingController(text: widget.gift?.category ?? '');
    _priceController = TextEditingController(text: widget.gift?.price.toString() ?? '');
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16.0,
          right: 16.0,
          top: 16.0,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AuthTextField(
                controller: _nameController,
                labelText: 'Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              AuthTextField(
                controller: _descriptionController,
                labelText: 'Description',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              AuthTextField(
                controller: _categoryController,
                labelText: 'Category',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category';
                  }
                  return null;
                },
              ),
              AuthTextField(
                controller: _priceController,
                labelText: 'Price',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              _image == null
                  ? CustomText(text: 'No image selected.')
                  : Image.file(_image!),
              AuthButton(
                text: 'Upload Image',
                onPressed: _pickImage,
              ),
              SizedBox(height: 20),
              AuthButton(
                text: widget.gift == null ? 'Add Gift' : 'Update Gift',
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    firebase_auth.User? currentUser = _authService.getCurrentUser();
                    if (currentUser != null) {
                      if (widget.gift == null) {
                        // Add new gift
                        Gift gift = Gift(
                          id: '', // Temporary ID, will be replaced by Firestore
                          name: _nameController.text,
                          description: _descriptionController.text,
                          category: _categoryController.text,
                          price: double.parse(_priceController.text),
                          imageUrl: '', // Handle image upload separately
                          status: 'available',
                          eventId: widget.eventId, // Set the eventId appropriately
                          isPledged: false,
                          userId: widget.userId, // Set the userId appropriately
                        );
                        await _controller.addGift(gift);
                        widget.onSave(gift);
                      } else {
                        // Update existing gift
                        Gift updatedGift = Gift(
                          id: widget.gift!.id,
                          name: _nameController.text,
                          description: _descriptionController.text,
                          category: _categoryController.text,
                          price: double.parse(_priceController.text),
                          imageUrl: widget.gift!.imageUrl, // Handle image upload separately
                          status: widget.gift!.status,
                          eventId: widget.gift!.eventId,
                          isPledged: widget.gift!.isPledged,
                          userId: widget.gift!.userId, // Set the userId appropriately
                        );
                        await _controller.updateGift(updatedGift);
                        widget.onSave(updatedGift);
                      }
                      Navigator.of(context).pop();
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}