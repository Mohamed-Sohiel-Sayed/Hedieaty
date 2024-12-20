import 'package:flutter/material.dart';
import '../../../models/gift.dart';
import '../../../controllers/gift_controller.dart';
import '../../../routes.dart';
import '../../../shared/widgets/custom_widgets.dart';
import '../../../models/user.dart';

class GiftListItem extends StatelessWidget {
  final Gift gift;
  final GiftController _controller = GiftController();
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  GiftListItem({required this.gift, this.onEdit, this.onDelete});

  /// Fetches the name of the user who pledged the gift.
  Future<String> _getPledgedByName(String userId) async {
    User? user = await _controller.fetchUser(userId);
    return user?.name ?? 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: CustomText(text: gift.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(text: '${gift.category} - ${gift.status}'),
          if (gift.isPledged)
            gift.pledgedBy != null
                ? FutureBuilder<String>(
              future: _getPledgedByName(gift.pledgedBy!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CustomText(
                    text: 'Pledged by: Loading...',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                } else if (snapshot.hasError) {
                  return CustomText(
                    text: 'Pledged by: Error',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                } else {
                  return CustomText(
                    text: 'Pledged by: ${snapshot.data}',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }
              },
            )
                : CustomText(
              text: 'Pledged by: Unknown',
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