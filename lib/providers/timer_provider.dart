import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../views/betyg.dart'; // Behövs för att navigera till BetygSida

// Notera: Om du navigerar till HuvudNavigator i BetygSida efter sparning,
// behöver du inte importera HuvudNavigator här. Om du navigerar direkt
// till HuvudNavigator härifrån (vilket du inte gör), skulle du behöva en import.

class TimerProvider extends ChangeNotifier {
  int _seconds = 0;
  bool _isRunning = false;
  Timer? _timer;
  String _currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  int get seconds => _seconds;
  bool get isRunning => _isRunning;

  void checkNewDay() {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (today != _currentDate) {
      resetTimer();
      _currentDate = today;
    }
  }

  void startPauseTimer(BuildContext context) {
    checkNewDay();

    if (_isRunning) {
      _timer?.cancel();
      _isRunning = false;

      // Tidigare: Körde _showSessionSlutDialog här om tiden var lång nog
      // Vi behåller logiken för att pausa men dialogen kan skötas i endSession
      // eller som en separat knapp/händelse.
      // Här väljer vi att hålla timern pausad utan dialog för att undvika dubbelhantering.
      if (_seconds >= 600) {
        // Kör dialogen som en hint, men avbryt inte timern helt än.
        // Vi behåller _showSessionSlutDialog för att inte bryta funktionalitet:
        _showSessionSlutDialog(context);
      }
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _seconds++;
        notifyListeners();
      });
      _isRunning = true;
    }
    notifyListeners();
  }

  void resetTimer() {
    _timer?.cancel();
    _seconds = 0;
    _isRunning = false;
    notifyListeners();
  }

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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => BetygSida(readTime: sessionTime),
                ),
              );
              // Notera: resetTimer() hanteras nu i BetygSida när man sparar.
            },
          ),
        ],
      ),
    );
  }

  // Används om timern automatiskt pausas efter 10 min (600s)
  void _showSessionSlutDialog(BuildContext context) {
    final sessionTime = formattedTime; // Hämta tiden HÄR

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
                  // Skicka med tiden för att undvika vit skärm
                  builder: (_) => BetygSida(readTime: sessionTime), 
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String get formattedTime {
    final minutes = (_seconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}