import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'timer.dart'; 
import '../providers/timer_provider.dart';
import 'betyg.dart'; 

// Dagens session sida - navigeringssida för timer och betyg
class DagensSessionSida extends StatelessWidget {
  const DagensSessionSida({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dagens session"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            
            //Knapp - starta timer
            ElevatedButton(
              onPressed: () {
                //Navigerar till TimerSida
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const TimerSida()));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Color.fromARGB(255, 140, 161, 222)),
              child: const Text("Starta timer",
                  style: TextStyle(color: Colors.white)),
            ),
            
            const SizedBox(height: 16),
            
            //Knapp - betygsätt session utan timer
            ElevatedButton(
              onPressed: () {
                // Hämta lästiden från TimerProvider innan navigering till BetygSida
                final timerProvider =
                    Provider.of<TimerProvider>(context, listen: false);
                
                //Navigerrar till betygsida och skickar med tid
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BetygSida(readTime: timerProvider.formattedTime),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Color.fromARGB(255, 230, 206, 74)),
              child: const Text("⭐ Betygsätt dagens session",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}