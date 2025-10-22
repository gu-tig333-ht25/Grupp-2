import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'features/calendar/providers/auth_provider.dart';
import 'features/calendar/providers/calendar_provider.dart';
import 'features/calendar/screens/kalender_sida.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('sv_SE', null);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CalendarProvider()),
      ],
      child: const DialoglasningsApp(),
    ),
  );
}

class DialoglasningsApp extends StatelessWidget {
  const DialoglasningsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dialogisk Läsning',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 64, 104, 222)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color.fromARGB(255, 252, 222, 133),
      ),
      home: const HuvudNavigator(),
    );
  }
}

// HUVUDNAVIGATOR MED BOTTOM BAR
class HuvudNavigator extends StatefulWidget {
  const HuvudNavigator({super.key});

  @override
  State<HuvudNavigator> createState() => _HuvudNavigatorState();
}

class _HuvudNavigatorState extends State<HuvudNavigator> {
  int _valdIndex = 0;

  final List<Widget> _sidor = const [
    StartSida(),
    KalenderSida(),
    ForumSida(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _valdIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _sidor[_valdIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF8CA1DE),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: _valdIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Start"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Kalender"),
          BottomNavigationBarItem(icon: Icon(Icons.family_restroom), label: "Forum"),
        ],
      ),
    );
  }
}

// STARTSIDAN
class StartSida extends StatelessWidget {
  const StartSida({super.key});

  @override
  Widget build(BuildContext context) {
    final idagDatum = DateFormat('EEEE d MMMM', 'sv_SE').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Startsida'),
        backgroundColor: const Color(0xFF8CA1DE),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF8CA1DE),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "📅 Idag: $idagDatum\n",
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            const TextSpan(
                              text:
                                  "Bok: Bamse och tjuvjakten\nLästid: 10 minuter\nSe video: Hur man läser interaktivt",
                              style: TextStyle(fontSize: 14, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF8CA1DE),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {},
                      child: const Text("Starta session"),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildNavButton(context, "🎯 Mål", const MalSida()),
              const SizedBox(height: 16),
              _buildNavButton(context, "⭐ Sessioner", const SessionerSida()),
              const SizedBox(height: 16),
              _buildNavButton(context, "📖 Om boken", const OmBokenSida()),
              const SizedBox(height: 16),
              _buildNavButton(context, "🎥 Resurser & videor", const ResurserSida()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton(BuildContext context, String text, Widget sida) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF8CA1DE),
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => sida));
      },
      child: Text(text, style: const TextStyle(fontSize: 18, color: Colors.white)),
    );
  }
}

// FORUM
class ForumSida extends StatelessWidget {
  const ForumSida({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Familjeforum"),
        centerTitle: true,
        backgroundColor: const Color(0xFF8CA1DE),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          "Här kan familjer dela erfarenheter och tips om dialogisk läsning.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

// SESSIONER
class SessionerSida extends StatelessWidget {
  const SessionerSida({super.key});
  final List<Map<String, String>> sessioner = const [
    {"datum": "Fredag 19 oktober", "betyg": "4", "anteckning": "Tuve var engagerad idag"},
    {"datum": "Lördag 20 oktober", "betyg": "3", "anteckning": "Lite trött men vi läste två sidor"},
    {"datum": "Söndag 21 oktober", "betyg": "5", "anteckning": "Väldigt fokuserad läsning!"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sessioner"),
        centerTitle: true,
        backgroundColor: const Color(0xFF8CA1DE),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sessioner.length,
        itemBuilder: (context, index) {
          final session = sessioner[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const Icon(Icons.bookmark, color: Color(0xFF8CA1DE)),
              title: Text(session["datum"]!),
              subtitle: Text("Betyg: ${session["betyg"]}/5\n${session["anteckning"]}"),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}

// ÖVRIGA SIDER
class MalSida extends StatelessWidget {
  const MalSida({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mål")),
      body: const Center(child: Text("Sätt och följ upp mål här.")),
    );
  }
}

class OmBokenSida extends StatelessWidget {
  const OmBokenSida({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Om boken")),
      body: const Center(child: Text("Information om boken här.")),
    );
  }
}

class ResurserSida extends StatelessWidget {
  const ResurserSida({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Resurser & videor")),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          ListTile(
            leading: Icon(Icons.link),
            title: Text("Introduktion till dialogisk läsning"),
          ),
          ListTile(
            leading: Icon(Icons.link),
            title: Text("PEER-sekvens och exempel"),
          ),
          ListTile(
            leading: Icon(Icons.link),
            title: Text("CROWD-frågor och metoder"),
          ),
          ListTile(
            leading: Icon(Icons.video_library),
            title: Text("Se instruktionsvideo om lässtrategier"),
          ),
        ],
      ),
    );
  }
}