import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'pages/signup.dart';
import 'pages/login.dart';
import 'mal_sida.dart';
import 'package:provider/provider.dart';
import 'mal_provider.dart';
import 'views/resurser_view.dart';
import 'timer.dart';
import 'session_provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('sv_SE', null); // Initiera svenska locale
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MalProvider()),
        ChangeNotifierProvider(create: (_) => TimerProvider()),
        ChangeNotifierProvider(create: (_) => SessionProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dialogisk Läsning',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 64, 104, 222)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color.fromARGB(255, 252, 222, 133),
      ),
      home: const InitFirebase(),
      routes: {
        '/login': (context) => const Login(),
        '/signup': (context) => const Signup(),
        '/timer': (context) => const TimerSida(),
      },
    );
  }
}

class InitFirebase extends StatelessWidget {
  const InitFirebase({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseApp>(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Fel vid Firebase-initiering: ${snapshot.error}'),
            ),
          );
        }
        return const AuthGate();
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Fel i authStateChanges: ${snapshot.error}')),
          );
        }

        if (snapshot.hasData) {
          return const DialoglasningsApp();
        }

        return const Login();
      },
    );
  }
}

class DialoglasningsApp extends StatelessWidget {
  const DialoglasningsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dialogisk Läsning',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 64, 104, 222)),
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
                  children: [
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "📅 Idag: $idagDatum\n",
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => const DagensSessionSida()));
                      },
                      child: const Text("Starta session"),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Övriga knappar på startsidan
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
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => const BetygSida()));
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

class BetygSida extends StatelessWidget {
  const BetygSida({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Betygsätt dagens läsning")),
      body: const Center(child: Text("Här kan du ge ett betyg på dagens lästillfälle.")),
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


