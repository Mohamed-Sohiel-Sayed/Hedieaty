// lib/views/pledged_gifts/pledged_gifts_page.dart
import 'package:flutter/material.dart';
import '../../controllers/pledged_gifts_controller.dart';
import '../../models/gift.dart';

class PledgedGiftsPage extends StatelessWidget {
  final PledgedGiftsController _giftController = PledgedGiftsController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Pledged Gifts'),
      ),
      body: FutureBuilder<List<Gift>>(
        future: _giftController.getPledgedGifts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No pledged gifts found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final gift = snapshot.data![index];
                return ListTile(
                  title: Text(gift.name),
                  subtitle: Text('Due Date: ${gift.dueDate}'),
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      // Implement edit functionality
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}