import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../controllers/gift_controller.dart';
import '../../models/gift.dart';
import '../../routes.dart';
import '../../services/auth_service.dart';
import '../../shared/widgets/custom_widgets.dart';
import 'widgets/gift_list_item.dart';
import 'widgets/gift_form.dart';
import '../../shared/widgets/flashy_bottom_navigation_bar.dart';

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
  String _sortCriteria = 'name';
  bool _isCurrentUser = false;
  Future<List<Gift>>? _giftsFuture;

  @override
  void initState() {
    super.initState();
    firebase_auth.User? currentUser = _authService.getCurrentUser();
    if (currentUser != null) {
      _isCurrentUser = currentUser.uid == widget.userId;
    }
    _fetchGifts();
  }

  void _fetchGifts() {
    setState(() {
      _giftsFuture = _controller.getAllGifts(widget.userId, widget.eventId);
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
              _fetchGifts(); // Refresh the gift list after saving
            },
            eventId: widget.eventId,
            userId: widget.userId,
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
      body: FutureBuilder<List<Gift>>(
        future: _giftsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CustomLoadingIndicator());
          } else if (snapshot.hasError) {
            return Center(child: CustomText(text: 'Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: CustomText(text: 'No gifts found'));
          } else {
            List<Gift> gifts = _sortGifts(snapshot.data!);
            return RefreshIndicator(
              onRefresh: () async {
                _fetchGifts();
              },
              child: ListView.builder(
                itemCount: gifts.length,
                itemBuilder: (context, index) {
                  return GiftListItem(
                    gift: gifts[index],
                    onEdit: _isCurrentUser && !gifts[index].isPledged
                        ? () {
                      _showGiftForm(gift: gifts[index]);
                    }
                        : null,
                    onDelete: () {
                      _fetchGifts(); // Refresh the gift list after deletion
                    },
                  );
                },
              ),
            );
          }
        },
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