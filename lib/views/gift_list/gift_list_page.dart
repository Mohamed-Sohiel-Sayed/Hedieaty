import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../controllers/gift_controller.dart';
import '../../models/gift.dart';
import '../../routes.dart';
import '../../services/auth_service.dart';
import '../../shared/widgets/refreshable widget.dart';
import 'widgets/gift_list_item.dart';
import 'widgets/gift_form.dart';
import '../../shared/widgets/flashy_bottom_navigation_bar.dart';
import '../../shared/widgets/custom_widgets.dart';

class GiftListPage extends StatefulWidget {
  final String eventId;
  final String userId;

  GiftListPage({required this.eventId, required this.userId});

  @override
  _GiftListPageState createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  final GiftController _controller = GiftController();
  final AuthService _authService = AuthService();
  late Stream<List<Gift>> _giftsStream;
  String _sortCriteria = 'name';
  bool _isCurrentUser = false;

  @override
  void initState() {
    super.initState();
    firebase_auth.User? currentUser = _authService.getCurrentUser();
    if (currentUser != null) {
      _isCurrentUser = currentUser.uid == widget.userId;
      _giftsStream = _controller.getGifts(widget.eventId);
    } else {
      // Handle the case where the user is not signed in
      _giftsStream = Stream.error('User not signed in');
    }
  }

  Future<void> _refresh() async {
    // Simulate a network call or data refresh
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      // Refresh the state of the widget
    });
  }

  void _showGiftForm({Gift? gift}) {
    if (_isCurrentUser) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return GiftForm(
            gift: gift,
            onSave: (Gift savedGift) {
              setState(() {});
            },
            eventId: widget.eventId,
            userId: widget.userId, // Pass the userId to the GiftForm
          );
        },
      );
    }
  }

  List<Gift> _sortGifts(List<Gift> gifts) {
    switch (_sortCriteria) {
      case 'name':
        gifts.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'category':
        gifts.sort((a, b) => a.category.compareTo(b.category));
        break;
      case 'status':
        gifts.sort((a, b) => a.status.compareTo(b.status));
        break;
    }
    return gifts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gift List'),
        actions: _isCurrentUser
            ? [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _showGiftForm();
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
                items: <String>['name', 'category', 'status']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      'Sort by $value',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  );
                }).toList(),
                dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Gift>>(
                stream: _giftsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CustomLoadingIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: CustomText(text: 'Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: CustomText(text: 'No gifts found'));
                  } else {
                    List<Gift> gifts = _sortGifts(snapshot.data!);
                    return ListView.builder(
                      itemCount: gifts.length,
                      itemBuilder: (context, index) {
                        return GiftListItem(
                          gift: gifts[index],
                          onEdit: _isCurrentUser && !gifts[index].isPledged
                              ? () {
                            _showGiftForm(gift: gifts[index]);
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