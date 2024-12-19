import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../controllers/gift_controller.dart';
import '../../models/gift.dart';
import '../../services/auth_service.dart';
import '../../shared/widgets/refreshable widget.dart';
import '../../shared/widgets/custom_widgets.dart';

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

  Future<void> _refresh() async {
    // Simulate a network call or data refresh
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      // Refresh the state of the widget
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gift Details'),
      ),
      body: RefreshableWidget(
        onRefresh: _refresh,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
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
                  enabled: _isCurrentUser && !_isPledged,
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
                  enabled: _isCurrentUser && !_isPledged,
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
                  enabled: _isCurrentUser && !_isPledged,
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
                  enabled: _isCurrentUser && !_isPledged,
                ),
                SizedBox(height: 20),
                if (_isCurrentUser) ...[
                  _image == null
                      ? CustomText(text: 'No image selected.')
                      : Image.file(_image!),
                  AuthButton(
                    text: 'Upload Image',
                    onPressed: _pickImage,
                  ),
                  SizedBox(height: 20),
                  SwitchListTile(
                    title: CustomText(text: 'Pledged'),
                    value: _isPledged,
                    onChanged: (bool value) {
                      if (!_isPledged) {
                        setState(() {
                          _isPledged = value;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 20),
                  AuthButton(
                    text: 'Save',
                    onPressed: () async {
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
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}