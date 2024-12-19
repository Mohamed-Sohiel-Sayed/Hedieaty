import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../controllers/home_controller.dart';
import '../../controllers/event_controller.dart';
import '../../models/user.dart';
import '../../routes.dart';
import '../../services/auth_service.dart';
import '../../shared/widgets/refreshable widget.dart';
import 'widgets/friend_list_item.dart';
import '../../shared/widgets/flashy_bottom_navigation_bar.dart';
import '../../shared/widgets/custom_widgets.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController _controller = HomeController();
  final EventController _eventController = EventController();
  final AuthService _authService = AuthService();
  late Future<List<User>> _friendsFuture;

  @override
  void initState() {
    super.initState();
    firebase_auth.User? currentUser = _authService.getCurrentUser();
    if (currentUser != null) {
      _friendsFuture = _controller.getFriends(currentUser.uid);
    } else {
      // Handle the case where the user is not signed in
      _friendsFuture = Future.error('User not signed in');
    }
  }

  Future<void> _refresh() async {
    // Simulate a network call or data refresh
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      // Refresh the state of the widget
      firebase_auth.User? currentUser = _authService.getCurrentUser();
      if (currentUser != null) {
        _friendsFuture = _controller.getFriends(currentUser.uid);
      } else {
        // Handle the case where the user is not signed in
        _friendsFuture = Future.error('User not signed in');
      }
    });
  }

  void _addFriend() {
    // Implement add friend logic
  }

  void _searchFriends() {
    // Implement search friends logic
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: _searchFriends,
          ),
          IconButton(
            icon: Icon(Icons.person_add),
            onPressed: _addFriend,
          ),
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
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<User>>(
                future: _friendsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CustomLoadingIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: CustomText(text: 'Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: CustomText(text: 'No friends found'));
                  } else {
                    List<User> friends = snapshot.data!;
                    return ListView.builder(
                      itemCount: friends.length,
                      itemBuilder: (context, index) {
                        return FutureBuilder<int>(
                          future: _eventController.getUpcomingEventsCount(friends[index].id),
                          builder: (context, eventSnapshot) {
                            if (eventSnapshot.connectionState == ConnectionState.waiting) {
                              return FriendListItem(
                                friend: friends[index],
                                subtitle: 'Loading upcoming events...',
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                    AppRoutes.eventList,
                                    arguments: friends[index].id,
                                  );
                                },
                              );
                            } else if (eventSnapshot.hasError) {
                              print('Error loading events for friend ${friends[index].id}: ${eventSnapshot.error}');
                              return FriendListItem(
                                friend: friends[index],
                                subtitle: 'Error loading events',
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                    AppRoutes.eventList,
                                    arguments: friends[index].id,
                                  );
                                },
                              );
                            } else {
                              int upcomingEventsCount = eventSnapshot.data ?? 0;
                              print('Upcoming events for friend ${friends[index].id}: $upcomingEventsCount');
                              return FriendListItem(
                                friend: friends[index],
                                subtitle: upcomingEventsCount > 0
                                    ? 'Upcoming Events: $upcomingEventsCount'
                                    : 'No Upcoming Events',
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                    AppRoutes.eventList,
                                    arguments: friends[index].id,
                                  );
                                },
                              );
                            }
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
      ),
      bottomNavigationBar: FlashyBottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.of(context).pushReplacementNamed(AppRoutes.eventList, arguments: _authService.getCurrentUser()!.uid);
          } else if (index == 2) {
            Navigator.of(context).pushReplacementNamed(AppRoutes.profile);
          }
        },
      ),
    );
  }
}