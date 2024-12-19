import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../controllers/event_controller.dart';
import '../../controllers/gift_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../models/event.dart';
import '../../models/gift.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../shared/widgets/flashy_bottom_navigation_bar.dart';
import '../../routes.dart';
import '../../shared/widgets/refreshable widget.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  final EventController _eventController = EventController();
  final GiftController _giftController = GiftController();
  final ProfileController _profileController = ProfileController();
  late Stream<List<Event>> _eventsStream;
  late Stream<List<Gift>> _giftsStream;
  late firebase_auth.User? _currentUser;
  User? _user;

  @override
  void initState() {
    super.initState();
    _currentUser = _authService.getCurrentUser();
    if (_currentUser != null) {
      _eventsStream = _eventController.getEvents(_currentUser!.uid);
      _giftsStream = _giftController.getGiftsByUser(_currentUser!.uid);
      _fetchUserProfile();
    } else {
      // Handle the case where the user is not signed in
      _eventsStream = Stream.error('User not signed in');
      _giftsStream = Stream.error('User not signed in');
    }
  }

  Future<void> _fetchUserProfile() async {
    User? user = await _profileController.getUser(_currentUser!.uid);
    setState(() {
      _user = user;
    });
  }

  Future<void> _refresh() async {
    // Simulate a network call or data refresh
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      // Refresh the state of the widget
      _fetchUserProfile();
    });
  }

  void _updateProfile() {
    // Implement profile update logic
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController nameController = TextEditingController(text: _user?.name);
        TextEditingController emailController = TextEditingController(text: _user?.email);
        return AlertDialog(
          title: Text('Update Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (_user != null) {
                  User updatedUser = _user!.copyWith(
                    name: nameController.text,
                    email: emailController.text,
                  );
                  await _profileController.updateUser(updatedUser);
                  setState(() {
                    _user = updatedUser;
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
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
              Navigator.of(context).pushReplacementNamed(AppRoutes.signIn);
            },
          ),
        ],
      ),
      body: RefreshableWidget(
        onRefresh: _refresh,
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
                title: Text(_user?.name ?? 'No Name'),
                subtitle: Text(_user?.email ?? 'No Email'),
                trailing: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: _updateProfile,
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
                            Navigator.of(context).pushNamed(
                              AppRoutes.giftList,
                              arguments: {'eventId': events[index].id, 'userId': _currentUser!.uid},
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
                            Navigator.of(context).pushNamed(
                              AppRoutes.giftDetails,
                              arguments: {'gift': gifts[index], 'userId': _currentUser!.uid},
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
                  Navigator.of(context).pushNamed(AppRoutes.myPledgedGifts);
                },
                child: const Text('My Pledged Gifts'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: FlashyBottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pushReplacementNamed(AppRoutes.home);
          } else if (index == 1) {
            if (_currentUser != null) {
              Navigator.of(context).pushReplacementNamed(
                AppRoutes.eventList,
                arguments: _currentUser!.uid,
              );
            }
          }
        },
      ),
    );
  }
}