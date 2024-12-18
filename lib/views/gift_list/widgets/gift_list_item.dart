import 'package:flutter/material.dart';
import '../../../models/gift.dart';
import '../../../controllers/gift_controller.dart';

class GiftListItem extends StatelessWidget {
  final Gift gift;
  final GiftController _controller = GiftController();
  final VoidCallback onEdit;

  GiftListItem({required this.gift, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(gift.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${gift.category} - ${gift.status}'),
          if (gift.isPledged)
            Text(
              'Pledged',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: onEdit,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              await _controller.deleteGift(gift.id);
            },
          ),
        ],
      ),
      onTap: () {
        // Navigate to gift details page
      },
    );
  }
}