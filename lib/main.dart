import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
//Importer för sidor och vyer
import 'pages/signup.dart';
import 'pages/login.dart';
import 'views/mal_sida.dart';
import 'views/timer.dart';
import 'views/sessioner.dart';
import 'views/resurser_view.dart';
import 'views/calendar.dart';
import 'views/omboken.dart';
import 'views/dagens_session.dart';
//Importer för tillståndshantering (Provider)
import 'package:provider/provider.dart';
import 'providers/calendar_provider.dart';
import 'providers/session_provider.dart';
import 'providers/timer_provider.dart';
import 'providers/mal_provider.dart';

//Huvudfunktion
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  await initializeDateFormatting('sv_SE', null); //Ställer in svenskt datumformat
  await Firebase.initializeApp( //Initierar firebase
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    //Tillhandahåller appens globala tillstånd (data)
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MalProvider()),
        ChangeNotifierProvider(create: (_) => TimerProvider()),
        ChangeNotifierProvider(create: (_) => SessionProvider()),
        ChangeNotifierProvider(create: (_) => CalendarProvider())
      ],
      child: const MyApp(), 
    ),
  );
}

//MyApp - Appens grundläggande struktur och tema
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dialogisk Läsning',
      theme: ThemeData(
        //Ställer in appens färgtema
        colorScheme:
            ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 64, 104, 222)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color.fromARGB(255, 251, 252, 252),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 45, 76, 114), 
          foregroundColor: Colors.white,
        ),
      ),

      //Startar appen med autentiseringskontrollen
      home: const AuthGate(),
      //Definerar namngivna rutter
      routes: {
        '/login': (context) => const Login(),
        '/signup': (context) => const Signup(),
        '/timer': (context) => const TimerSida(),
      },
    );
  }
}

//AuthGate - Kontrollerar användarens inloggningsstatus
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    //Lyssnar på inloggnings/utloggnings-händelser från Firebase
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        //Visar laddning
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        //Felhantering
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Fel i authStateChanges: ${snapshot.error}')),
          );
        }

        //Om användaren är inloggad:
        if (snapshot.hasData) {
          //Laddar in mål och sessioner från Firestore.
          Provider.of<MalProvider>(context, listen: false).loadGoalsFromFirestore();
          Provider.of<SessionProvider>(context, listen: false).loadSessionsFromFirestore();
          
          //Går tillbaka till Huvudnavigatorn.
          return const HuvudNavigator();
        }

        //Om använderar är utloggad:
        return const Login();
      },
    );
  }
}

// HuvudNavigator - appens Bottom-navigering
class HuvudNavigator extends StatefulWidget {
  const HuvudNavigator({super.key});

  @override
  State<HuvudNavigator> createState() => _HuvudNavigatorState();
}

class _HuvudNavigatorState extends State<HuvudNavigator> {
  int _valdIndex = 0;

  //Lista över vyer för bottenfältet
  final List<Widget> _sidor = const [
    StartSida(),
    CalendarPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _valdIndex = index; //Uppdaterar vald sida.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _sidor[_valdIndex],
      //Bottomnavigation-fältet
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 194, 194, 194),
        selectedItemColor: const Color.fromARGB(255, 227, 228, 228),
        unselectedItemColor: const Color.fromARGB(255, 98, 98, 98),
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

//Startsida - huvudskärmen efter inloggning
class StartSida extends StatelessWidget {
  const StartSida({super.key});

  // Funktion för att logga ut och rensa provider-data
  Future<void> _loggaUt(BuildContext context) async {
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    final malProvider = Provider.of<MalProvider>(context, listen: false);
    
    try {
      await FirebaseAuth.instance.signOut();
      //Rensar lokal data för att undvika problem vid nästa inloggning.
      sessionProvider.clearData();
      malProvider.clearData();
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
        centerTitle: true,
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
                  color: Color.fromARGB(255, 45, 76, 114),
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
                                  "Bok: Knacka på\nLästid: 10 minuter",
                              style: TextStyle(fontSize: 14, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Knapp för att starta session.
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.2,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color.fromARGB(255, 96, 96, 96),
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

              // Navigeringsknappar till appens övriga vyer
              _buildNavButton(context, "Mål", const MalSida()),
              const SizedBox(height: 16),
              _buildNavButton(context, "Sessioner", const SessionerSida()),
              const SizedBox(height: 16),
              _buildNavButton(context, "Om boken", const OmBokenSida()),
              const SizedBox(height: 16),
              _buildNavButton(context, "Resurser & videor", const ResurserSida()),
            ],
          ),
        ),
      ),
    );
  }

  //Hjälp-widget för att bygga de stora navigeringsknapparna
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