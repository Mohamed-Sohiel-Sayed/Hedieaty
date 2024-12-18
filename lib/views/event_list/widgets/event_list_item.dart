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
      subtitle: Text('${event.date} - ${event.location}'),
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
}