import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/calendar_provider.dart';
import '../providers/auth_provider.dart';

class KalenderSida extends StatefulWidget {
  const KalenderSida({super.key});

  @override
  State<KalenderSida> createState() => _KalenderSidaState();
}

class _KalenderSidaState extends State<KalenderSida> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final calendar = Provider.of<CalendarProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Kalender"),
        backgroundColor: const Color(0xFF8CA1DE),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => calendar.loadGoogleEvents(auth),
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: 'sv_SE',
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            eventLoader: (day) => calendar.getEventsForDay(day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_selectedDay != null) {
                calendar.addLocalEvent(_selectedDay!, "Ny lokal händelse");
              }
            },
            child: const Text("Lägg till lokal händelse"),
          ),
        ],
      ),
    );
  }
}