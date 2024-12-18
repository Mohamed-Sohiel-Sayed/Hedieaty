import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';

class EventController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addEvent(Event event) async {
    DocumentReference docRef = _firestore.collection('events').doc();
    event = event.copyWith(id: docRef.id);
    await docRef.set(event.toMap());
  }

  Future<void> updateEvent(Event event) async {
    await _firestore.collection('events').doc(event.id).update(event.toMap());
  }

  Future<void> deleteEvent(String eventId) async {
    await _firestore.collection('events').doc(eventId).delete();
  }

  Stream<List<Event>> getEvents(String userId) {
    return _firestore.collection('events').where('userId', isEqualTo: userId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
    });
  }

  Future<int> getUpcomingEventsCount(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('events')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThan: DateTime.now().toIso8601String())
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }
}