import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'timer.dart'; 
import '../providers/timer_provider.dart';
import 'betyg.dart'; 

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
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const TimerSida()));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("⏱ Starta timer",
                  style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Hämta lästiden från TimerProvider innan navigering till BetygSida
                final timerProvider =
                    Provider.of<TimerProvider>(context, listen: false);
                
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    // Antar att BetygSida nu tar en `readTime` som argument
                    builder: (_) => BetygSida(readTime: timerProvider.formattedTime),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              child: const Text("⭐ Betygsätt dagens session",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}