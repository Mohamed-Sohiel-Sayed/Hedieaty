import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../controllers/event_controller.dart';
import '../../models/event.dart';
import '../../services/auth_service.dart';
import '../../shared/widgets/refreshable widget.dart';
import 'widgets/event_list_item.dart';
import 'widgets/event_form.dart';
import '../../shared/widgets/flashy_bottom_navigation_bar.dart';
import '../../routes.dart';

class EventListPage extends StatefulWidget {
  final String userId;

  EventListPage({required this.userId});

  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  final EventController _controller = EventController();
  final AuthService _authService = AuthService();
  late Stream<List<Event>> _eventsStream;
  String _sortCriteria = 'name';
  bool _isCurrentUser = false;

  @override
  void initState() {
    super.initState();
    firebase_auth.User? currentUser = _authService.getCurrentUser();
    if (currentUser != null) {
      _isCurrentUser = currentUser.uid == widget.userId;
      _eventsStream = _controller.getEvents(widget.userId);
    } else {
      // Handle the case where the user is not signed in
      _eventsStream = Stream.error('User not signed in');
    }
  }

  Future<void> _refresh() async {
    // Simulate a network call or data refresh
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      // Refresh the state of the widget
    });
  }

  void _showEventForm({Event? event}) {
    if (_isCurrentUser) {
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
        events.sort((a, b) => a.getStatus().compareTo(b.getStatus()));
        break;
    }
    return events;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event List'),
        actions: _isCurrentUser
            ? [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _showEventForm();
            },
          ),
        ]
            : null,
      ),
      body: RefreshableWidget(
        onRefresh: _refresh,
        child: Column(
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
                          onEdit: _isCurrentUser
                              ? () {
                            _showEventForm(event: events[index]);
                          }
                              : null,
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: FlashyBottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pushReplacementNamed(AppRoutes.home);
          } else if (index == 2) {
            Navigator.of(context).pushReplacementNamed(AppRoutes.profile);
          }
        },
      ),
    );
  }
}