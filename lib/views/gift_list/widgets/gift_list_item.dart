import 'package:flutter/material.dart';
import '../../../models/gift.dart';
import '../../../controllers/gift_controller.dart';
import '../../../routes.dart';
import '../../../shared/widgets/custom_widgets.dart';

class GiftListItem extends StatelessWidget {
  final Gift gift;
  final GiftController _controller = GiftController();
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  GiftListItem({required this.gift, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: CustomText(text: gift.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(text: '${gift.category} - ${gift.status}'),
          if (gift.isPledged)
            CustomText(
              text: 'Pledged by: ${gift.pledgedBy}',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (!gift.isPublic)
            CustomText(
              text: 'Private',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!gift.isPublic)
            IconButton(
              icon: Icon(Icons.publish),
              tooltip: 'Publish Gift',
              onPressed: () async {
                await _controller.publishGift(gift);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gift published successfully')),
                );
                if (onDelete != null) {
                  onDelete!(); // Refresh the gift list
                }
              },
            ),
          if (onEdit != null)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: onEdit,
            ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              if (!gift.isPledged) {
                bool confirm = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Delete Gift'),
                    content: Text('Are you sure you want to delete this gift?'),
                    actions: [
                      TextButton(
                        child: Text('Cancel'),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                      ElevatedButton(
                        child: Text('Delete'),
                        onPressed: () => Navigator.of(context).pop(true),
                      ),
                    ],
                  ),
                );
                if (confirm) {
                  await _controller.deleteGift(gift.id, gift.isPublic, gift.userId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gift deleted successfully')),
                  );
                  if (onDelete != null) {
                    onDelete!(); // Refresh the gift list
                  }
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Cannot delete a pledged gift')),
                );
              }
            },
          ),
        ],
      ),
      onTap: () {
        Navigator.of(context).pushNamed(
          AppRoutes.giftDetails,
          arguments: {'gift': gift, 'userId': gift.userId},
        ).then((_) {
          if (onDelete != null) {
            onDelete!(); // Refresh the gift list after returning
          }
        });
      },
    );
  }
}