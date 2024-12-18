import 'package:flutter/material.dart';
import '../../../models/event.dart';

class EventListItem extends StatelessWidget {
  final Event event;

  EventListItem({required this.event});

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
            onPressed: () {
              // Navigate to edit event page
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              // Delete event
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