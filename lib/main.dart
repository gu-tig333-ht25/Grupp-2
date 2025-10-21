import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'timer.dart';
import 'session_provider.dart';
import 'betyg.dart';
import 'sessioner.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('sv_SE', null);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimerProvider()),
        ChangeNotifierProvider(create: (_) => SessionProvider()),
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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 64, 104, 222)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color.fromARGB(255, 252, 222, 133),
      ),
      home: const HuvudNavigator(),
      routes: {
        '/betyg': (context) => const BetygSida(),
      },
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
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => const InstallningarSida()));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Idag-ruta med starta session-knapp
              Container(
  decoration: BoxDecoration(
    color: const Color(0xFF8CA1DE),
    borderRadius: BorderRadius.circular(16),
  ),
  padding: const EdgeInsets.all(16),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      // Textdel (tar så mycket plats som möjligt)
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
              TextSpan(
                text:
                    "Bok: Bamse och tjuvjakten\nLästid: 10 minuter\nVideo: Fråga och utvärdera",
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
            ],
          ),
        ),
      ),

      const SizedBox(width: 12),

      // 🔽 Responsiv knappbredd
      SizedBox(
        width: MediaQuery.of(context).size.width * 0.2, // 20% av skärmens bredd
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF8CA1DE),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DagensSessionSida()),
            );
          },
          child: const Text(
            "Starta\nsession",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    ],
  ),
),

              const SizedBox(height: 24),

              // Övriga knappar på startsidan
              _buildNavButton(context, "🎯 Mål", const MalSida()),
              const SizedBox(height: 16),
              _buildNavButton(context, "⭐ Sessioner", const SessionerSida()), // Flyttad hit
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

// DAGENS SESSION-SIDA
class DagensSessionSida extends StatelessWidget {
  const DagensSessionSida({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dagens session"),
        centerTitle: true,
        backgroundColor: const Color(0xFF8CA1DE),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8CA1DE)),
              child: const Text("🎥 Se dagens video", style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => const TimerSida()));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("⏱ Starta timer", style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final timerProvider = Provider.of<TimerProvider>(context, listen: false);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BetygSida(readTime: timerProvider.formattedTime),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              child:
                  const Text("⭐ Betygsätt dagens session", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// KALENDER
class KalenderSida extends StatelessWidget {
  const KalenderSida({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kalender"),
        backgroundColor: const Color(0xFF8CA1DE),
        foregroundColor: Colors.white,
      ),
      body: const Center(child: Text("Här kan kalendern ligga.")),
    );
  }
}

// FAMILJEFORUM
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
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            "Här kan familjer dela erfarenheter och tips om dialogisk läsning.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}

// INSTÄLLNINGAR
class InstallningarSida extends StatelessWidget {
  const InstallningarSida({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inställningar"),
        backgroundColor: const Color(0xFF8CA1DE),
        foregroundColor: Colors.white,
      ),
      body: const Center(child: Text("Profil och appinställningar här.")),
    );
  }
}

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