import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'pages/signup.dart';
import 'pages/login.dart';
import 'views/mal_sida.dart';
import 'package:provider/provider.dart';
//import 'mal_provider.dart';
import 'views/timer.dart';
import 'views/betyg.dart';
import 'views/sessioner.dart';
import 'views/resurser_view.dart';
import 'calendar/calendar.dart';
import 'calendar/calendar_provider.dart';
import 'providers/session_provider.dart';
import 'providers/timer_provider.dart';
import 'views/dagens_session.dart';
import 'providers/mal_provider.dart';

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
        ChangeNotifierProvider(create: (_) => CalendarProvider())
      ],
      child: const MyApp(), // MyApp sköter routing och AuthGate
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
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF8CA1DE), 
          foregroundColor: Colors.white,
        ),
      ),

      home: const AuthGate(),
      routes: {
        '/login': (context) => const Login(),
        '/signup': (context) => const Signup(),
        '/timer': (context) => const TimerSida(),
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
          Provider.of<MalProvider>(context, listen: false).loadGoalsFromFirestore();
          return const HuvudNavigator();
        }

        return const Login();
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
    CalendarPage(),
    //ForumSida(),
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
        ],
      ),
    );
  }
}

// STARTSIDAN
class StartSida extends StatelessWidget {
  const StartSida({super.key});

  // Funktion för att logga ut
  Future<void> _loggaUt(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      // AuthGate hanterar navigeringen tillbaka till Login() automatiskt
    } catch (e) {
      // Hantera fel vid utloggning (t.ex. visa ett felmeddelande)
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        SnackBar(content: Text("Kunde inte logga ut: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final idagDatum = DateFormat('EEEE d MMMM', 'sv_SE').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Startsida'),
        actions: [
          TextButton(
            onPressed: () => _loggaUt(context),
            child: const Text(
              'Logga ut',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
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
                                  "Bok: Bamse och tjuvjakten\nLästid: 10 minuter",
                              style: TextStyle(fontSize: 14, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Knapp
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.2,
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

// ÖVRIGA UNDERSIDOR

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