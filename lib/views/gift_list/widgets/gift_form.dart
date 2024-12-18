import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../../controllers/gift_controller.dart';
import '../../../models/gift.dart';
import '../../../services/auth_service.dart';

class GiftForm extends StatefulWidget {
  final Gift? gift;
  final Function(Gift) onSave;

  GiftForm({this.gift, required this.onSave});

  @override
  _GiftFormState createState() => _GiftFormState();
}

class _GiftFormState extends State<GiftForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _statusController;
  final GiftController _controller = GiftController();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.gift?.name ?? '');
    _categoryController = TextEditingController(text: widget.gift?.category ?? '');
    _statusController = TextEditingController(text: widget.gift?.status ?? '');
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
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
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
              ),
              TextFormField(
                controller: _statusController,
                decoration: InputDecoration(labelText: 'Status'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a status';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    firebase_auth.User? currentUser = _authService.getCurrentUser();
                    if (currentUser != null) {
                      if (widget.gift == null) {
                        // Add new gift
                        Gift gift = Gift(
                          id: '', // Temporary ID, will be replaced by Firestore
                          name: _nameController.text,
                          category: _categoryController.text,
                          status: _statusController.text,
                          eventId: widget.gift!.eventId,
                          isPledged: false, description: '', price: 0.0, imageUrl: '',
                        );
                        await _controller.addGift(gift);
                        widget.onSave(gift);
                      } else {
                        // Update existing gift
                        Gift updatedGift = Gift(
                          id: widget.gift!.id,
                          name: _nameController.text,
                          category: _categoryController.text,
                          status: _statusController.text,
                          eventId: widget.gift!.eventId,
                          isPledged: widget.gift!.isPledged, description: '', price: 0.0, imageUrl: '',
                        );
                        await _controller.updateGift(updatedGift);
                        widget.onSave(updatedGift);
                      }
                      Navigator.of(context).pop();
                    }
                  }
                },
                child: Text(widget.gift == null ? 'Add Gift' : 'Update Gift'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}