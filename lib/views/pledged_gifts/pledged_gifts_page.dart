import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../controllers/gift_controller.dart';
import '../../models/gift.dart';
import '../../services/auth_service.dart';

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
      _pledgedGiftsStream = _giftController.getPledgedGifts(currentUser.uid);
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
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No pledged gifts found'));
          } else {
            List<Gift> gifts = snapshot.data!;
            return ListView.builder(
              itemCount: gifts.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(gifts[index].name),
                  subtitle: Text(gifts[index].category),
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      // Add logic to modify the pledge if still valid
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