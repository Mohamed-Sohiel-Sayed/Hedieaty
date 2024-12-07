// lib/views/profile/profile_page.dart
import 'package:flutter/material.dart';
import '../../controllers/profile_controller.dart';
import '../../models/user.dart';
import '../pledged_gifts/pledged_gifts_page.dart';

class ProfilePage extends StatelessWidget {
  final ProfileController _profileController = ProfileController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: FutureBuilder<UserModel>(
        future: _profileController.getUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No profile data found.'));
          } else {
            final user = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Name: ${user.name}'),
                  Text('Email: ${user.email}'),
                  Text('Phone: ${user.phoneNum}'),
                  ElevatedButton(
                    onPressed: () {
                      // Implement profile update functionality
                    },
                    child: Text('Update Profile'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PledgedGiftsPage()),
                      );
                    },
                    child: Text('My Pledged Gifts'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}