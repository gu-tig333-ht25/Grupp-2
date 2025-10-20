import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/calendar_provider.dart';

class KalenderSida extends StatelessWidget {
  const KalenderSida({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final calendar = Provider.of<CalendarProvider>(context);

    if (!auth.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Kalender"),
          backgroundColor: const Color(0xFF8CA1DE),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.login),
            label: const Text("Logga in med Google"),
            onPressed: () async {
              await auth.signIn();
            },
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Min Google Kalender"),
        backgroundColor: const Color(0xFF8CA1DE),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async{
              await auth.signOut();
            },
          )
        ],
      ),
      body: FutureBuilder(
        future: calendar.loadEvents(auth),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (calendar.events.isEmpty) {
            return const Center(child: Text("Inga händelser hittades"));
          }

          return ListView.builder(
            itemCount: calendar.events.length,
            itemBuilder: (context, i) {
              final event = calendar.events[i];
              return ListTile(
                title: Text(event.summary ?? "Namnlös händelse"),
                subtitle: Text(event.start?.dateTime?.toLocal().toString() ?? "Ingen tid"),
              );
            },
          );
        },
      ),
    );
  }
}