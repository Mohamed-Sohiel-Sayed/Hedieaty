import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../controllers/event_controller.dart';
import '../../models/event.dart';
import '../../services/auth_service.dart';
import 'widgets/event_list_item.dart';
import 'widgets/event_form.dart';

class EventListPage extends StatefulWidget {
  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  final EventController _controller = EventController();
  final AuthService _authService = AuthService();
  late Stream<List<Event>> _eventsStream;

  @override
  void initState() {
    super.initState();
    firebase_auth.User? currentUser = _authService.getCurrentUser();
    if (currentUser != null) {
      _eventsStream = _controller.getEvents(currentUser.uid);
    } else {
      // Handle the case where the user is not signed in
      _eventsStream = Stream.error('User not signed in');
    }
  }

  void _showEventForm({Event? event}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return EventForm(
          event: event,
          onSave: (Event savedEvent) {
            setState(() {});
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event List'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _showEventForm();
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Event>>(
        stream: _eventsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No events found'));
          } else {
            List<Event> events = snapshot.data!;
            return ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                return EventListItem(
                  event: events[index],
                  onEdit: () {
                    _showEventForm(event: events[index]);
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}