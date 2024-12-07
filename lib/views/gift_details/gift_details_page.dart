// lib/views/gift_details/gift_details_page.dart
import 'package:flutter/material.dart';
import '../../controllers/gift_controller.dart';
import '../../models/event.dart';
import '../../models/gift.dart';

class GiftDetailsPage extends StatelessWidget {
  final Gift? gift;
  final EventModel? event;
  final GiftController _giftController = GiftController();

  GiftDetailsPage({this.gift, this.event});

  @override
  Widget build(BuildContext context) {
    final _nameController = TextEditingController(text: gift?.name ?? '');
    final _descriptionController = TextEditingController(text: gift?.description ?? '');
    final _categoryController = TextEditingController(text: gift?.category ?? '');
    final _priceController = TextEditingController(text: gift?.price?.toString() ?? '');
    bool _isPledged = gift?.status == 'pledged';

    return Scaffold(
      appBar: AppBar(
        title: Text(gift == null ? 'Add Gift' : 'Edit Gift'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(labelText: 'Category'),
            ),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            SwitchListTile(
              title: Text('Pledged'),
              value: _isPledged,
              onChanged: gift == null || gift!.status != 'pledged'
                  ? (value) {
                _isPledged = value;
              }
                  : null,
            ),
            ElevatedButton(
              onPressed: () {
                if (gift == null) {
                  _giftController.addGift(
                    _nameController.text,
                    _descriptionController.text,
                    _categoryController.text,
                    double.parse(_priceController.text),
                    _isPledged ? 'pledged' : 'available',
                  );
                } else {
                  _giftController.updateGift(
                    gift!.id,
                    _nameController.text,
                    _descriptionController.text,
                    _categoryController.text,
                    double.parse(_priceController.text),
                    _isPledged ? 'pledged' : 'available',
                  );
                }
                Navigator.pop(context);
              },
              child: Text(gift == null ? 'Add' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }
}