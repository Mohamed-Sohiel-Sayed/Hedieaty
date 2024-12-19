import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../controllers/gift_controller.dart';
import '../../models/gift.dart';
import '../../services/auth_service.dart';
import '../../shared/widgets/custom_widgets.dart';

class PledgedGiftsPage extends StatefulWidget {
  @override
  _PledgedGiftsPageState createState() => _PledgedGiftsPageState();
}

class _PledgedGiftsPageState extends State<PledgedGiftsPage> {
  final AuthService _authService = AuthService();
  final GiftController _giftController = GiftController();
  late Stream<List<Gift>> _pledgedGiftsStream;

  @override
  void initState() {
    super.initState();
    firebase_auth.User? currentUser = _authService.getCurrentUser();
    if (currentUser != null) {
      String userId = currentUser.uid;
      _pledgedGiftsStream = _giftController.getPledgedGifts(userId);
    } else {
      // Handle the case where the user is not signed in
      _pledgedGiftsStream = Stream.error('User not signed in');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Pledged Gifts'),
      ),
      body: StreamBuilder<List<Gift>>(
        stream: _pledgedGiftsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CustomLoadingIndicator());
          } else if (snapshot.hasError) {
            return Center(child: CustomText(text: 'Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: CustomText(text: 'No pledged gifts found'));
          } else {
            List<Gift> gifts = snapshot.data!;
            return ListView.builder(
              itemCount: gifts.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: CustomText(text: gifts[index].name),
                  subtitle: CustomText(text: gifts[index].category),
                  trailing: IconButton(
                    icon: Icon(Icons.remove_circle_outline),
                    onPressed: () async {
                      // Logic to unpledge the gift
                      Gift updatedGift = gifts[index].copyWith(
                        isPledged: false,
                        pledgedBy: null,
                      );
                      await _giftController.updateGift(updatedGift);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gift unpledged successfully')),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}