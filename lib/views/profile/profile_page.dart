import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../controllers/event_controller.dart';
import '../../controllers/gift_controller.dart';
import '../../models/event.dart';
import '../../models/gift.dart';
import '../../services/auth_service.dart';
import '../pledged_gifts/pledged_gifts_page.dart';
import '../gift_list/gift_list_page.dart';
import '../gift_details/gift_details_page.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  final EventController _eventController = EventController();
  final GiftController _giftController = GiftController();
  late Stream<List<Event>> _eventsStream;
  late Stream<List<Gift>> _giftsStream;
  late firebase_auth.User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _authService.getCurrentUser();
    if (_currentUser != null) {
      _eventsStream = _eventController.getEvents(_currentUser!.uid);
      _giftsStream = _giftController.getGiftsByUser(_currentUser!.uid);
    } else {
      // Handle the case where the user is not signed in
      _eventsStream = Stream.error('User not signed in');
      _giftsStream = Stream.error('User not signed in');
    }
  }

  void _updateProfile() {
    // Implement profile update logic
  }

  void _updateNotificationSettings() {
    // Implement notification settings update logic
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              Navigator.of(context).pushReplacementNamed('/sign_in');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Profile',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ListTile(
                title: Text(_currentUser?.displayName ?? 'No Name'),
                subtitle: Text(_currentUser?.email ?? 'No Email'),
                trailing: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: _updateProfile,
                ),
              ),
              ListTile(
                title: Text('Notification Settings'),
                trailing: IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: _updateNotificationSettings,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'My Events',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              StreamBuilder<List<Event>>(
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
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(events[index].name),
                          subtitle: Text(events[index].date),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => GiftListPage(eventId: events[index].id),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }
                },
              ),
              SizedBox(height: 20),
              Text(
                'My Gifts',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              StreamBuilder<List<Gift>>(
                stream: _giftsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No gifts found'));
                  } else {
                    List<Gift> gifts = snapshot.data!;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: gifts.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(gifts[index].name),
                          subtitle: Text(gifts[index].category),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => GiftDetailsPage(gift: gifts[index]),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PledgedGiftsPage(),
                    ),
                  );
                },
                child: Text('My Pledged Gifts'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}