import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../controllers/gift_controller.dart';
import '../../models/gift.dart';
import '../../services/auth_service.dart';
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
  bool _isCurrentUser = false;
  File? _image;
  Future<Gift>? _giftFuture;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.gift.name);
    _descriptionController =
        TextEditingController(text: widget.gift.description);
    _categoryController = TextEditingController(text: widget.gift.category);
    _priceController =
        TextEditingController(text: widget.gift.price.toString());

    firebase_auth.User? currentUserFirebase =
    _authService.getCurrentUser();
    if (currentUserFirebase != null) {
      _isCurrentUser = currentUserFirebase.uid == widget.userId;
    }
    _fetchGift();
  }

  void _fetchGift() {
    setState(() {
      _giftFuture = _controller.getAllGifts(widget.userId, widget.gift.eventId)
          .then((gifts) => gifts.firstWhere((g) => g.id == widget.gift.id, orElse: () => widget.gift));
    });
  }

  Future<void> _pickImage() async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _pledgeGift() async {
    try {
      await _controller.pledgeGift(widget.gift.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gift pledged successfully!')),
      );
      _fetchGift(); // Refresh the gift details
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gift Details'),
      ),
      body: FutureBuilder<Gift>(
        future: _giftFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CustomLoadingIndicator());
          } else if (snapshot.hasError) {
            return Center(child: CustomText(text: 'Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: CustomText(text: 'Gift not found'));
          } else {
            Gift gift = snapshot.data!;
            bool isPledged = gift.isPledged;
            String? pledgedBy = gift.pledgedBy;

            return SingleChildScrollView(
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
                      enabled: _isCurrentUser && !isPledged,
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
                      enabled: _isCurrentUser && !isPledged,
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
                      enabled: _isCurrentUser && !isPledged,
                    ),
                    AuthTextField(
                      controller: _priceController,
                      labelText: 'Price',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                      enabled: _isCurrentUser && !isPledged,
                    ),
                    SizedBox(height: 20),
                    if (_isCurrentUser) ...[
                      _image == null
                          ? CustomText(text: 'No image selected.')
                          : Image.file(_image!),
                      ElevatedButton(
                        child: Text('Upload Image'),
                        onPressed: _pickImage,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        child: Text('Save'),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            Gift updatedGift = Gift(
                              id: gift.id,
                              name: _nameController.text,
                              description: _descriptionController.text,
                              category: _categoryController.text,
                              price: double.parse(_priceController.text),
                              eventId: gift.eventId,
                              isPublic: gift.isPublic,
                              isPledged: gift.isPledged,
                              status: gift.status,
                              imageUrl: gift.imageUrl,
                              userId: gift.userId,
                              pledgedBy: gift.pledgedBy,
                            );
                            await _controller.updateGift(updatedGift);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Gift updated successfully')),
                            );
                            _fetchGift(); // Refresh the gift details
                          }
                        },
                      ),
                    ],
                    SizedBox(height: 20),
                    // Pledge Button Section
                    if (!isPledged && !_isCurrentUser)
                      Center(
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.card_giftcard),
                          label: Text('Pledge Gift'),
                          onPressed: _pledgeGift,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                        ),
                      )
                    else if (isPledged)
                      Center(
                        child: Text(
                          pledgedBy != null
                              ? 'Pledged by: $pledgedBy'
                              : 'Gift has been pledged.',
                          style: TextStyle(
                              fontSize: 16, color: Colors.grey),
                        ),
                      )
                    else
                      Center(
                        child: Text(
                          'You can only pledge your friends\' gifts.',
                          style: TextStyle(
                              fontSize: 16, color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}