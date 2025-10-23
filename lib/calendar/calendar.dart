import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'calendar_provider.dart';
import 'package:intl/intl.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

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
            eventLoader: calendarProvider.getEventsForDay,
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
                          title: Text(event,
                              style: const TextStyle(color: Colors.white)),
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

  // ---- SAFE ADD EVENT DIALOG ----
  void _showAddEventDialog(
      BuildContext context, CalendarProvider calendarProvider) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Lägg till händelse"),
        content: TextField(
          controller: controller,
          decoration:
              const InputDecoration(hintText: "Beskrivning av händelse"),
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
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                calendarProvider.addEvent(
                    _selectedDay ?? DateTime.now(), text);
                if (Navigator.of(dialogContext).canPop()) {
                  Navigator.of(dialogContext).pop();
                }
              }
            },
          ),
        ],
      ),
    );
  }
}