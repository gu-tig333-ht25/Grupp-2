import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../views/betyg.dart';

//Timerprovider - hanterar all logik för timer, tid och sessionens slut
class TimerProvider extends ChangeNotifier {
  int _seconds = 0;
  bool _isRunning = false;
  Timer? _timer;
  String _currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now()); // Håller reda på vilket datum timern startades

  int get seconds => _seconds;
  bool get isRunning => _isRunning;

  //Kontrollerar om det blivit en ny dag och nollställer vid behov
  void checkNewDay() {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (today != _currentDate) {
      resetTimer();
      _currentDate = today;
    }
  }

  //Startar, Pausar timern och kontrollerar för autoslutförande (10 min)
  void startPauseTimer(BuildContext context) {
    checkNewDay();

    if (_isRunning) {
      //Pausa timern
      _timer?.cancel();
      _isRunning = false;

      //Om över 10 minuter, visa dialogen om du pausar
      if (_seconds >= 600) {
        _showSessionSlutDialog(context);
      }

    } else {
      //Starta timern
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _seconds++;
        notifyListeners();
      });
      _isRunning = true;
    }
    notifyListeners();
  }

  //Nollståller tid och stoppar timern
  void resetTimer() {
    _timer?.cancel();
    _seconds = 0;
    _isRunning = false;
    notifyListeners();
  }

  //Avslutar sessionen via knappstryck
  void endSession(BuildContext context) {
    _timer?.cancel();
    _isRunning = false;
    
    final sessionTime = formattedTime;

    // Visa popup innan man går till Betygsätt-sidan
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("🎉 Session avslutad!"),
        content: const Text(
            "Bra jobbat! Vill du gå vidare och betygsätta dagens läsning?"),
        actions: [
          TextButton(
            child: const Text("Stäng"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("Betygsätt"),
            onPressed: () {
              Navigator.pop(context);
              //Navigerar till betygssidan och skickar med läst tid
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => BetygSida(readTime: sessionTime),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Används om timern automatiskt pausas efter 10 min (600s)
  void _showSessionSlutDialog(BuildContext context) {
    final sessionTime = formattedTime;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("🎉 Session slutförd!"),
        content: const Text(
            "Bra jobbat! Vill du gå vidare och betygsätta dagens läsning?"),
        actions: [
          TextButton(
            child: const Text("Stäng"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("Betygsätt"),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  // Skicka med tiden till betygssidan
                  builder: (_) => BetygSida(readTime: sessionTime), 
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  //Retunerar tiden i format MM:SS
  String get formattedTime {
    final minutes = (_seconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  //Stoppar timern när providern tas bort från minnet
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}