// lib/views/gift_list/gift_list_page.dart
import 'package:flutter/material.dart';
import '../../controllers/gift_controller.dart';
import '../../models/gift.dart';
import '../gift_details/gift_details_page.dart';

class GiftListPage extends StatelessWidget {
  final String eventId;
  final GiftController _giftController = GiftController();

  GiftListPage({required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gifts'),
      ),
      body: FutureBuilder<List<Gift>>(
        future: _giftController.getGifts(eventId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No gifts found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final gift = snapshot.data![index];
                return ListTile(
                  title: Text(gift.name),
                  subtitle: Text('Category: ${gift.category}, Status: ${gift.status}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GiftDetailsPage(gift: gift),
                      ),
                    );
                  },
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _giftController.deleteGift(gift.id);
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GiftDetailsPage(gift: null)),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Add Gift',
      ),
    );
  }
}