import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../controllers/gift_controller.dart';
import '../../models/gift.dart';
import '../../services/auth_service.dart';

class GiftDetailsPage extends StatefulWidget {
  final Gift gift;
  final String userId;

  GiftDetailsPage({required this.gift, required this.userId});

  @override
  _GiftDetailsPageState createState() => _GiftDetailsPageState();
}

class _GiftDetailsPageState extends State<GiftDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  late TextEditingController _priceController;
  final GiftController _controller = GiftController();
  final AuthService _authService = AuthService();
  bool _isPledged = false;
  bool _isCurrentUser = false;
  File? _image;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.gift.name);
    _descriptionController = TextEditingController(text: widget.gift.description);
    _categoryController = TextEditingController(text: widget.gift.category);
    _priceController = TextEditingController(text: widget.gift.price.toString());
    _isPledged = widget.gift.isPledged;
    firebase_auth.User? currentUser = _authService.getCurrentUser();
    if (currentUser != null) {
      _isCurrentUser = currentUser.uid == widget.userId;
    }
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Gift Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                  enabled: !_isPledged && _isCurrentUser,
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                  enabled: !_isPledged && _isCurrentUser,
                ),
                TextFormField(
                  controller: _categoryController,
                  decoration: InputDecoration(labelText: 'Category'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a category';
                    }
                    return null;
                  },
                  enabled: !_isPledged && _isCurrentUser,
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    }
                    return null;
                  },
                  enabled: !_isPledged && _isCurrentUser,
                ),
                SizedBox(height: 20),
                _image == null
                    ? Text('No image selected.')
                    : Image.file(_image!),
                ElevatedButton(
                  onPressed: _isPledged || !_isCurrentUser ? null : _pickImage,
                  child: Text('Upload Image'),
                ),
                SizedBox(height: 20),
                SwitchListTile(
                  title: Text('Pledged'),
                  value: _isPledged,
                  onChanged: (bool value) {
                    if (!_isPledged && _isCurrentUser) {
                      setState(() {
                        _isPledged = value;
                      });
                    }
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isPledged || !_isCurrentUser
                      ? null
                      : () async {
                    if (_formKey.currentState!.validate()) {
                      firebase_auth.User? currentUser = _authService.getCurrentUser();
                      if (currentUser != null) {
                        Gift updatedGift = Gift(
                          id: widget.gift.id,
                          name: _nameController.text,
                          description: _descriptionController.text,
                          category: _categoryController.text,
                          price: double.parse(_priceController.text),
                          eventId: widget.gift.eventId,
                          isPledged: _isPledged,
                          status: widget.gift.status,
                          imageUrl: widget.gift.imageUrl,
                          userId: widget.gift.userId,
                        );
                        await _controller.updateGift(updatedGift);
                        Navigator.of(context).pop();
                      }
                    }
                  },
                  child: Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}