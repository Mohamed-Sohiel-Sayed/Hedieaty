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
  String _sortCriteria = 'name';

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

  List<Event> _sortEvents(List<Event> events) {
    switch (_sortCriteria) {
      case 'name':
        events.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'date':
        events.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'status':
        events.sort((a, b) => _getStatus(a).compareTo(_getStatus(b)));
        break;
    }
    return events;
  }

  String _getStatus(Event event) {
    DateTime eventDate = DateTime.parse(event.date);
    DateTime now = DateTime.now();
    if (eventDate.isBefore(now)) {
      return 'Past';
    } else if (eventDate.isAfter(now)) {
      return 'Upcoming';
    } else {
      return 'Current';
    }
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: _sortCriteria,
              onChanged: (String? newValue) {
                setState(() {
                  _sortCriteria = newValue!;
                });
              },
              items: <String>['name', 'date', 'status']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text('Sort by $value'),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Event>>(
              stream: _eventsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No events found'));
                } else {
                  List<Event> events = _sortEvents(snapshot.data!);
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
          ),
        ],
      ),
    );
  }
}