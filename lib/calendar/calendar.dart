import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'calendar_provider.dart';
import 'package:intl/intl.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_auth/firebase_auth.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CalendarProvider>(context, listen: false)
        .loadEventsFromFirestore();
    });
  }

  @override
  Widget build(BuildContext context) {
    final calendarProvider = Provider.of<CalendarProvider>(context);
    final events =
        calendarProvider.getEventsForDay(_selectedDay ?? DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Kalender"),
        backgroundColor: const Color(0xFF8CA1DE),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: 'sv_SE',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: (day) => calendarProvider.getEventsForDay(day),
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.orangeAccent,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Color(0xFF8CA1DE),
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.deepPurple,
                shape: BoxShape.circle,
              ),
            ),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: [
                if (events.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text("Inga händelser denna dag."),
                    ),
                  )
                else
                  ...events.map((event) => Card(
                        color: const Color(0xFF8CA1DE),
                        child: ListTile(
                          title: Text(
                            event.title,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            "🕒 ${_formatTime24(event.time)}",
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.white),
                            onPressed: () {
                              calendarProvider.removeEvent(
                                  _selectedDay ?? DateTime.now(), event);
                            },
                          ),
                        ),
                      )),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF8CA1DE),
        onPressed: () => _showAddEventDialog(context, calendarProvider),
        child: const Icon(Icons.add),
      ),
    );
  }

  // ✅ Convert TimeOfDay → 24-hour formatted string
  String _formatTime24(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.Hm('sv_SE').format(dt); // HH:mm format (24h)
  }

  // ---- ADD EVENT DIALOG WITH SCROLLABLE TIME PICKER ----
  void _showAddEventDialog(
      BuildContext context, CalendarProvider calendarProvider) {
    final controller = TextEditingController();
    TimeOfDay? selectedTime;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Lägg till händelse"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: "Beskrivning av händelse",
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.access_time),
                label: Text(selectedTime == null
                    ? "Välj tid"
                    : "Vald tid: ${_formatTime24(selectedTime!)}"),
                onPressed: () async {
                  // Open scrollable time picker (Cupertino-style)
                  await showCupertinoModalPopup(
                    context: dialogContext,
                    builder: (_) => Container(
                      height: 250,
                      color: Colors.white,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 200,
                            child: CupertinoDatePicker(
                              mode: CupertinoDatePickerMode.time,
                              use24hFormat: true, // 24-hour format
                              initialDateTime: DateTime.now(),
                              onDateTimeChanged: (DateTime dateTime) {
                                setState(() {
                                  selectedTime = TimeOfDay(
                                    hour: dateTime.hour,
                                    minute: dateTime.minute,
                                  );
                                });
                              },
                            ),
                          ),
                          TextButton(
                            child: const Text(
                              "Klar",
                              style: TextStyle(
                                color: Color(0xFF8CA1DE),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Avbryt"),
              onPressed: () {
                if (Navigator.of(dialogContext).canPop()) {
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
            ElevatedButton(
              child: const Text("Lägg till"),
              onPressed: () async {
                final text = controller.text.trim();
                if (text.isNotEmpty && selectedTime != null) {
                  calendarProvider.addEvent(
                    _selectedDay ?? DateTime.now(),
                    CalendarEvent(time: selectedTime!, title: text),
                  );
                  if (Navigator.of(dialogContext).canPop()) {
                    Navigator.of(dialogContext).pop();
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Ange både titel och tid för händelsen"),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}