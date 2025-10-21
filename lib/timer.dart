import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'betyg.dart';

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
              resetTimer(); // nollställ efter att readTime är skickad
            },
          ),
        ],
      ),
    );
  }

  void _showSessionSlutDialog(BuildContext context) {
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
                MaterialPageRoute(builder: (_) => const BetygSida()),
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

// Timer UI
class TimerSida extends StatelessWidget {
  const TimerSida({super.key});

  @override
  Widget build(BuildContext context) {
    final timerProvider = Provider.of<TimerProvider>(context);
    timerProvider.checkNewDay(); // Nollställ om nytt datum

    final buttonWidth = 200.0;
    final buttonTextStyle = const TextStyle(fontSize: 18, color: Colors.white);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Timer"),
        centerTitle: true,
        backgroundColor: const Color(0xFF8CA1DE),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Lästid",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                timerProvider.formattedTime,
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8CA1DE),
                ),
              ),
              const SizedBox(height: 40),

              // Start/Pausa
              SizedBox(
                width: buttonWidth,
                child: ElevatedButton.icon(
                  icon: Icon(timerProvider.isRunning
                      ? Icons.pause
                      : Icons.play_arrow),
                  label: Text(timerProvider.isRunning ? "Pausa" : "Starta",
                      style: buttonTextStyle),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: timerProvider.isRunning
                        ? Colors.orange
                        : const Color(0xFF8CA1DE),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => timerProvider.startPauseTimer(context),
                ),
              ),
              const SizedBox(height: 16),

              // Nollställ
              SizedBox(
                width: buttonWidth,
                child: ElevatedButton(
                  onPressed: timerProvider.resetTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text("Nollställ", style: buttonTextStyle),
                ),
              ),
              const SizedBox(height: 16),

              // Klar
              SizedBox(
                width: buttonWidth,
                child: ElevatedButton(
                  onPressed: () => timerProvider.endSession(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text("Klar", style: buttonTextStyle),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}