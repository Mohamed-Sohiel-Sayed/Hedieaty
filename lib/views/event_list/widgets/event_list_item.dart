import 'package:flutter/material.dart';
import '../../../models/event.dart';
import '../../../controllers/event_controller.dart';

class EventListItem extends StatelessWidget {
  final Event event;
  final EventController _controller = EventController();
  final VoidCallback onEdit;

  EventListItem({required this.event, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(event.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${event.date} - ${event.location}'),
          Text(
            'Status: ${event.getStatus()}',
            style: TextStyle(
              color: _getStatusColor(event.getStatus()),
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
              await _controller.deleteEvent(event.id);
            },
          ),
        ],
      ),
      onTap: () {
        // Navigate to event details or gift list page
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