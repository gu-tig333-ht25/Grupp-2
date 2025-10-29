import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../providers/calendar_provider.dart';
import 'package:intl/intl.dart';

// sida som visar kalendern med möjlighet att lägga till och ta bort event
// event/händelser laddas via FireStore från CalendarProvider

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}
// Hanterar tillståndet för CalendarPage och interaktionen med användaren och kalendern.

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    // Laddar alla event från firestore när kalendern öppnas
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CalendarProvider>(context, listen: false)
        .loadEventsFromFirestore();
    });
  }

  @override
  Widget build(BuildContext context) {
    //hämtar tillgång till datan i kalendern genom provider
    final calendarProvider = Provider.of<CalendarProvider>(context);
    final events =
        calendarProvider.getEventsForDay(_selectedDay ?? DateTime.now());
    // Huvudlayouten för kalendern med appbar + kalendern + lista över händelser som man lagt in
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kalender"),
        backgroundColor: const Color(0xFF8CA1DE),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: 'sv_SE', //svensk lokal dvs veckodagar, datumformat 
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
              // uppdaterar valt datum man klickat på i kalendern
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
                // meddelande om vald dag ej har händelser
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text("Inga händelser denna dag."),
                    ),
                  )
                else
                //lista av händelser under kalendern med titel, tid raderaknapp
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
                              // tar bort event från kalendern
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

  // Konvertera DateTime till 24h formatering
  String _formatTime24(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.Hm('sv_SE').format(dt); 
  }

  //Lägga till händelser i kalendern där dialog ruta visas för att lägga till titel och tid för eventet.
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
                  // Öppna tidsväljaren
                  await showCupertinoModalPopup(
                    context: dialogContext,
                    builder: (_) => Container(
                      height: 250,
                      color: Colors.white,
                      child: Column(
                        children: [
                          // tidsväljaren
                          SizedBox(
                            height: 200,
                            child: CupertinoDatePicker(
                              mode: CupertinoDatePickerMode.time,
                              use24hFormat: true, // 24h formats
                              initialDateTime: DateTime.now(),
                              onDateTimeChanged: (DateTime dateTime) {
                                // uppdatera valda tiden
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
                // säkerställer att titel och tid är ifyllda
                if (text.isNotEmpty && selectedTime != null) {
                  calendarProvider.addEvent(
                    _selectedDay ?? DateTime.now(),
                    CalendarEvent(time: selectedTime!, title: text),
                  );
                  if (Navigator.of(dialogContext).canPop()) {
                    Navigator.of(dialogContext).pop();
                  }
                } else {
                  // visar felmedelande om man valt att fylla i något av de två, eller båda två
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