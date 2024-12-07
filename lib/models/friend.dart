// lib/models/friend.dart
import 'event.dart';

class Friend {
  final String id;
  final String name;
  //final String profilePictureUrl;
  final List<EventModel> upcomingEvents;

  Friend({
    required this.id,
    required this.name,
    //required this.profilePictureUrl,
    required this.upcomingEvents,
  });
}