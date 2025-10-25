import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart'; // Importera logiken

// Timer UI
class TimerSida extends StatelessWidget {
  const TimerSida({super.key});

  @override
  Widget build(BuildContext context) {
    // Använd Provider.of för att lyssna på ändringar från TimerProvider
    final timerProvider = Provider.of<TimerProvider>(context);
    
    // Anropa checkNewDay. Måste ligga här i build-metoden.
    // Låt Providern sköta logiken för att undvika onödiga anrop.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      timerProvider.checkNewDay();
    });

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