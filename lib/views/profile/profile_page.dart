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
import '../../shared/widgets/custom_widgets.dart';

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
    await Future.delayed(Duration(seconds: 2));
    _fetchUserProfile();
  }

  void _updateProfile() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController nameController =
        TextEditingController(text: _user?.name);
        TextEditingController emailController =
        TextEditingController(text: _user?.email);
        TextEditingController mobileController =
        TextEditingController(text: _user?.mobile);
        return AlertDialog(
          title: CustomText(
            text: 'Update Profile',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AuthTextField(
                  controller: nameController,
                  labelText: 'Name',
                ),
                SizedBox(height: 12),
                AuthTextField(
                  controller: emailController,
                  labelText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 12),
                AuthTextField(
                  controller: mobileController,
                  labelText: 'Mobile',
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          actions: [
            AuthTextButton(
              text: 'Cancel',
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            AuthTextButton(
              text: 'Save',
              onPressed: () async {
                if (_user != null) {
                  User updatedUser = _user!.copyWith(
                    name: nameController.text,
                    email: emailController.text,
                    mobile: mobileController.text,
                  );
                  await _profileController.updateUser(updatedUser);
                  setState(() {
                    _user = updatedUser;
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileHeader() {
    // Check if profilePictureUrl is not null and not empty
    final bool hasProfilePicture = _user?.profilePictureUrl != null &&
        _user!.profilePictureUrl!.isNotEmpty;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // User Avatar
            CircleAvatar(
              radius: 40,
              backgroundColor:
              Theme.of(context).colorScheme.primaryContainer,
              backgroundImage: hasProfilePicture
                  ? NetworkImage(_user!.profilePictureUrl!)
                  : null,
              child: !hasProfilePicture
                  ? Icon(
                Icons.person,
                size: 40,
                color:
                Theme.of(context).colorScheme.onPrimaryContainer,
              )
                  : null,
            ),
            SizedBox(width: 16),
            // User Information
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: _user?.name ?? 'No Name',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(height: 4),
                  CustomText(
                    text: _user?.email ?? 'No Email',
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  SizedBox(height: 4),
                  CustomText(
                    text: _user?.mobile ?? 'No Mobile',
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
            // Edit Button
            IconButton(
              icon: Icon(Icons.edit,
                  color: Theme.of(context).colorScheme.primary),
              onPressed: _updateProfile,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: 'My Events',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface, // Specify color
            ),
            SizedBox(height: 12),
            StreamBuilder<List<Event>>(
              stream: _eventsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CustomLoadingIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                      child: CustomText(
                        text: 'Error: ${snapshot.error}',
                        color: Colors.red, // Highlight errors in red
                      ));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: CustomText(text: 'No events found'));
                } else {
                  List<Event> events = snapshot.data!;
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: events.length,
                    separatorBuilder: (context, index) => Divider(),
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Icon(Icons.event,
                            color: Theme.of(context).colorScheme.primary),
                        title: CustomText(
                            text: events[index].name,
                            fontWeight: FontWeight.bold),
                        subtitle:
                        CustomText(text: events[index].date.toString()),
                        trailing: Icon(Icons.arrow_forward_ios,
                            size: 16, color: Colors.grey),
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            AppRoutes.giftList,
                            arguments: {
                              'eventId': events[index].id,
                              'userId': _currentUser!.uid
                            },
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGiftsSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: 'My Gifts',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface, // Specify color
            ),
            SizedBox(height: 12),
            StreamBuilder<List<Gift>>(
              stream: _giftsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CustomLoadingIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                      child: CustomText(
                        text: 'Error: ${snapshot.error}',
                        color: Colors.red,
                      ));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: CustomText(text: 'No gifts found'));
                } else {
                  List<Gift> gifts = snapshot.data!;
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: gifts.length,
                    separatorBuilder: (context, index) => Divider(),
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Icon(Icons.card_giftcard,
                            color: Theme.of(context).colorScheme.primary),
                        title: CustomText(
                            text: gifts[index].name,
                            fontWeight: FontWeight.bold),
                        subtitle:
                        CustomText(text: gifts[index].category),
                        trailing: Icon(Icons.arrow_forward_ios,
                            size: 16, color: Colors.grey),
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            AppRoutes.giftDetails, // assuming this route exists
                            arguments: gifts[index],
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
            SizedBox(height: 16),
            // Updated Navigation to Pledged Gifts Page
            ElevatedButton.icon(
              icon: Icon(Icons.assignment_turned_in),
              label: Text('View Pledged Gifts'),
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.myPledgedGifts);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: 'Profile',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildProfileHeader(),
              SizedBox(height: 16),
              _buildEventsSection(),
              SizedBox(height: 16),
              _buildGiftsSection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: FlashyBottomNavigationBar(
        currentIndex: 2, // Assuming Profile is index 2
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.of(context).pushReplacementNamed(AppRoutes.home);
              break;
            case 1:
            // Events
              Navigator.of(context).pushReplacementNamed(
                AppRoutes.eventList,
                arguments: _currentUser!.uid,
              );
              break;
            case 2:
            // Profile
              break; // Already on profile
            default:
              break;
          }
        },
      ),
    );
  }
}