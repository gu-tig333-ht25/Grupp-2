import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../views/betyg.dart';

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

      if (_seconds >= 600) {
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