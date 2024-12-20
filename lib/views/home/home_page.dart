import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_contacts/flutter_contacts.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/event_controller.dart';
import '../../models/user.dart' as app_user;
import '../../routes.dart';
import '../../services/auth_service.dart';
import '../../shared/widgets/custom_widgets.dart'; // Assumed custom widgets
import 'widgets/friend_list_item.dart';
import '../../shared/widgets/flashy_bottom_navigation_bar.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController _homeController = HomeController();
  final EventController _eventController = EventController();
  final AuthService _authService = AuthService();
  late Future<List<app_user.User>> _friendsFuture;

  @override
  void initState() {
    super.initState();
    _initializeFriends();
  }

  void _initializeFriends() {
    firebase_auth.User? currentUser = _authService.getCurrentUser();
    if (currentUser != null) {
      _friendsFuture = _homeController.getFriends(currentUser.uid);
    } else {
      // Handle the case where the user is not signed in
      _friendsFuture = Future.error('User not signed in');
    }
  }

  Future<void> _refresh() async {
    // Refresh friends list
    _initializeFriends();
    setState(() {});
  }

  void _addFriend() {
    _showAddFriendDialog();
  }

  void _showAddFriendDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AddFriendDialog(homeController: _homeController);
      },
    ).then((value) {
      if (value == true) {
        // If a friend was added, refresh the friends list
        _initializeFriends();
        setState(() {});
      }
    });
  }

  void _searchFriends() {
    showSearch(
      context: context,
      delegate: FriendSearchDelegate(_homeController, _authService),
    );
  }

  void _logout() async {
    await _authService.signOut();
    Navigator.of(context).pushReplacementNamed(AppRoutes.signIn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: 'Home Page',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            tooltip: 'Search Friends',
            onPressed: _searchFriends,
          ),
          IconButton(
            icon: Icon(Icons.person_add, color: Colors.white),
            tooltip: 'Add Friend',
            onPressed: _addFriend,
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<app_user.User>>(
          future: _friendsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CustomLoadingIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: CustomText(
                  text: 'Error: ${snapshot.error}',
                  color: Colors.red,
                  fontSize: 16,
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: CustomText(
                  text: 'No friends found',
                  fontSize: 18,
                  color: Colors.grey[700],
                ),
              );
            } else {
              List<app_user.User> friends = snapshot.data!;
              return ListView.builder(
                padding: EdgeInsets.all(16.0),
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
      bottomNavigationBar: FlashyBottomNavigationBar(
        currentIndex: 0, // Indicates Home Page
        onTap: (index) {
          switch (index) {
            case 0:
            // Already on Home Page
              break;
            case 1:
              firebase_auth.User? currentUser = _authService.getCurrentUser();
              if (currentUser != null) {
                Navigator.of(context).pushReplacementNamed(
                  AppRoutes.eventList,
                  arguments: currentUser.uid,
                );
              }
              break;
            case 2:
              Navigator.of(context).pushReplacementNamed(AppRoutes.profile);
              break;
            default:
              break;
          }
        },
      ),
    );
  }
}

/// Dialog for Adding Friends
class AddFriendDialog extends StatefulWidget {
  final HomeController homeController;

  AddFriendDialog({required this.homeController});

  @override
  _AddFriendDialogState createState() => _AddFriendDialogState();
}

class _AddFriendDialogState extends State<AddFriendDialog> {
  bool _isContactsSelected = true;
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _nameController = TextEditingController(); // Controller for friend's name
  bool _isLoading = false;
  String? _errorMessage;

  void _toggleSelection(bool isContacts) {
    setState(() {
      _isContactsSelected = isContacts;
      _errorMessage = null;
      _nameController.clear(); // Clear name when toggling
    });
  }

  Future<void> _selectFromContacts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      List<Contact> contacts = await widget.homeController.getDeviceContacts();
      if (contacts.isEmpty) {
        setState(() {
          _errorMessage = 'No contacts found.';
        });
        return;
      }

      // Show a dialog to select a contact
      Contact? selectedContact = await showDialog<Contact>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Select a Contact'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                Contact contact = contacts[index];
                String displayName = contact.displayName ?? 'No Name Found';
                return ListTile(
                  title: Text(displayName),
                  onTap: () {
                    Navigator.of(context).pop(contact);
                  },
                );
              },
            ),
          ),
        ),
      );

      if (selectedContact != null) {
        // Extract the first mobile number
        String? mobile = selectedContact.phones.isNotEmpty ? selectedContact.phones.first.number : null;
        String? name = selectedContact.displayName;

        if (mobile != null && mobile.isNotEmpty) {
          app_user.User? appUser = await widget.homeController.getCurrentUser();
          if (appUser != null) {
            bool success = await widget.homeController.addFriendByMobile(
              appUser.id,
              mobile,
              name: name, // Pass the friend's name
            );
            if (success) {
              Navigator.of(context).pop(true); // Indicate success
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Friend added successfully!')),
              );
            } else {
              setState(() {
                _errorMessage = 'Friend already added or cannot add yourself.';
              });
            }
          } else {
            setState(() {
              _errorMessage = 'User not authenticated.';
            });
          }
        } else {
          setState(() {
            _errorMessage = 'Selected contact has no mobile number.';
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to add friend: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addFriendManually() async {
    String mobile = _mobileController.text.trim();
    String name = _nameController.text.trim();

    if (mobile.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a mobile number.';
      });
      return;
    }

    if (name.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a name.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      app_user.User? appUser = await widget.homeController.getCurrentUser();
      if (appUser != null) {
        bool success = await widget.homeController.addFriendByMobile(
          appUser.id,
          mobile,
          name: name, // Pass the friend's name
        );
        if (success) {
          Navigator.of(context).pop(true); // Indicate success
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Friend added successfully!')),
          );
        } else {
          setState(() {
            _errorMessage = 'Friend already added or cannot add yourself.';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'User not authenticated.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to add friend: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: CustomText(
        text: 'Add Friend',
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ToggleButtons(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('Contacts'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('Mobile'),
                ),
              ],
              isSelected: [_isContactsSelected, !_isContactsSelected],
              onPressed: (int index) {
                _toggleSelection(index == 0);
              },
            ),
            SizedBox(height: 20),
            if (_isContactsSelected)
              ElevatedButton.icon(
                icon: Icon(Icons.contacts),
                label: Text('Select from Contacts'),
                onPressed: _isLoading
                    ? null
                    : () async {
                  await _selectFromContacts();
                },
              )
            else
              Column(
                children: [
                  AuthTextField(
                    controller: _mobileController,
                    labelText: 'Friend\'s Mobile Number',
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 20),
                  AuthTextField(
                    controller: _nameController,
                    labelText: 'Friend\'s Name',
                    keyboardType: TextInputType.name,
                  ),
                  SizedBox(height: 20),
                  CustomNeumorphicButton(
                    text: 'Add Friend',
                    onPressed: _isLoading
                        ? null
                        : () async {
                      await _addFriendManually();
                    },
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                ],
              ),
            if (_errorMessage != null) ...[
              SizedBox(height: 12),
              CustomText(
                text: _errorMessage!,
                color: Colors.red,
              ),
            ],
            if (_isLoading) ...[
              SizedBox(height: 20),
              CustomLoadingIndicator(),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading
              ? null
              : () => Navigator.of(context).pop(),
          child: CustomText(
            text: 'Cancel',
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

/// Search Delegate for Friends
class FriendSearchDelegate extends SearchDelegate<String> {
  final HomeController homeController;
  final AuthService authService;

  FriendSearchDelegate(this.homeController, this.authService);

  @override
  String get searchFieldLabel => 'Search Friends by Name';

  @override
  TextStyle? get searchFieldStyle => TextStyle(
    color: Colors.white,
  );

  @override
  InputDecorationTheme get searchFieldDecorationTheme => InputDecorationTheme(
    hintStyle: TextStyle(color: Colors.white54),
  );

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: theme.colorScheme.primary,
      ),
      inputDecorationTheme: searchFieldDecorationTheme,
      textTheme: TextTheme(
        titleLarge: searchFieldStyle!, // Updated for newer Flutter versions
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: Icon(Icons.clear, color: Colors.white),
          onPressed: () {
            query = '';
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () {
        close(context, ''); // Close search
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    firebase_auth.User? currentUser = authService.getCurrentUser();

    if (currentUser == null) {
      return Center(
        child: CustomText(
          text: 'User not signed in',
          color: Colors.red,
          fontSize: 16,
        ),
      );
    }

    return FutureBuilder<List<app_user.User>>(
      future: homeController.searchFriendsByName(query, currentUser.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CustomLoadingIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: CustomText(
              text: 'Error: ${snapshot.error}',
              color: Colors.red,
              fontSize: 16,
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: CustomText(
              text: 'No friends found',
              fontSize: 18,
              color: Colors.grey[700],
            ),
          );
        } else {
          List<app_user.User> searchResults = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.all(16.0),
            itemCount: searchResults.length,
            itemBuilder: (context, index) {
              return FriendListItem(
                friend: searchResults[index],
                subtitle: 'Tap to view events',
                onTap: () {
                  Navigator.of(context).pushNamed(
                    AppRoutes.eventList,
                    arguments: searchResults[index].id,
                  );
                },
              );
            },
          );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Optionally, implement suggestions
    return Center(
      child: CustomText(
        text: 'Search friends by name',
        color: Colors.grey,
        fontSize: 16,
      ),
    );
  }
}