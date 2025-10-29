import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

//Calender Event - datamodell för en enkild händelse
class CalendarEvent {
  final TimeOfDay time;
  final String title;

  CalendarEvent({required this.time, required this.title});

  // För att spara till Firestore
  Map<String, dynamic> toMap() {
    return {
      'hour': time.hour,
      'minute': time.minute,
      'title': title,
    };
  }

  // För att läsa från Firestore
  static CalendarEvent fromMap(Map<String, dynamic> map) {
    return CalendarEvent(
      time: TimeOfDay(hour: map['hour'], minute: map['minute']),
      title: map['title'],
    );
  }
}

//Calenderprovider - hanterar kalenderdata och firestore-synk
class CalendarProvider extends ChangeNotifier {
  final Map<DateTime, List<CalendarEvent>> _events = {};

  // Firebase-instanser
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //Hämtar händelser för en specifik dag
  List<CalendarEvent> getEventsForDay(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    return _events[normalized] ?? [];
  }

  // Hämta händelser från Firestore
  Future<void> loadEventsFromFirestore() async {
    final user = _auth.currentUser;
    if (user == null) return;

    //Hämtar alla dokument från användarens calender samling
    final snapshot = await _db
        .collection('users')
        .doc(user.uid)
        .collection('calendar')
        .get();

    _events.clear();

    for (var doc in snapshot.docs) { //Datumet hämtas från dokumentets ID
      final dateParts = doc.id.split('-');
      final date = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
      );

      //Konverterar Firestore-listan av Maps till en lista av CalendarEvent-objekt
      final eventList = (doc['events'] as List)
          .map((e) => CalendarEvent.fromMap(Map<String, dynamic>.from(e)))
          .toList();

      _events[date] = eventList;
    }

    notifyListeners();
  }

  // Lägg till händelse
  Future<void> addEvent(DateTime date, CalendarEvent event) async {
    final normalized = DateTime(date.year, date.month, date.day);
    _events.putIfAbsent(normalized, () => []);
    _events[normalized]!.add(event);
    notifyListeners();

    //Sparar den uppdaterade listan till Firestore
    final user = _auth.currentUser;
    if (user != null) {
      final ref = _db
          .collection('users')
          .doc(user.uid)
          .collection('calendar')
          .doc("${date.year}-${date.month}-${date.day}");

      await ref.set({
        'events': _events[normalized]!.map((e) => e.toMap()).toList(),
      });
    }
  }

  // Ta bort händelse
  Future<void> removeEvent(DateTime date, CalendarEvent event) async {
    final normalized = DateTime(date.year, date.month, date.day);
    _events[normalized]?.remove(event);

    if (_events[normalized]?.isEmpty ?? false) {
      _events.remove(normalized);
    }
    notifyListeners();

    final user = _auth.currentUser;
    if (user != null) {
      final ref = _db
          .collection('users')
          .doc(user.uid)
          .collection('calendar')
          .doc("${date.year}-${date.month}-${date.day}");

      if (_events.containsKey(normalized)) {
        await ref.set({
          'events': _events[normalized]!.map((e) => e.toMap()).toList(),
        });
      } else {
        await ref.delete();
      }
    }
  }
}