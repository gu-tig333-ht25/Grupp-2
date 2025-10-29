import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/session_provider.dart';
import '../providers/timer_provider.dart';
import '../main.dart';

//Betygsättningssida
class BetygSida extends StatefulWidget {
  final String? readTime; // Lästid från timer
  final String? datum;
  final String? sessionId;
  
  const BetygSida({super.key, this.readTime, this.datum, this.sessionId});

  @override
  State<BetygSida> createState() => _BetygSidaState();
}

class _BetygSidaState extends State<BetygSida> {
  int engagemang = 0;
  int kvalitet = 0;
  int uppmarksamhet = 0;
  TextEditingController anteckningController = TextEditingController();
  String displayReadTime = '00:00';

  @override
  void initState() {
    super.initState();
    //Beräkna vilket datum vi ska titta på (dagens om inget skickas med)
    final targetDate = widget.datum ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
    //Försök hämta en befintlig session före detta datum
    final session = Provider.of<SessionProvider>(context, listen: false)
        .getSessionForDate(targetDate);

    //Om session redan finns, ladda in befintliga värden öfr redigering
    if (session != null) {
      engagemang = session.engagemang;
      kvalitet = session.kvalitet;
      uppmarksamhet = session.uppmarksamhet;
      anteckningController.text = session.anteckning;
      displayReadTime = session.lastReadTime;
    }
    
    //Annars (ny session), använd lästiden som skickades in från timern
    else {
      displayReadTime = widget.readTime ?? '00:00';
    }
  }

  //Hjälp-widget för stjärnbetyg
  Widget starRating(String label, int value, void Function(int) onChanged) {
    return Row(
      children: [
        SizedBox(width: 120, child: Text(label)),
        ...List.generate(5, (index) {
          return IconButton(
            icon: Icon(
              index < value ? Icons.star : Icons.star_border,
              color: Colors.amber,
            ),
            onPressed: () => onChanged(index + 1),
          );
        })
      ],
    );
  }

  // Frigör minneskontrollern
  @override
  void dispose() {
    anteckningController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Betygsätt dagens session"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Lästid idag: $displayReadTime",
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 24),
              
              //Betygskontroller
              starRating("Engagemang", engagemang, (v) {
                setState(() => engagemang = v);
              }),
              starRating("Kvalitet", kvalitet, (v) {
                setState(() => kvalitet = v);
              }),
              starRating("Uppmärksamhet", uppmarksamhet, (v) {
                setState(() => uppmarksamhet = v);
              }),
              const SizedBox(height: 16),
              
              //Anteckningsfält
              TextField(
                controller: anteckningController,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Anteckning (frivillig)',
                ),
              ),
              const SizedBox(height: 24),
              
              //Spara-knapp
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    //Skapa session-objektet
                    final session = Session(
                      // Använder befintligt ID för uppdatering, annars tomt för nytt
                      id: widget.sessionId ?? '',
                      datum: widget.datum?? today,
                      engagemang: engagemang,
                      kvalitet: kvalitet,
                      uppmarksamhet: uppmarksamhet,
                      anteckning: anteckningController.text,
                      lastReadTime: displayReadTime,
                    );

                    // Spara/Uppdatera sessionen via Provider
                    Provider.of<SessionProvider>(context, listen: false)
                        .addOrUpdateSession(session);

                    //Nollställ timern 
                    Provider.of<TimerProvider>(context, listen: false).resetTimer();

                    //Navigera tillbaka till huvudnavigatorn och rensa stacken
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const HuvudNavigator(),
                      ),
                      (Route<dynamic> route) => false, // Rensa alla rutter under
                    );
                  },

                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF8CA1DE), 
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16))),
                  child: const Text("Spara", style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}