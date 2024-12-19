import 'package:flutter/material.dart';
import '../../../models/event.dart';
import '../../../controllers/event_controller.dart';
import '../../../routes.dart';
import '../../../shared/widgets/custom_widgets.dart';

class EventListItem extends StatelessWidget {
  final Event event;
  final EventController _controller = EventController();
  final VoidCallback? onEdit;

  EventListItem({required this.event, this.onEdit});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: CustomText(text: event.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(text: '${event.date} - ${event.location}'),
          CustomText(
            text: 'Status: ${event.getStatus()}',
            fontWeight: FontWeight.bold,
            style: TextStyle(
              color: _getStatusColor(event.getStatus()),
            ),
          ),
        ],
      ),
      trailing: onEdit != null
          ? Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: onEdit,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              await _controller.deleteEvent(event.id);
            },
          ),
        ],
      )
          : null,
      onTap: () {
        Navigator.of(context).pushNamed(
          AppRoutes.giftList,
          arguments: {'eventId': event.id, 'userId': event.userId},
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Past':
        return Colors.red;
      case 'Current':
        return Colors.orange;
      case 'Upcoming':
        return Colors.green;
      default:
        return Colors.black;
    }
  }
}